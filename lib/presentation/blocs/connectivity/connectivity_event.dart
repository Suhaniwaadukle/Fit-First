import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable{
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class CheckConnectivity extends ConnectivityEvent {}

class UpdateConnectivity extends ConnectivityEvent {
  final bool isConnected;
  const UpdateConnectivity(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}