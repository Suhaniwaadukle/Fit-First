import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchLocationEvent extends LocationEvent {}

class GetImmediateLocationEvent extends LocationEvent {}

class LoadSavedLocationEvent extends LocationEvent {}

class UpdateLocationEvent extends LocationEvent {
  final double latitude;
  final double longitude;

  UpdateLocationEvent(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class FetchPartnerLocationsEvent extends LocationEvent {} // New event
