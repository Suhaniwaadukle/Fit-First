import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';

Widget buildGymCard<T>({
  required BuildContext context,
  required T gym,
  required bool isSelected,
  required String Function(T) getName,
  required String Function(T) getEmail,
  required String Function(T) getPhoneCode,
  required String Function(T) getMobile,
  required String Function(T) getDistance,
  required String Function(T) getImageUrl,
  required bool Function(T) isPartner,
  required void Function()? onLeftButtonPressed,
  required void Function()? onRightButtonPressed,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected ? AppColors.kPrimaryColor : const Color(0xFFE3E8EB),
        width: isSelected ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected ? AppColors.kPrimaryColor.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
          blurRadius: isSelected ? 15 : 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Name + Partner + Image
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getName(gym),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isPartner(gym))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Partner',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                getImageUrl(gym),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// Email
        Row(
          spacing: 10,
          children: [
            Icon(Icons.mail_rounded, size: 16, color: AppColors.kPrimaryColor),
            Text(
              getEmail(gym),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),

        const SizedBox(height: 4),

        /// Phone
        Row(
          spacing: 10,
          children: [
            Icon(Icons.phone, size: 16, color: AppColors.kPrimaryColor),
            Text(
              '${getPhoneCode(gym)} ${getMobile(gym)}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),

        const SizedBox(height: 4),

        /// Distance
        Row(
          spacing: 10,
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.kPrimaryColor),
            Text(getDistance(gym), style: TextStyle(fontSize: 14, color: AppColors.kPrimaryColor)),
          ],
        ),

        const SizedBox(height: 15),

        /// Bottom Buttons if selected
        if (isSelected)
          CommonBottomButtonWidget(
            padding: EdgeInsets.zero,
            leftButtonText: 'Gym Details',
            rightButtonText: 'Gym Buddy',
            leftBackgroundColor: AppColors.kWhite,
            leftBorderColor: AppColors.kPrimaryColor.withValues(alpha: 0.5),
            onLeftButtonPressed: onLeftButtonPressed,
            onRightButtonPressed: onRightButtonPressed,
            isAbsorbing: false,
            isLeftButtonLoading: false,
            isRightButtonLoading: false,
            isRightButtonEnabled: false,
          ),
      ],
    ),
  );
}
