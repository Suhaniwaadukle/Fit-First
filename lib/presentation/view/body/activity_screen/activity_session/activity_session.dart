import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:lottie/lottie.dart' hide Marker;
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
import 'package:orka_sports/presentation/blocs/location/location_state.dart' as AppLocationState;
import 'package:orka_sports/presentation/view/body/gear_screen/gear_screen.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../history_screen/TaskScreen.dart';
import '../history_screen/history_screen.dart';

class ActivitySessionScreen extends StatefulWidget {
  final String activityType;
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
  final Completer<GoogleMapController> _mapCompleter =
  Completer<GoogleMapController>();
  GoogleMapController? _mapController;
  LatLng? _initialMapCenter;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routeCoordinates = [];
  List<LatLng> _roadSnappedCoordinates = [];
  String _sourceLat = "0.0";
  String _sourceLng = "0.0";
  String _destinationLat = "0.0";
  String _destinationLng = "0.0";
  bool _isPaused = false;
  bool _isPausing = false;
  DateTime? _pauseStartTime;
  int _totalPausedSeconds = 0;
  double _liveGpsDistanceKm = 0.0;
  String _avgPace = "00:00";
  String _liveCalculatedCaloriesBurned = "0.0";
  double _maxSpeed = 0.0;
  int _overSpeedingCount = 0;
  double _totalElevationGain = 0.0;
  double _lastElevation = 0.0;
  double _weight = 70.0;
  bool _isStopping = false;
  StreamSubscription<StepCount>? _stepCountStream;
  bool _goalCompleted = false;

