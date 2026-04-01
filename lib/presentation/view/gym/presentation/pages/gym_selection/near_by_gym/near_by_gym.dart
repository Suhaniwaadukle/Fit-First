import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_near_gym_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/search_gym_model.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/near_by_gym/sub_industry_filters.dart';
import 'package:orka_sports/presentation/view/gym/presentation/widgets/gym_card.dart';

class NearbyGymsWidget extends StatelessWidget {
  final GymEntity gymEntity;
  final GymController gymController;

  final Function(int) onSelect;

  const NearbyGymsWidget({
    super.key,
    required this.onSelect,
    required this.gymEntity,
    required this.gymController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Partner Gyms Near You',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D3436))),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.map), label: const Text('Map View')),
          ],
        ),
        AppSize.kHeight10,
        gymEntity.isSubIndustryLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Loading filters.. "),
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CommonLoadingWidget(),
                  ),
                ],
              )
            : SubIndustryFilterRow(
                subIndustries: gymEntity.getSubIndustryList.data ?? [],
                selectedId: gymEntity.selectedSubIndustryId,
                onSelected: (item) {
                  gymController.onSelectedSubIndustryId(context, value: item.id ?? '');
                },
                gymController: gymController,
                gymEntity: gymEntity,
              ),
        const SizedBox(height: 30),
        gymEntity.isNearGymLoading
            ? CommonLoadingWidget()
            : gymEntity.getNearGymsList.data == null || (gymEntity.getNearGymsList.data?.isEmpty ?? false)
                ? Center(
                    child: Text(gymEntity.getNearGymsList.message ?? ""),
                  )
                : Column(
                    children: List.generate(
                      gymEntity.getNearGymsList.data!.length,
                      (index) {
                        final gym = gymEntity.getNearGymsList.data![index];
                        final isSelected = gymEntity.selectedGymIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => gymController.selectGymIndex(index),
                            child: buildGymCard<NearGymData>(
                                context: context,
                                gym: gym,
                                isSelected: isSelected,
                                getName: (data) => data.name ?? '',
                                getEmail: (data) => data.email ?? '',
                                getPhoneCode: (data) => data.phonecode ?? '',
                                getMobile: (data) => data.mobile ?? '',
                                getImageUrl: (data) => data.partnerImage ?? '',
                                getDistance: (data) => data.distance ?? '',
                                isPartner: (data) => data.partnerImage != null && data.partnerImage!.isNotEmpty,
                                onLeftButtonPressed: () => gymController.onGymDetailsOnTap(context,
                                    type: "Near Gym", partnerId: gym.id ?? '', searchGym: SearchGymData()),
                                onRightButtonPressed: () =>
                                    gymController.onGymBuddyOnTap(context, partnerId: gym.id ?? '')),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
