import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc; // Alias to avoid conflict
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/road_service.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/data/models/activity_model/activity_model.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart';
import 'package:orka_sports/presentation/blocs/activity/activity_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_event.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/blocs/location/location_event.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/blocs/location/location_bloc.dart';
import 'package:orka_sports/presentation/blocs/location/location_state.dart' as AppLocationState; // Alias
import 'package:orka_sports/presentation/view/body/activity_screen/history_screen/history_screen.dart';
import 'package:orka_sports/presentation/view/body/gear_screen/gear_screen.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivitySessionScreen extends StatefulWidget {
  final String activityType; // e.g., "Walking", "Running", "Cycling"
  final IconData activityIcon;
  final String activityId;
  final String yourGoal;
  final double distanceGoal;
  final ActivityRepository activityRepo;

  const ActivitySessionScreen({
    super.key,
    required this.activityType,
    required this.activityIcon,
    required this.activityId,
    required this.yourGoal,
    required this.distanceGoal,
    required this.activityRepo,
  });

  @override
  State<ActivitySessionScreen> createState() => _ActivitySessionScreenState();
}

class _ActivitySessionScreenState extends State<ActivitySessionScreen> {
  bool isStarted = false;
  double distanceGoal = 3.5;
  String goalType = 'Distance';
  final List<String> goalTypes = ['Distance', 'Time'];
  int _currentIndex = 0;

  DateTime? _startTime;
  Timer? _activityTimer;
  int _durationSeconds = 0;

  final loc.Location _locationController = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  final Completer<GoogleMapController> _mapCompleter = Completer<GoogleMapController>();
  GoogleMapController? _mapController;

  LatLng? _initialMapCenter;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routeCoordinates = [];

  // ADD THESE VARIABLES FOR ROAD FOLLOWING
  List<LatLng> _roadSnappedCoordinates = [];

  String _sourceLat = "0.0";
  String _sourceLng = "0.0";
  String _destinationLat = "0.0";
  String _destinationLng = "0.0";

  // _currentDistanceKm will now be primarily for live UI display from GPS
  // The final distance for saving will come from the health package if available
  double _liveGpsDistanceKm = 0.0;
  String _avgPace = "00:00"; // Will be recalculated with final distance

  // _caloriesBurned will be primarily for live UI display from calculation
  // The final calories for saving will come from the health package if available
  String _liveCalculatedCaloriesBurned = "0.0";

  double _maxSpeed = 0.0;
  int _overSpeedingCount = 0;
  double _totalElevationGain = 0.0;
  double _lastElevation = 0.0;
  double _weight = 70.0; // Default, will try to fetch from profile
  bool _isStopping = false;

  Marker? _userMarker;

  // Health package factory
  // final Health _health = Health();
  // final List<HealthDataType> _healthDataTypes = [HealthDataType.DISTANCE_DELTA, HealthDataType.ACTIVE_ENERGY_BURNED];

