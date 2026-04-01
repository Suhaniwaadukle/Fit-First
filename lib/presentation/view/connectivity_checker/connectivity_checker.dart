import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_event.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_state.dart';
import 'package:orka_sports/presentation/view/connectivity_checker/no_internet_screen.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';

class ConnectivityChecker extends StatefulWidget {
  final Widget child;
  const ConnectivityChecker({super.key, required this.child});

  @override
  State<ConnectivityChecker> createState() => _ConnectivityCheckerState();
}

class _ConnectivityCheckerState extends State<ConnectivityChecker> {
  bool _wasDisconnected = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state.isConnected) {
          if (_wasDisconnected) {
            _wasDisconnected = false;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            showCustomSnackbar(context, 'Internet connection restored');
          }
        } else {
          if (!_wasDisconnected) {
            _wasDisconnected = true;
            showCustomSnackbar(context, 'No internet connection');
          }
        }
      },
      builder: (context, state) {
        if (!state.isConnected) {
          return NoInternetScreen(
            onRetry: () {
              context.read<ConnectivityBloc>().add(CheckConnectivity());
            },
          );
        }

        return widget.child;
      },
    );
  }
}
