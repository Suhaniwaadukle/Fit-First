import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';

class CoachDetailScreen extends StatelessWidget {
  const CoachDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer(builder: (context, ref, child) {
      final gymState = ref.watch(DiProviders.gymControllerProvider);
      final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);
      final coach = gymState.getCoachesDetails.data?.coachInfo;
      final availability = gymState.getCoachesDetails.data?.availability;

      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CommonAppBar(
          title: "Coach Details",
          titleStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        body: gymState.isCoachesDetailsLoading
            ? CommonLoadingWidget()
            : gymState.getCoachesDetails.status == "error"
                ? Center(
                    child: Text(gymState.getCoachesDetails.message ?? ""),
                  )
                : RefreshIndicator.adaptive(
                    onRefresh: () {
                      return gymProvider.getCoachesDetails(context);
                    },
                    child: SingleChildScrollView(
                      padding: AppPaddings.backgroundPAll,
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: CircleAvatar(
                              backgroundColor: AppColors.kWhite,
                              radius: 60,
                              child: Image.network(
                                coach?.profilePhoto ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            coach?.fullName ?? 'N/A',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${coach?.experienceYears ?? "0"} Years Experience',
                            style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coach?.countryName ?? '',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          CommonContainerWithBorder(
                            radius: 10,
                            child: Column(
                              children: [
                                _infoRow("Gender", coach?.gender),
                                _infoRow("DOB", coach?.dob),
                                _infoRow("Contact Number", coach?.contactNumber),
                                _infoRow("Address", coach?.address),
                                _infoRow("Levels", coach?.levels),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Availability",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...availability?.map((slot) => Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot.dayOfWeek ?? '',
                                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${slot.fromTime ?? ''} – ${slot.toTime ?? ''}',
                                              style: textTheme.bodyMedium,
                                            ),
                                            Text(
                                              slot.slot ?? '',
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(fontWeight: FontWeight.w500, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          slot.addressArea ?? '',
                                          style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  )) ??
                              [],
                        ],
                      ),
                    ),
                  ),
      );
    });
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
