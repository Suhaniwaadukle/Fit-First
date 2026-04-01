import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';

class CoachListScreen extends StatelessWidget {
  const CoachListScreen({
    super.key,
    required this.gymController,
    required this.gymEntity,
  });

  final GymController gymController;
  final GymEntity gymEntity;

  @override
  Widget build(BuildContext context) {
    final coaches = gymEntity.getCoachesList.data ?? [];

    return CommonContainerWithBorder(
      radius: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Top Coaches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          /// Loader
          if (gymEntity.isCoachesListLoading) ...[
            const Center(child: CircularProgressIndicator()),
          ]

          /// Empty State
          else if (coaches.isEmpty) ...[
            Center(child: Text(gymEntity.getCoachesList.message ?? 'No coaches available')),
          ]

          /// List or Preview
          else ...[
            if (coaches.length <= 4)

              /// Show entire list if 4 or less
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: coaches.length,
                itemBuilder: (ctx, index) {
                  final coach = coaches[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(coach.profilePhoto ?? ''),
                    ),
                    title: Text(coach.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${coach.experienceYears ?? '0'} Years Experience'),
                    onTap: () {
                      gymController.onCoachesDetailScreen(context, coachId: coach.id ?? '');
                    },
                  );
                },
              )
            else ...[
              /// If isShowAllCoaches is false -> show first 4 with stacked preview
              if (!gymEntity.isShowAllCoaches)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 60,
                        child: Stack(
                          children: List.generate(4, (index) {
                            final coach = coaches[index];
                            return Positioned(
                              left: index * 35,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(coach.profilePhoto ?? ''),
                                backgroundColor: Colors.grey[200],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => gymController.onShowAllCoaches(),
                        child: const Text(
                          'View More',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                /// Show full list when expanded
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: coaches.length,
                  itemBuilder: (ctx, index) {
                    final coach = coaches[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(coach.profilePhoto ?? ''),
                      ),
                      title: Text(coach.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${coach.experienceYears ?? '0'} Years Experience'),
                      onTap: () {
                        gymController.onCoachesDetailScreen(context, coachId: coach.id ?? '');
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => gymController.onShowAllCoaches(),
                    child: const Text(
                      'View Less',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
