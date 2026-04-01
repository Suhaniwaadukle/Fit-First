import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/body_iq.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/result_screen/result_screen.dart';

class BodyiqDashboardScreen extends StatefulWidget {
  const BodyiqDashboardScreen({super.key});

  @override
  State<BodyiqDashboardScreen> createState() => _BodyiqDashboardScreenState();
}

class _BodyiqDashboardScreenState extends State<BodyiqDashboardScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final result = ProviderScope.containerOf(context).read(DiProviders.bodyIqControllerProvider.notifier);
        result.getDoshaResult(context);
        result.getLifeStyleResultFn(context);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
        return bodyIqState.isDoshaResultLoading || bodyIqState.isLifeStyleResultLoading
            ? CommonLoadingWidget()
            : bodyIqState.getDoshaResultModel.status == "success" &&
                    bodyIqState.getLifeStyleResultModel.status == "success" &&
                    bodyIqState.getDoshaResultModel.kapha == '0' &&
                    bodyIqState.getDoshaResultModel.pitta == '0' &&
                    bodyIqState.getDoshaResultModel.vata == '0' &&
                    bodyIqState.getLifeStyleResultModel.score == 0
                ? BodyIqScreen()
                : ResultScreen();
      },
    );
  }
}
