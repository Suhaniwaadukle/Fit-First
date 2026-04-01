import 'package:orka_sports/data/models/partner_model/partner_model.dart';
import 'package:equatable/equatable.dart';

abstract class PartnersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PartnersInitial extends PartnersState {}

class PartnersLoading extends PartnersState {}

class PartnersLoaded extends PartnersState {
  final List<PartnerModel> partners;
  PartnersLoaded(this.partners);

  @override
  List<Object?> get props => [partners];
}

class PartnersError extends PartnersState {
  final String message;
  PartnersError(this.message);

  @override
  List<Object?> get props => [message];
}