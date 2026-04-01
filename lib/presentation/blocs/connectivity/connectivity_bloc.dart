import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/services/connectivity_services.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_event.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription? _connectivitySubscription;

  ConnectivityBloc({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService,
        super(const ConnectivityInitial()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    on<UpdateConnectivity>(_onUpdateConnectivity);

    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((resultList) async {
      final isDisconnected = resultList.contains(ConnectivityResult.none);

      if (isDisconnected) {
        add(const UpdateConnectivity(false));
      } else {
        // Double-confirm with actual internet
        final hasInternet = await _connectivityService.hasInternetConnection();
        add(UpdateConnectivity(hasInternet));
      }
    });

    add(CheckConnectivity());
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    try {
      final resultList = await _connectivityService.connectivityStatus;
      final isDisconnected = resultList.contains(ConnectivityResult.none);
      final hasInternet = !isDisconnected && await _connectivityService.hasInternetConnection();

      emit(ConnectivitySuccess(hasInternet));
    } catch (e) {
      log('Error in _onCheckConnectivity: $e');
      emit(const ConnectivitySuccess(false));
    }
  }

  Future<void> _onUpdateConnectivity(
    UpdateConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(ConnectivitySuccess(event.isConnected));
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
