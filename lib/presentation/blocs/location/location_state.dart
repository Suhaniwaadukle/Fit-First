import 'package:equatable/equatable.dart';
import 'package:orka_sports/data/models/location/get_partner_loc_model.dart'; // Import your model

abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final bool isFromAPI;
  final bool? updateSuccess;
  final GetPartnerLocModel? partnerLocations; // New field

  LocationLoaded({
    required this.latitude,
    required this.longitude,
    this.isFromAPI = false,
    this.updateSuccess,
    this.partnerLocations, // Initialize it
  });

  @override
  List<Object?> get props => [latitude, longitude, isFromAPI, updateSuccess, partnerLocations];
}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
