import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart' as loc;
import 'package:orka_sports/data/repositories/location_service.dart';
import 'package:orka_sports/data/repositories/profile_repository.dart'; // Import ProfileRepository
import 'location_event.dart';
import 'location_state.dart';
import 'dart:developer';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final loc.Location locationController;
  final LocationService locationService;
  // final ProfileRepository _profileRepository; // Add ProfileRepository

  LocationBloc({
    required this.locationController,
    LocationService? locationService,
    ProfileRepository? profileRepository, // Add to constructor
  })  : locationService = locationService ?? LocationService(),
        // _profileRepository = profileRepository ?? ProfileRepository(), // Initialize
        super(LocationInitial()) {
    on<FetchLocationEvent>(_fetchCurrentLocation);
    on<UpdateLocationEvent>(_updateLocationOnMap);
    on<GetImmediateLocationEvent>(_locateMe);
    on<LoadSavedLocationEvent>(_loadSavedLocation);
    on<FetchPartnerLocationsEvent>(_fetchPartnerLocations); // New event handler
  }

  Future<void> _fetchCurrentLocation(FetchLocationEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading());

    try {
      // First try to load saved location from API
      final savedLocation = await locationService.getUserLocation();
      if (savedLocation != null) {
        // Also fetch partner locations
        final partnerLocs = await locationService.getPartnerLocations();
        emit(LocationLoaded(
          latitude: savedLocation['latitude']!,
          longitude: savedLocation['longitude']!,
          isFromAPI: true,
          partnerLocations: partnerLocs, // Pass partner locations
        ));
        return;
      }

      // If no saved location, get current location
      await _getCurrentLocationAndUpdate(emit);
    } catch (e) {
      log('Error in _fetchCurrentLocation: $e');
      emit(LocationError("Failed to fetch location: ${e.toString()}"));
    }
  }

  Future<void> _updateLocationOnMap(UpdateLocationEvent event, Emitter<LocationState> emit) async {
    // When updating location manually, refetch partners to ensure data is fresh
    final partnerLocs = await locationService.getPartnerLocations();
    emit(LocationLoaded(
      latitude: event.latitude,
      longitude: event.longitude,
      isFromAPI: false,
      partnerLocations: partnerLocs, // Pass partner locations
    ));
  }

  Future<void> _locateMe(GetImmediateLocationEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading());
    await _getCurrentLocationAndUpdate(emit);
  }

  Future<void> _loadSavedLocation(LoadSavedLocationEvent event, Emitter<LocationState> emit) async {
    emit(LocationLoading());

    try {
      final savedLocation = await locationService.getUserLocation();
      if (savedLocation != null) {
        final partnerLocs = await locationService.getPartnerLocations();
        emit(LocationLoaded(
          latitude: savedLocation['latitude']!,
          longitude: savedLocation['longitude']!,
          isFromAPI: true,
          partnerLocations: partnerLocs, // Pass partner locations
        ));
      } else {
        emit(LocationError("No saved location found"));
      }
    } catch (e) {
      log('Error in _loadSavedLocation: $e');
      emit(LocationError("Failed to load saved location: ${e.toString()}"));
    }
  }

  Future<void> _fetchPartnerLocations(FetchPartnerLocationsEvent event, Emitter<LocationState> emit) async {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      try {
        final partnerLocs = await locationService.getPartnerLocations();
        emit(LocationLoaded(
          latitude: currentState.latitude,
          longitude: currentState.longitude,
          isFromAPI: currentState.isFromAPI,
          updateSuccess: currentState.updateSuccess,
          partnerLocations: partnerLocs, // Update with new partner locations
        ));
      } catch (e) {
        log('Error fetching partner locations: $e');
        // If there's an error fetching partner locations, keep the current location data
        emit(LocationError("Failed to load partner locations: ${e.toString()}"));
      }
    }
  }

  Future<void> _getCurrentLocationAndUpdate(Emitter<LocationState> emit) async {
    try {
      // Check location service and permission
      bool serviceEnabled = await locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await locationController.requestService();
        if (!serviceEnabled) {
          emit(LocationError("Location service is disabled."));
          return;
        }
      }

      loc.PermissionStatus permissionStatus = await locationController.hasPermission();
      if (permissionStatus == loc.PermissionStatus.denied) {
        permissionStatus = await locationController.requestPermission();
        if (permissionStatus != loc.PermissionStatus.granted) {
          emit(LocationError("Location permissions are denied."));
          return;
        }
      }

      // Get current location
      loc.LocationData locationData = await locationController.getLocation();
      double latitude = locationData.latitude!;
      double longitude = locationData.longitude!;

      // Update location via API
      final updateResult = await locationService.updateLocationAPI(
        latitude,
        longitude,
      );

      // Fetch partner locations after updating user location
      final partnerLocs = await locationService.getPartnerLocations();

      emit(LocationLoaded(
        latitude: latitude,
        longitude: longitude,
        isFromAPI: false,
        updateSuccess: updateResult['success'],
        partnerLocations: partnerLocs, // Pass partner locations
      ));
    } catch (e) {
      log('Error in _getCurrentLocationAndUpdate: $e');
      emit(LocationError("Failed to fetch location: ${e.toString()}"));
    }
  }
}
