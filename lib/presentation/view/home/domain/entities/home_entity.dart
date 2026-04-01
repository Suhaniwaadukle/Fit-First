import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:orka_sports/presentation/view/home/data/models/get_allpartners_model.dart';
import 'package:orka_sports/presentation/view/home/data/models/get_allusers_model.dart';

@immutable
class HomeEntity {
  final bool isAllUsersLoading;
  final bool isAllPartnersLoading;
  final GetAllUsersModel? getAllUsersList;     // ✅ Make nullable
  final GetAllPartnersModel? getAllPartnersList; // ✅ Make nullable

  // Map related state
  final Set<Marker> markers;
  final CameraPosition? initialCameraPosition;
  final bool isMapReady;
  final bool isHomeInitialized;

  const HomeEntity({
    required this.isAllUsersLoading,
    required this.isAllPartnersLoading,
    required this.getAllUsersList,
    required this.getAllPartnersList,
    required this.markers,
    required this.initialCameraPosition,
    required this.isMapReady,
    required this.isHomeInitialized,
  });

  factory HomeEntity.initial() {
    return HomeEntity(
      isAllUsersLoading: false,
      isAllPartnersLoading: false,
      getAllUsersList: null,        // ✅ Start with null, not empty object
      getAllPartnersList: null,     // ✅ Start with null, not empty object
      markers: {},
      initialCameraPosition: const CameraPosition(target: LatLng(20.5937, 78.9629)),
      isMapReady: false,
      isHomeInitialized: false,
    );
  }

  HomeEntity copyWith({
    bool? isAllUsersLoading,
    bool? isAllPartnersLoading,
    GetAllUsersModel? getAllUsersList,
    GetAllPartnersModel? getAllPartnersList,
    Set<Marker>? markers,
    CameraPosition? initialCameraPosition,
    bool? isMapReady,
    bool? isHomeInitialized,
  }) {
    return HomeEntity(
      isAllUsersLoading: isAllUsersLoading ?? this.isAllUsersLoading,
      isAllPartnersLoading: isAllPartnersLoading ?? this.isAllPartnersLoading,
      getAllUsersList: getAllUsersList ?? this.getAllUsersList,
      getAllPartnersList: getAllPartnersList ?? this.getAllPartnersList,
      markers: markers ?? this.markers,
      initialCameraPosition: initialCameraPosition ?? this.initialCameraPosition,
      isMapReady: isMapReady ?? this.isMapReady,
      isHomeInitialized: isHomeInitialized ?? this.isHomeInitialized,
    );
  }
}
