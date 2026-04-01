import 'package:equatable/equatable.dart';

abstract class PartnersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPartners extends PartnersEvent {
  final String userId;
  final String subcategoryId;

  LoadPartners({required this.userId, required this.subcategoryId});

  @override
  List<Object?> get props => [userId, subcategoryId];
}