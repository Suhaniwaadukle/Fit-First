import 'package:equatable/equatable.dart';

abstract class ConnectivityState extends Equatable {
  final bool isConnected;
  const ConnectivityState(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial() : super(true);
}

class ConnectivitySuccess extends ConnectivityState {
  const ConnectivitySuccess(super.isConnected);

  @override
  List<Object> get props => [isConnected];
}