  @override
  void initState() {
    super.initState();
    context.read<ActivityListBloc>().add(LoadActivityList());

    _requestPermissions();
    log('ActivitySessionScreen initialized with activity Id: ${widget.activityId}');
    final locationBlocState = context.read<LocationBloc>().state;
    if (locationBlocState is AppLocationState.LocationLoaded) {
      _initialMapCenter =
          LatLng(locationBlocState.latitude, locationBlocState.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _initialMapCenter!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
        ),
      );
    } else {
      _initialMapCenter = const LatLng(23.2599, 77.4126);
      context.read<LocationBloc>().add(FetchLocationEvent());
    }

    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final weightString = profileState.profile.weight;
      if (weightString != null && weightString.isNotEmpty) {
        _weight = double.tryParse(weightString) ?? 70.0;
        log("User weight set from profile: $_weight kg");
      }
    } else {
      log("Profile not loaded at initState, using default weight: $_weight kg");
    }

    distanceGoal =
    (widget.distanceGoal == 0 || widget.distanceGoal == 0.0)
        ? 3.5
        : widget.distanceGoal;
  }

  Future<void> _requestPermissions() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        if (mounted) {
          showCustomSnackbar(context, "Location service is disabled.");
        }
      }
    }

    loc.PermissionStatus permissionStatus =
    await _locationController.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await _locationController.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        if (mounted) {
          showCustomSnackbar(context, "Location permissions are denied.");
        }
      }
    }

    log("Only location permissions requested. Health Connect disabled.");
    await _locationController.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 2000,
      distanceFilter: 5,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_mapCompleter.isCompleted) {
      _mapCompleter.complete(controller);
    }
    _mapController = controller;
    if (_initialMapCenter != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _initialMapCenter!,
                zoom: 15.0,
              ),
            ),
          );
        }
      });
    }
  }

  void _updateUserMarker(LatLng position) {
    if (!mounted) return;
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'user_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  void _startActivityTimer() {
    _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_isPaused) return;

      setState(() {
        _durationSeconds++;

        int activeSeconds = _durationSeconds - _totalPausedSeconds;

        _avgPace = _liveGpsDistanceKm > 0
            ? _formatPace(_liveGpsDistanceKm, activeSeconds)
            : "0.00";

        _liveCalculatedCaloriesBurned = _calculateCaloriesBurned(
          _liveGpsDistanceKm,
          activeSeconds,
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

  double _calculateCaloriesBurned(
      double distanceKm, int durationSeconds, double weight)
  {
    if (distanceKm <= 0) return 0;
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
      case 'Hiking':
        met = 6.0;
        break;
      default:
        met = 3.5;
    }

    double durationHours = durationSeconds / 3600;
    double calories = met * weight * durationHours;

    return calories;
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

  Future<void> _checkGoalCompletion() async {
    if (!_goalCompleted && _liveGpsDistanceKm >= distanceGoal) {
      setState(() {
        _goalCompleted = true;
      });
      await _stopSession();
      log("Goal completed! Distance: $_liveGpsDistanceKm km / Goal: $distanceGoal km");
      _activityTimer?.cancel();
      _locationSubscription?.cancel();
      _showGoalCompletedDialog();
    }
  }

  Future<void> _showGoalCompletedDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 28, horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '🏆',
                            style: TextStyle(fontSize: 38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Goal Completed!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Amazing work! You crushed your target.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _goalStatChip(
                        icon: Icons.flag_rounded,
                        color: Colors.green,
                        label: 'Goal',
                        value:
                        '${distanceGoal.toStringAsFixed(1)} km',
                      ),
                      Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200),
                      _goalStatChip(
                        icon: Icons.location_on_rounded,
                        color: AppColors.primary,
                        label: 'Covered',
                        value:
                        '${_liveGpsDistanceKm.toStringAsFixed(2)} km',
                      ),
                      Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200),
                      _goalStatChip(
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orange,
                        label: 'Calories',
                        value: '$_liveCalculatedCaloriesBurned kcal',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 24, indent: 20, endIndent: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.activityIcon,
                          size: 17, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        widget.activityType,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            CustomSmoothNavigator.push(
                              context,
                              TaskScreen(
                                activityType: widget.activityType,
                                activityIcon: widget.activityIcon,
                                distanceCovered: _liveGpsDistanceKm,
                                durationFormatted: _formatDuration(_durationSeconds),
                                caloriesBurned: _liveCalculatedCaloriesBurned,
                                avgPace: _avgPace,
                                elevationGain: _totalElevationGain.toStringAsFixed(1),
                                overSpeedingCount: _overSpeedingCount,
                                routeCoordinates: _routeCoordinates,
                                markers: _markers,
                                polylines: _polylines,
                                startLatLng: _initialMapCenter,
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'See Activity',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppColors.primary.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            'Continue Activity',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _goalStatChip({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }

  Future<void> _startSession() async {
    log(">>> START SESSION CALLED for: ${widget.activityType}");
    setState(() {
      isStarted = true;
      _startTime = DateTime.now();
      _durationSeconds = 0;
      _liveGpsDistanceKm = 0.0;
      _routeCoordinates.clear();
      _roadSnappedCoordinates.clear();
      _markers.clear();
      _polylines.clear();
      _avgPace = "00:00";
      _liveCalculatedCaloriesBurned = "0.0";
      _overSpeedingCount = 0;
      _totalElevationGain = 0.0;
      _lastElevation = 0.0;
      _maxSpeed = 0.0;
      _isPaused = false;
      _isPausing = false;
      _pauseStartTime = null;
      _totalPausedSeconds = 0;
      _goalCompleted = false;
    });

    _startActivityTimer();

    try {
      loc.LocationData? currentLocation =
      await _locationController.getLocation();

      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        _sourceLat = currentLocation.latitude!.toString();
        _sourceLng = currentLocation.longitude!.toString();
        final startLatLng =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _routeCoordinates.add(startLatLng);
        _addMarker(startLatLng, "start_marker", "Start Point");
        _updateUserMarker(startLatLng);
        final controller = await _mapCompleter.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: startLatLng,
              zoom: 18,
              tilt: 45,
              bearing: 0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, "Could not get start location: $e");
      }
    }

    const double minMovementThresholdMeters = 5;
    const double minSpeedThresholdKmph = 0.5;

    _locationSubscription = _locationController.onLocationChanged
        .listen((loc.LocationData newLocation) async {
      if (_isPaused) return;

      if (newLocation.latitude != null &&
          newLocation.longitude != null &&
          newLocation.accuracy != null &&
          newLocation.accuracy! <= 20.0 &&
          mounted) {
        final newLatLng =
        LatLng(newLocation.latitude!, newLocation.longitude!);
        final lastLatLng = _routeCoordinates.isNotEmpty
            ? _routeCoordinates.last
            : newLatLng;

        double segmentDistance = Geolocator.distanceBetween(
          lastLatLng.latitude,
          lastLatLng.longitude,
          newLatLng.latitude,
          newLatLng.longitude,
        );

        double currentSpeedKmph = (newLocation.speed != null)
            ? newLocation.speed! * 3.6
            : (segmentDistance / 1000.0) / (1 / 3600);

        if (segmentDistance < minMovementThresholdMeters ||
            currentSpeedKmph < minSpeedThresholdKmph) {
          return;
        }

        _updateUserMarker(newLatLng);

        setState(() {
          // ✅ GPS se live distance update
          _liveGpsDistanceKm += segmentDistance / 1000.0;

          _checkOverspeeding(currentSpeedKmph);

          if (currentSpeedKmph > _maxSpeed) {
            _maxSpeed = currentSpeedKmph;
          }

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

        // ── NEW: check goal after every distance update ────────────────
        _checkGoalCompletion();
        // ─────────────────────────────────────────────────────────────

        if (_routeCoordinates.length % 5 == 0) {
          try {
            final snappedPoints =
            await RoadService.snapToRoads(_routeCoordinates);
            if (mounted) {
              setState(() {
                _roadSnappedCoordinates = snappedPoints;
                _updatePolyline();
              });
            }
          } catch (e) {
            setState(() {
              _roadSnappedCoordinates = List.from(_routeCoordinates);
              _updatePolyline();
            });
          }
        } else {
          _updatePolyline();
        }

        try {
          final controller = await _mapCompleter.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newLatLng,
                zoom: 18,
                tilt: 45,
                bearing: newLocation.heading ?? 0,
              ),
            ),
          );
        } catch (e) {
          log("Camera animate error: $e");
        }
      }
    });
  }

  void _addMarker(LatLng position, String markerId, String title) {
    if (!mounted) return;
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'user_location');
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            markerId == "start_marker"
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        ),
      );
    });
  }

  Future<void> _togglePause() async {
    if (_isPausing) return;
    _isPausing = true;
    setState(() {});

    try {
      if (_isPaused) {
        if (_pauseStartTime != null) {
          _totalPausedSeconds +=
              DateTime.now().difference(_pauseStartTime!).inSeconds;
          _pauseStartTime = null;
        }
        _isPaused = false;
        setState(() {});
        log("Session Resumed | Total paused so far: $_totalPausedSeconds sec");
      } else {
        _pauseStartTime = DateTime.now();
        _isPaused = true;
        setState(() {});
        log("Session Paused at $_pauseStartTime");
      }
    } catch (e) {
      log("Pause/Resume error: $e");
      if (mounted) {
        showCustomSnackbar(context, "Pause/Resume mein error: $e");
      }
    } finally {
      if (mounted) {
        _isPausing = false;
        setState(() {});
      }
    }
  }

  void _updatePolyline() {
    if (!mounted) return;
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

  Future<Map<String, double?>> _fetchHealthData(
      DateTime startTime, DateTime endTime) async {
    log("Skipping health data fetch. Returning fallback values for GPS.");
    return {
      'distance': null,
      'calories': null,
    };
  }

  Future<void> _stopSession() async {
    if (_isPaused && _pauseStartTime != null) {
      _totalPausedSeconds +=
          DateTime.now().difference(_pauseStartTime!).inSeconds;
      _pauseStartTime = null;
    }
    _isPaused = false;
    _stepCountStream?.cancel();
    if (_activityTimer != null && _activityTimer!.isActive) {
      _activityTimer?.cancel();
    }
    _locationSubscription?.cancel();

    final DateTime endTime = DateTime.now();

    try {
      loc.LocationData? finalLocation =
      await _locationController.getLocation();
      if (finalLocation.latitude != null && finalLocation.longitude != null) {
        _destinationLat = finalLocation.latitude!.toString();
        _destinationLng = finalLocation.longitude!.toString();
        final finalLatLng =
        LatLng(finalLocation.latitude!, finalLocation.longitude!);
        if (_routeCoordinates.isNotEmpty &&
            _routeCoordinates.last != finalLatLng) {
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

    int activeDurationSeconds = _durationSeconds - _totalPausedSeconds;
    if (activeDurationSeconds < 0) activeDurationSeconds = 0;

    Map<String, double?> healthMetrics =
    await _fetchHealthData(_startTime!, endTime);
    double? healthDistanceMeters = healthMetrics['distance'];
    double? healthCaloriesKcal = healthMetrics['calories'];

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

    String finalCaloriesBurned;
    if (healthCaloriesKcal != null && healthCaloriesKcal > 0) {
      finalCaloriesBurned = healthCaloriesKcal.toStringAsFixed(1);
      log("Using Health calories: $finalCaloriesBurned kcal");
    } else {
      finalCaloriesBurned = _calculateCaloriesBurned(
        finalDistanceKm,
        activeDurationSeconds,
        _weight,
      ).toStringAsFixed(1);
      log("Using calculated calories: $finalCaloriesBurned kcal");
      if (mounted) {
        showCustomSnackbar(
            context, "Using calculated calories due to health data issue.");
      }
    }

    String finalAvgPace = _formatPace(finalDistanceKm, activeDurationSeconds);
    log("Final pace: $finalAvgPace min/km");

    String formattedDuration = _formatDuration(activeDurationSeconds);
    log("Final duration: $formattedDuration");

    String formattedElevation = _totalElevationGain.toStringAsFixed(1);
    log("Final elevation gain: $formattedElevation m");

    final userId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('userId'));
    if (userId == null) {
      if (mounted) {
        showCustomSnackbar(context, 'User ID not found. Cannot save activity.');
      }
      return;
    }

    String? apiActivityId;
    switch (widget.activityType) {
      case 'Walking':
      case 'Running':
      case 'Cycling':
      case 'Hiking':
        apiActivityId = widget.activityId;
        break;
      default:
        log(">>> activityType value is: '${widget.activityType}'");
        apiActivityId = widget.activityId;
        break;
    }

    if (apiActivityId.isEmpty) {
      if (mounted) {
        showCustomSnackbar(context,
            'Activity ID for ${widget.activityType} not found in profile.');
      }
      return;
    }
    _totalPausedSeconds = 0;

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

  Future<void> _handleRewardLogic(
      {required double finalActualDistance}) async
  {
    try {
      if (widget.activityType == "Walking") {
        final value = await widget.activityRepo.getDailyWalkRecommendation(
          actualDistance: finalActualDistance,
        );
        log("coind today : ${value.coinsAwardedToday} : ${value.toString()}");
        await _showCoinsAwardedDialog(
            value.coinsAwardedToday, value.popupRequired);
      }
      else if (widget.activityType == "Running") {
        final value = await widget.activityRepo.getDailyRunRecommendation(
          actualDistance: finalActualDistance,
        );
        await _showCoinsAwardedDialog(
            value.coinsAwardedToday, value.popupRequired);
      } else if (widget.activityType == "Cycling") {
        final value = await widget.activityRepo.getDailyCyclingRecommendation(
          actualDistance: finalActualDistance,
        );
        await _showCoinsAwardedDialog(
            value.coinsAwardedToday, value.popupRequired);
      }
      else if (widget.activityType == "Hiking") {
        final value = await widget.activityRepo.getDailyHikingRecommendation(
          actualDistance: finalActualDistance,
        );
        await _showCoinsAwardedDialog(
            value.coinsAwardedToday, value.popupRequired);
      }
    }
      catch (e) {
      log("Reward logic error: $e");
    }
  }

  Future<void> _showCoinsAwardedDialog(int coinsAwarded, bool popup) async {
    if (!mounted) return;

    if (coinsAwarded == 0) {
      await showGoalRestrictionPopup(context, distanceGoal.toString());
    } else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    _stepCountStream?.cancel();
    if (_mapCompleter.isCompleted) {
      _mapController?.dispose();
    }
    super.dispose();
  }

  Future<void> showGoalRestrictionPopup(
      BuildContext context, String distanceGoal)
  {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.kWhite,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
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
                        backgroundColor:
                        WidgetStatePropertyAll(AppColors.kPrimaryColor),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          color: AppColors.kWhite,
                          fontWeight: FontWeight.bold,
                        ),
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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Activity",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _currentIndex == 0
              ? Column(
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: BlocListener<LocationBloc,
                    AppLocationState.LocationState>(
                  listener: (context, locState) {
                    if (locState is AppLocationState.LocationLoaded &&
                        mounted) {
                      final newCenter = LatLng(
                          locState.latitude, locState.longitude);
                      _updateUserMarker(newCenter);
                      if (_mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(newCenter, 15.0),
                        );
                      } else {
                        setState(() {
                          _initialMapCenter = newCenter;
                        });
                      }
                    }
                  },
                  child: _initialMapCenter != null
                      ? GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _initialMapCenter!,
                      zoom: 15.0,
                    ),
                    markers: Set<Marker>.from(_markers),
                    polylines: Set<Polyline>.from(_polylines),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    buildingsEnabled: false,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                    padding: const EdgeInsets.only(bottom: 8),
                  )
                      : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text("Fetching location..."),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: isStarted
                    ? _buildInProgressUI(context)
                    : _buildGoalUI(context),
              ),
            ],
          )
              : HistoryScreen(activityType: widget.activityType),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentIndex == 0)
              isStarted
                  ? Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(.35),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: _isStopping
                        ? null
                        : () async {
                      setState(() => _isStopping = true);
                      await _stopSession();
                      if (mounted) {
                        setState(() => _isStopping = false);
                      }
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
                      "Stop",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(.35),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _startSession,
                    child: const Text(
                      'Start',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
    String lottiePath = "assets/Lottie/Running.json";

    if (widget.activityType.toLowerCase().contains("cycling")) {
      lottiePath = "assets/Lottie/Cycling.json";
    } else if (widget.activityType.toLowerCase().contains("hiking")) {
      lottiePath = "assets/Lottie/Hiking.json";
    } else if (widget.activityType.toLowerCase().contains("walking")) {
      lottiePath = "assets/Lottie/Walking.json";
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Lottie.asset(
              lottiePath,
              repeat: true,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black.withOpacity(.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.yourGoal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              size: 40,
                              color: Colors.grey,
                            ),
                            onPressed: decrementGoalDistance,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 28),
                            child: Text(
                              distanceGoal.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              size: 40,
                              color: Colors.grey,
                            ),
                            onPressed: incrementGoalDistance,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(widget.activityIcon,
                                size: 18, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              widget.activityType,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<ActivitySubCategoryBloc>().add(
                                  LoadSubCategories(
                                    activityId: widget.activityId,
                                    activityType: 'Nutrition',
                                  ),
                                );

                                CustomSmoothNavigator.push(
                                  context,
                                  NutritionScreen(
                                    activityId: widget.activityId,
                                    activityType: 'Nutrition',
                                  ),
                                );
                              },
                              icon: const Icon(Icons.restaurant_menu),
                              label: const Text(
                                'Nutrition',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<ActivitySubCategoryBloc>().add(
                                  LoadSubCategories(
                                    activityId: widget.activityId,
                                    activityType: 'Gear',
                                  ),
                                );

                                CustomSmoothNavigator.push(
                                  context,
                                  GearScreen(
                                    activityId: widget.activityId,
                                    activityType: 'Gear',
                                  ),
                                );
                              },
                              icon: const Icon(Icons.sports_martial_arts),
                              label: const Text(
                                'Gears',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.activityType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progressValue * 100).toStringAsFixed(0)} %',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (goalType == 'Distance')
                        Text(
                          'of ${distanceGoal.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                _buildStatCell(
                  icon: Icons.location_on,
                  iconColor: Colors.orange,
                  value: formattedDistance,
                  label: 'km',
                ),
                const SizedBox(width: 20),
                _buildStatCell(
                  icon: Icons.timer,
                  iconColor: Colors.blue,
                  value: _formatDuration(_durationSeconds),
                  label: 'Duration',
                  isLarge: true,
                ),
                const SizedBox(width: 18),
                _buildStatCell(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.red,
                  value: formattedCalories,
                  label: 'Cal',
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                _buildStatCell(
                  icon: Icons.speed,
                  iconColor: Colors.green,
                  value: formattedPace,
                  label: 'min/km',
                ),
                const SizedBox(width: 18),
                _buildStatCell(
                  icon: Icons.height,
                  iconColor: Colors.purple,
                  value: '$formattedElevation m',
                  label: 'Elevation',
                ),
                const SizedBox(width: 18),
                _buildStatCell(
                  icon: Icons.warning,
                  iconColor: Colors.amber,
                  value: _overSpeedingCount.toString(),
                  label: 'Overspeed',
                ),
              ],
            ),
            const SizedBox(height: 35),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _isPaused
                    ? Colors.orange.withOpacity(0.08)
                    : Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPaused
                      ? Colors.orange.withOpacity(0.35)
                      : Colors.green.withOpacity(0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isPaused
                          ? Colors.orange.withOpacity(0.18)
                          : Colors.green.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPaused ? Icons.pause_circle : Icons.favorite,
                      color: _isPaused ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPaused
                              ? '⏸ Activity Paused'
                              : '💡 Did You Know?',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black45,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isPaused
                              ? 'Taking short pauses during workouts helps muscles recover and prevents fatigue.'
                              : 'Regular exercise reduces stress hormones like cortisol.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isStarted)
                    GestureDetector(
                      onTap: _isPausing ? null : _togglePause,
                      child: Container(
                        height: 50,
                        width: 50,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.withOpacity(.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isPausing
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Icon(
                            _isPaused
                                ? Icons.play_arrow
                                : Icons.pause,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCell({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    bool isLarge = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 35 : 22,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: isLarge ? 33 : 20),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Start'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
      onTap: (index) {
        if (!isStarted) {
          setState(() => _currentIndex = index);
        } else {
          showCustomSnackbar(context,
              "Please stop the current activity before switching tabs.");
        }
      },
    );
  }
}