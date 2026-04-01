import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/gym/data/models/search_gym_model.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';
import 'package:orka_sports/presentation/view/gym/presentation/widgets/gym_card.dart';

class ExistingGymWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCheckPartnership;
  final GymEntity gymEntity;
  final GymController gymController;

  const ExistingGymWidget({
    super.key,
    required this.controller,
    required this.onCheckPartnership,
    required this.gymEntity,
    required this.gymController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your gym name',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE3E8EB),
            ),
          ),
          child: CustomTextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Search for your gym...',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (val) {
              gymController.onSearchGymValidation();
            },
            validator: (p0) {
              return null;
            },
            keyboard: TextInputType.name,
          ),
        ),
        const SizedBox(height: 24),
        gymEntity.isSearchGymLoading
            ? CommonLoadingWidget()
            : gymEntity.searchGymList.data == null || (gymEntity.searchGymList.data?.isEmpty ?? false)
                ? SizedBox(
                    width: double.infinity,
                    child: ButtonWidget(
                      borderRadius: BorderRadius.circular(15),
                      backgroundColor: gymEntity.isSearchFieldValid
                          ? WidgetStatePropertyAll(
                              AppColors.kPrimaryColor,
                            )
                          : WidgetStatePropertyAll(
                              AppColors.kBlack.withValues(alpha: 0.15),
                            ),
                      text: 'Search',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.kWhite,
                            fontWeight: FontWeight.bold,
                          ),
                      onPressed: gymEntity.isSearchFieldValid ? onCheckPartnership : null,
                    ),
                  )
                : Column(
                    children: List.generate(
                      gymEntity.searchGymList.data!.length,
                      (index) {
                        final gym = gymEntity.searchGymList.data![index];
                        final isSelected = gymEntity.selectedGymIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => gymController.selectGymIndex(index),
                            child: buildGymCard<SearchGymData>(
                                context: context,
                                gym: gym,
                                isSelected: isSelected,
                                getName: (g) => g.name ?? '',
                                getEmail: (data) => data.email ?? '',
                                getPhoneCode: (data) => data.phonecode ?? '',
                                getMobile: (data) => data.mobile ?? '',
                                getImageUrl: (data) => data.partnerImage ?? '',
                                getDistance: (g) => g.distance ?? '',
                                isPartner: (g) => g.partnerImage != null && g.partnerImage!.isNotEmpty,
                                onLeftButtonPressed: () => gymController.onGymDetailsOnTap(
                                      context,
                                      type: "My Gym",
                                      partnerId: gym.id ?? '',
                                      searchGym: gym,
                                    ),
                                onRightButtonPressed: () =>
                                    gymController.onGymBuddyOnTap(context, partnerId: gym.id ?? '')),
                          ),
                        );
                      },
                    ),
                  )
      ],
    );
  }
}