  @override
  void initState() {
    super.initState();
    context.read<ActivityListBloc>().add(LoadActivityList());

    _requestPermissions(); // Combines location and health permissions
    log('ActivitySessionScreen initialized with activity Id: ${widget.activityId}');
    final locationBlocState = context.read<LocationBloc>().state;
    if (locationBlocState is AppLocationState.LocationLoaded) {
      _initialMapCenter = LatLng(locationBlocState.latitude, locationBlocState.longitude);
      _updateUserMarker(_initialMapCenter!);
    } else {
      _initialMapCenter = const LatLng(22.17, 70.79); // Default
      context.read<LocationBloc>().add(FetchLocationEvent());
    }

    // Fetch user weight from ProfileBloc
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final weightString = profileState.profile.weight;
      if (weightString != null && weightString.isNotEmpty) {
        _weight = double.tryParse(weightString) ?? 70.0;
        log("User weight set from profile: $_weight kg");
      }
    } else {
      log("Profile not loaded at initState, using default weight: $_weight kg");
      // Consider dispatching an event to load profile if necessary and listen for it
    }
    distanceGoal = (widget.distanceGoal == 0 || widget.distanceGoal == 0.0) ? 3.5 : widget.distanceGoal;
  }

  Future<void> _requestPermissions() async {
    // Location Permissions only
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          showCustomSnackbar(context, "Location service is disabled.");
        }
      }
    }

    loc.PermissionStatus permissionStatus = await _locationController.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await _locationController.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        if (mounted) {
          showCustomSnackbar(context, "Location permissions are denied.");
        }
      }
    }

    log("Only location permissions requested. Health Connect disabled.");
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapCompleter.isCompleted) {
      _mapCompleter.complete(controller);
    }
    _mapController = controller;
    if (_initialMapCenter != null && mounted) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(_initialMapCenter!, 15.0));
      // If not already started, ensure user marker is at initial/current known loc
      if (!isStarted && _initialMapCenter != null) {
        _updateUserMarker(_initialMapCenter!);
      }
    }
  }

  _updateUserMarker(LatLng position) {
    if (!mounted) return;
    setState(() {
      // Clear existing markers that are just for user's current location if needed
      // _markers.removeWhere((m) => m.markerId.value == 'user_location');
      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // A different color for live tracking
      );
      // Add it to the main set if you want it to persist, or handle it separately
      _markers.add(_userMarker!);
    });
  }

  void _startActivityTimer() {
    _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _durationSeconds++;
        if (_liveGpsDistanceKm > 0) {
          _avgPace = _formatPace(_liveGpsDistanceKm, _durationSeconds);
        } else {
          _avgPace = "0.00";
        }
        // Live calorie update using MET formula
        _liveCalculatedCaloriesBurned = _calculateCaloriesBurned(
          _liveGpsDistanceKm,
          _durationSeconds,
          _weight,
        ).toStringAsFixed(1);
      });
    });
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  double _calculateCaloriesBurned(double distanceKm, int durationSeconds, double weight) {
    double met = 0.0;
    switch (widget.activityType) {
      case 'Walking':
        met = 3.5;
        break;
      case 'Running':
        met = 9.8;
        break;
      case 'Cycling':
        met = 7.5;
        break;
      default:
        met = 3.5;
    }
    double durationHours = durationSeconds / 3600;
    double calories = met * weight * durationHours;
    return calories; // Raw value, format when displaying/saving
  }

  void _checkOverspeeding(double currentSpeed) {
    double speedLimit = 0.0;
    switch (widget.activityType) {
      case 'Walking':
        speedLimit = 6.0;
        break;
      case 'Running':
        speedLimit = 20.0;
        break;
      case 'Cycling':
        speedLimit = 30.0;
        break;
      default:
        speedLimit = 6.0;
    }
    if (currentSpeed > speedLimit) _overSpeedingCount++;
  }

  Future<void> _startSession() async {
    setState(() {
      isStarted = true;
      _startTime = DateTime.now();
      _durationSeconds = 0;
      _liveGpsDistanceKm = 0.0;
      _routeCoordinates.clear();
      // ADD THIS LINE FOR ROAD FOLLOWING
      _roadSnappedCoordinates.clear();
      _markers.clear();
      _polylines.clear();
      _avgPace = "00:00";
      _liveCalculatedCaloriesBurned = "0.0";
      _overSpeedingCount = 0;
      _totalElevationGain = 0.0;
      _lastElevation = 0.0;
      _maxSpeed = 0.0;
    });

    _startActivityTimer();

    try {
      loc.LocationData? currentLocation = await _locationController.getLocation();
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        _sourceLat = currentLocation.latitude!.toString();
        _sourceLng = currentLocation.longitude!.toString();

        final startLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _routeCoordinates.add(startLatLng);
        _addMarker(startLatLng, "start_marker", "Start Point");
        _updateUserMarker(startLatLng);

        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLngZoom(startLatLng, 17.0));
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, "Could not get start location: $e");
      }
    }

    const double minMovementThresholdMeters = 5;
    const double minSpeedThresholdKmph = 0.5;

    _locationSubscription = _locationController.onLocationChanged.listen((loc.LocationData newLocation) async {
      if (newLocation.latitude != null &&
          newLocation.longitude != null &&
          newLocation.accuracy != null &&
          newLocation.accuracy! <= 20.0 &&
          mounted) {
        final newLatLng = LatLng(newLocation.latitude!, newLocation.longitude!);
        final lastLatLng = _routeCoordinates.isNotEmpty ? _routeCoordinates.last : newLatLng;

        double segmentDistance = Geolocator.distanceBetween(
          lastLatLng.latitude,
          lastLatLng.longitude,
          newLatLng.latitude,
          newLatLng.longitude,
        );

        double currentSpeedKmph = (newLocation.speed != null)
            ? newLocation.speed! * 3.6
            : (segmentDistance / 1000.0) / (1 / 3600); // fallback

        // Skip if distance or speed is too low (stationary or drift)
        if (segmentDistance < minMovementThresholdMeters || currentSpeedKmph < minSpeedThresholdKmph) {
          return;
        }

        _updateUserMarker(newLatLng);

        setState(() {
          _liveGpsDistanceKm += segmentDistance / 1000.0;

          _checkOverspeeding(currentSpeedKmph);
          if (currentSpeedKmph > _maxSpeed) _maxSpeed = currentSpeedKmph;

          if (newLocation.altitude != null) {
            double currentElevation = newLocation.altitude!;
            if (_lastElevation > 0 && currentElevation > _lastElevation) {
              _totalElevationGain += (currentElevation - _lastElevation);
            }
            _lastElevation = currentElevation;
          }

          _routeCoordinates.add(newLatLng);
          _destinationLat = newLocation.latitude!.toString();
          _destinationLng = newLocation.longitude!.toString();
        });

        // ADD ROAD SNAPPING LOGIC - Snap every 5 GPS points
        if (_routeCoordinates.length % 5 == 0) {
          try {
            final snappedPoints = await RoadService.snapToRoads(_routeCoordinates);
            if (mounted) {
              setState(() {
                _roadSnappedCoordinates = snappedPoints;
                _updatePolyline();
              });
            }
          } catch (e) {
            log('Road snapping failed: $e');
            // Fallback to GPS coordinates
            setState(() {
              _roadSnappedCoordinates = List.from(_routeCoordinates);
              _updatePolyline();
            });
          }
        } else {
          // Update polyline with existing data
          _updatePolyline();
        }

        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(newLatLng));
        }
      }
    });
  }

  void _addMarker(LatLng position, String markerId, String title) {
    if (!mounted) return;
    setState(() {
      // Remove old user marker before adding point specific markers like start/end
      _markers.removeWhere((m) => m.markerId.value == 'user_location');
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            markerId == "start_marker" ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
        ),
      );
    });
  }

  // MODIFIED METHOD TO USE ROAD-SNAPPED COORDINATES
  void _updatePolyline() {
    if (!mounted) return;
    
    // Use road-snapped coordinates if available, otherwise use GPS coordinates
    final coordinatesToUse = _roadSnappedCoordinates.isNotEmpty 
        ? _roadSnappedCoordinates 
        : _routeCoordinates;
    
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: List<LatLng>.from(coordinatesToUse),
          color: AppColors.primary,
          width: 5,
        ),
      );
    });
  }

  Future<Map<String, double?>> _fetchHealthData(DateTime startTime, DateTime endTime) async {
    log("Skipping health data fetch. Returning fallback values for GPS.");
    return {
      'distance': null, // Will fallback to GPS distance
      'calories': null, // Will fallback to calculated calories
    };
  }

  Future<void> _stopSession() async {
    if (_activityTimer!.isActive) _activityTimer?.cancel();
    _locationSubscription?.cancel();
    final DateTime endTime = DateTime.now();

    // Fetch final location for destination coordinates
    try {
      loc.LocationData? finalLocation = await _locationController.getLocation();
      if (finalLocation.latitude != null && finalLocation.longitude != null) {
        _destinationLat = finalLocation.latitude!.toString();
        _destinationLng = finalLocation.longitude!.toString();
        final finalLatLng = LatLng(finalLocation.latitude!, finalLocation.longitude!);
        if (_routeCoordinates.isNotEmpty && _routeCoordinates.last != finalLatLng) {
          _routeCoordinates.add(finalLatLng);
        }
        _addMarker(finalLatLng, "end_marker", "End Point");
      }
    } catch (e) {
      log("Error getting final location: $e");
    }

    setState(() {
      isStarted = false;
    });

    // Fetch data from HealthKit/Google Fit
    Map<String, double?> healthMetrics = await _fetchHealthData(_startTime!, endTime);
    double? healthDistanceMeters = healthMetrics['distance'];
    double? healthCaloriesKcal = healthMetrics['calories'];

    // Determine final distance
    double finalDistanceKm;
    if (healthDistanceMeters != null && healthDistanceMeters > 0) {
      finalDistanceKm = healthDistanceMeters / 1000.0;
      log("Using Health distance: ${finalDistanceKm.toStringAsFixed(3)} km");
    } else {
      finalDistanceKm = _liveGpsDistanceKm;
      log("Using GPS distance: ${finalDistanceKm.toStringAsFixed(3)} km");
      if (mounted) {
        showCustomSnackbar(context, "Using GPS distance due to health data issue.");
      }
    }

    // Determine final calories
    String finalCaloriesBurned;
    if (healthCaloriesKcal != null && healthCaloriesKcal > 0) {
      finalCaloriesBurned = healthCaloriesKcal.toStringAsFixed(1);
      log("Using Health calories: $finalCaloriesBurned kcal");
    } else {
      finalCaloriesBurned = _calculateCaloriesBurned(finalDistanceKm, _durationSeconds, _weight).toStringAsFixed(1);
      log("Using calculated calories: $finalCaloriesBurned kcal");
      if (mounted) {
        showCustomSnackbar(context, "Using calculated calories due to health data issue.");
      }
    }

    // Calculate final pace
    String finalAvgPace = _formatPace(finalDistanceKm, _durationSeconds);
    log("Final pace: $finalAvgPace min/km");

    // Format duration
    String formattedDuration = _formatDuration(_durationSeconds);
    log("Final duration: $formattedDuration");

    // Format elevation gain
    String formattedElevation = _totalElevationGain.toStringAsFixed(1);
    log("Final elevation gain: $formattedElevation m");

    final userId = await SharedPreferences.getInstance().then((prefs) => prefs.getString('userId'));
    if (userId == null) {
      if (mounted) {
        showCustomSnackbar(context, 'User ID not found. Cannot save activity.');
      }
      return;
    }

    String? apiActivityId;
    switch (widget.activityType) {
      case 'Walking':
        apiActivityId = widget.activityId;
        break;
      case 'Running':
        apiActivityId = widget.activityId;
        break;
      case 'Cycling':
        apiActivityId = widget.activityId;
        break;
      default:
        if (mounted) {
          showCustomSnackbar(context, 'Unknown activity type: ${widget.activityType}');
        }
        return;
    }

    if (apiActivityId.isEmpty) {
      if (mounted) {
        showCustomSnackbar(context, 'Activity ID for ${widget.activityType} not found in profile.');
      }
      return;
    }
    final activityToSave = ActivityData(
      activityId: apiActivityId,
      activityName: widget.activityType,
      userId: userId,
      sourceLat: _sourceLat,
      sourceLng: _sourceLng,
      destinationLat: _destinationLat,
      destinationLng: _destinationLng,
      timeTaken: formattedDuration,
      distance: finalDistanceKm.toStringAsFixed(3),
      avgPace: finalAvgPace,
      overSpeeding: _overSpeedingCount > 0 ? "true" : "false",
      caloriesBurned: finalCaloriesBurned,
      elevationGain: formattedElevation,
    );

    if (mounted) {
      context.read<ActivityBloc>().add(AddActivity(activityToSave));
      await _handleRewardLogic(finalActualDistance: finalDistanceKm);
    }
  }

  Future<void> _handleRewardLogic({required double finalActualDistance}) async {
    try {
      if (widget.activityType == "Walking") {
        final value = await widget.activityRepo.getDailyWalkRecommendation(
          actualDistance: finalActualDistance,
        );
        log("coind today : ${value.coinsAwardedToday} : ${value.toString()}");
        await _showCoinsAwardedDialog(value.coinsAwardedToday, value.popupRequired);
      } else if (widget.activityType == "Running") {
        final value = await widget.activityRepo.getDailyRunRecommendation(
          actualDistance: finalActualDistance,
        );
        await _showCoinsAwardedDialog(value.coinsAwardedToday, value.popupRequired);
      } else if (widget.activityType == "Cycling") {
        final value = await widget.activityRepo.getDailyCyclingRecommendation(
          actualDistance: finalActualDistance,
        );
        await _showCoinsAwardedDialog(value.coinsAwardedToday, value.popupRequired);
      }
    } catch (e) {
      log("Reward logic error: $e");
    }
  }

  Future<void> _showCoinsAwardedDialog(int coinsAwarded, bool popup) async {
    if (!mounted) return;

    if (coinsAwarded == 0) {
      await showGoalRestrictionPopup(context, distanceGoal.toString()); // Add `await`
    } else {
      await showDialog(
        // Add `await`
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("🎉 Congratulations!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset("assets/images/coin1.png"),
              ),
              const SizedBox(height: 12),
              const Text("You have been awarded"),
              const SizedBox(height: 8),
              Text(
                "$coinsAwarded ${coinsAwarded < 10 ? "Coin" : "Coins"}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kPrimaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }

  String _formatPace(double distanceKm, int durationSeconds) {
    if (distanceKm <= 0 || durationSeconds <= 0) return "0.00";
    double paceMinutesPerKm = (durationSeconds / 60.0) / distanceKm;
    return paceMinutesPerKm.toStringAsFixed(2);
  }

  void incrementGoalDistance() {
    setState(() => distanceGoal += 0.5);
  }

  void decrementGoalDistance() => setState(() {
        if (widget.distanceGoal == 0 || widget.distanceGoal == 0.0) {
          if (distanceGoal > 0.5) distanceGoal -= 0.5;
        } else {
          if (distanceGoal > widget.distanceGoal) {
            distanceGoal -= 0.5;
          } else {
            showGoalRestrictionPopup(context, distanceGoal.toString());
          }
        }
      });

  @override
  void dispose() {
    _activityTimer?.cancel();
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> showGoalRestrictionPopup(BuildContext context, String distanceGoal) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.kWhite, // dark background
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Increase Goal",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Kindly increase your goal to more than ${widget.distanceGoal} Km if you want to take part in the Fit First monthly rewards program and earn additional points on maintaining monthly streaks",
                  style: TextStyle(
                    color: AppColors.kBlack,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        text: "Cancel",
                        borderRadius: BorderRadius.circular(15),
                        backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Update user marker on map based on LocationBloc updates if map is visible and activity not started
    // This handles initial location updates before session starts
    final currentMarkers = Set<Marker>.from(_markers);

    if (_userMarker != null) {
      currentMarkers.removeWhere((m) => m.markerId.value == 'user_location'); // Remove old one if any
      currentMarkers.add(_userMarker!); // Add current one
    }

    return BlocListener<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivityLoading) {
          showCustomSnackbar(context, 'Saving activity...');
        } else if (state is ActivityAddedSuccess) {
          showCustomSnackbar(context, state.response.message);
        } else if (state is ActivityOperationFailure) {
          showCustomSnackbar(context, 'Error: ${state.error}');
        }
      },
      child: Scaffold(
        appBar: CommonAppBar(),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _currentIndex == 0
              ? Column(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: BlocListener<LocationBloc, AppLocationState.LocationState>(
                        listener: (context, locState) {
                          if (locState is AppLocationState.LocationLoaded && !isStarted && mounted) {
                            final newCenter = LatLng(locState.latitude, locState.longitude);
                            _updateUserMarker(newCenter);
                            if (_mapController != null) {
                              _mapController!.animateCamera(CameraUpdate.newLatLngZoom(newCenter, 15.0));
                            } else {
                              // If map not created yet, update initial center for when it is
                              setState(() {
                                _initialMapCenter = newCenter;
                              });
                            }
                          }
                        },
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _initialMapCenter ?? const LatLng(0, 0), // Default if still null
                            zoom: 15.0,
                          ),
                          markers: currentMarkers, // Use the dynamic set
                          polylines: _polylines,
                          myLocationEnabled: false, // Using custom marker
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          buildingsEnabled: false, // ADD THIS LINE TO FIX FLOATING POLYLINES
                          padding: const EdgeInsets.only(bottom: 20),
                        ),
                      ),
                    ),
                    Expanded(child: isStarted ? _buildInProgressUI(context) : _buildGoalUI(context)),
                  ],
                )
              : HistoryScreen(),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isStarted
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                          ),
                          onPressed: _isStopping
                              ? null
                              : () async {
                                  setState(() => _isStopping = true);
                                  await _stopSession(); // reward logic is inside this
                                  if (mounted) setState(() => _isStopping = false);
                                },
                          child: _isStopping
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Stop',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        )),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                        ),
                        onPressed: _startSession,
                        child: const Text(
                          'Start',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalUI(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24), // Reduced from 54
          Expanded( // Wrap in Expanded to take available space
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.yourGoal,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle, size: 36, color: Colors.grey),
                            onPressed: decrementGoalDistance,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              distanceGoal.toStringAsFixed(1),
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 36, color: Colors.grey),
                            onPressed: incrementGoalDistance,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(widget.activityIcon, size: 20, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(widget.activityType, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16), // Reduced from 18
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<ActivitySubCategoryBloc>().add(
                                      LoadSubCategories(activityId: widget.activityId, activityType: 'Nutrition'),
                                    );
                                CustomSmoothNavigator.push(
                                  context,
                                  NutritionScreen(activityId: widget.activityId, activityType: 'Nutrition'),
                                );
                              },
                              icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                              label: const Text('Nutrition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 14
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<ActivitySubCategoryBloc>().add(
                                      LoadSubCategories(activityId: widget.activityId, activityType: 'Gear'),
                                    );
                                CustomSmoothNavigator.push(
                                  context,
                                  GearScreen(activityId: widget.activityId, activityType: 'Gear'),
                                );
                              },
                              icon: const Icon(Icons.sports_martial_arts, color: Colors.white),
                              label: const Text('Gears', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 14
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14), // Bottom padding, reduced from 20
        ],
      ),
    );
  }

  Widget _buildInProgressUI(BuildContext context) {
    double progressValue = 0.0;
    if (goalType == 'Distance' && distanceGoal > 0) {
      progressValue = (_liveGpsDistanceKm / distanceGoal).clamp(0.0, 1.0);
    }

    String formattedDistance = _liveGpsDistanceKm.toStringAsFixed(3);
    String formattedCalories = _liveCalculatedCaloriesBurned;
    String formattedPace = _avgPace;
    String formattedElevation = _totalElevationGain.toStringAsFixed(1);

    // Combine all stat cards into a single list
    final statCards = [
      _StatCard(
        icon: Icons.timer,
        label: 'Duration',
        value: _formatDuration(_durationSeconds),
        color: Colors.blue,
      ),
      _StatCard(
        icon: Icons.location_on,
        label: 'Distance',
        value: '$formattedDistance km',
        color: Colors.orange,
      ),
      _StatCard(
        icon: Icons.local_fire_department,
        label: 'Calories',
        value: '$formattedCalories kcal',
        color: Colors.red,
      ),
      _StatCard(
        icon: Icons.speed,
        label: 'Pace',
        value: '$formattedPace km',
        color: Colors.green,
      ),
      _StatCard(
        icon: Icons.height,
        label: 'Elevation',
        value: '$formattedElevation m',
        color: Colors.purple,
      ),
      _StatCard(
        icon: Icons.warning,
        label: 'Overspeeding',
        value: _overSpeedingCount.toString(),
        color: Colors.amber,
      ),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.activityType.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primary,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progressValue * 100).toStringAsFixed(0)} %',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    if (goalType == 'Distance')
                      Text(
                        'of ${distanceGoal.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            /// ✅ Grid of stat cards (2 per row)
            StatCardGrid(cards: statCards),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex, // Use _currentIndex here
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Start'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
      onTap: (index) {
        if (!isStarted) {
          // Prevent switching tabs if an activity is in progress
          setState(() => _currentIndex = index);
        } else {
          showCustomSnackbar(context, "Please stop the current activity before switching tabs.");
        }
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class StatCardGrid extends StatelessWidget {
  final List cards;

  const StatCardGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2, // adjust for your desired card shape
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }
}
