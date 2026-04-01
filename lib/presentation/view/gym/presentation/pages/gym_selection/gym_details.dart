import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_dialogs/common_dialogs.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/gym_coaches/coaches_list.dart';
import 'package:readmore/readmore.dart';

class GymDetailsScreen extends StatelessWidget {
  const GymDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final gymState = ref.watch(DiProviders.gymControllerProvider);
      final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CommonAppBar(
          title: "Gym Details",
          titleStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        body: gymState.isGymDetailsLoading
            ? CommonLoadingWidget()
            : gymState.getGymDetailsList.data == null
                ? Center(
                    child: Text("Sorry! the details of the gym is not available"),
                  )
                : RefreshIndicator.adaptive(
                    onRefresh: () {
                      if (gymProvider.prefs.getString("gymType") == "Near Gym") {
                        return gymProvider.getGymDetails(context);
                      } else {
                        return Future.value();
                      }
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GymImageGallery(
                            gymController: gymProvider,
                            gymEntity: gymState,
                          ),
                          GymCard(
                            child: GymTitleAndDescription(
                              gymController: gymProvider,
                              gymEntity: gymState,
                            ),
                          ),
                          GymCard(
                              child: FacilitiesSection(
                            gymController: gymProvider,
                            gymEntity: gymState,
                          )),
                          GymCard(
                              child: OperatingHoursSection(
                            gymController: gymProvider,
                            gymEntity: gymState,
                          )),
                          GymCard(
                              child: AddressSection(
                            gymController: gymProvider,
                            gymEntity: gymState,
                          )),
                          GymCard(
                              child: ContactSection(
                            gymController: gymProvider,
                            gymEntity: gymState,
                          )),
                        ],
                      ),
                    ),
                  ),
        bottomNavigationBar: Padding(
          padding: AppPaddings.bottomnavP,
          child: SizedBox(
            width: double.infinity,
            child: ButtonWidget(
              borderRadius: BorderRadius.circular(15),
              text: "Join & Setup Schedule",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(
                    color: AppColors.kWhite,
                    fontWeight: FontWeight.bold,
                  ),
              onPressed: () {
                gymProvider.onClearGymCode();
                showCustomDialog(
                  context: context,
                  title: "Enter Code",
                  message: "",
                  content: Consumer(builder: (context, ref, child) {
                    final gymStatePopup = ref.watch(DiProviders.gymControllerProvider);
                    final gymProviderPopUp = ref.read(DiProviders.gymControllerProvider.notifier);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        Text("Please enter your gym code to join!"),
                        CustomTextFormField(
                          controller: gymStatePopup.gymCodeController,
                          hintText: "Type here...",
                          validator: (p0) {
                            return null;
                          },
                          keyboard: TextInputType.text,
                          onChanged: (p0) {
                            gymProvider.onVerifyCodeValid();
                          },
                        ),
                        AppSize.kHeight5,
                        SizedBox(
                          width: double.infinity,
                          child: ButtonWidget(
                            isLoading: gymStatePopup.isVerifyCodeLoading,
                            borderRadius: BorderRadius.circular(15),
                            backgroundColor: gymStatePopup.isVerifyCode
                                ? WidgetStatePropertyAll(
                                    AppColors.kPrimaryColor,
                                  )
                                : WidgetStatePropertyAll(
                                    AppColors.kBlack.withValues(alpha: 0.15),
                                  ),
                            text: "Submit",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.kWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                            onPressed: gymStatePopup.isVerifyCode
                                ? () {
                                    gymProviderPopUp.verifyGymCode(context);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

class GymCard extends StatelessWidget {
  final Widget child;
  const GymCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class GymImageGallery extends StatefulWidget {
  const GymImageGallery({
    super.key,
    required this.gymController,
    required this.gymEntity,
  });

  final GymController gymController;
  final GymEntity gymEntity;

  @override
  State<GymImageGallery> createState() => _GymImageGalleryState();
}

class _GymImageGalleryState extends State<GymImageGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> galleryList = widget.gymEntity.getGymDetailsList.data?.gallery ?? [];

    if (galleryList.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text("No images available")),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: PageView.builder(
            itemCount: galleryList.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final imageUrl = galleryList[index];
              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 220,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            galleryList.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index ? Colors.black : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GymTitleAndDescription extends StatelessWidget {
  const GymTitleAndDescription({super.key, required this.gymController, required this.gymEntity});
  final GymController gymController;
  final GymEntity gymEntity;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gymEntity.getGymDetailsList.data?.name ?? '',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ReadMoreText(
          gymEntity.getGymDetailsList.data?.description ?? '',
          trimLines: 3,
          colorClickableText: AppColors.kPrimaryColor,
          trimMode: TrimMode.Line,
          trimCollapsedText: 'Read more',
          trimExpandedText: 'Read less',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          moreStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.kPrimaryColor,
          ),
          lessStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.kPrimaryColor,
          ),
        ),
        AppSize.kHeight15,
        CoachListScreen(
          gymController: gymController,
          gymEntity: gymEntity,
        ),
      ],
    );
  }
}

class FacilitiesSection extends StatelessWidget {
  const FacilitiesSection({
    super.key,
    required this.gymController,
    required this.gymEntity,
  });

  final GymController gymController;
  final GymEntity gymEntity;

  @override
  Widget build(BuildContext context) {
    final featureString = gymEntity.getGymDetailsList.data?.features ?? '';
    final features = featureString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Facilities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: features.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  feature,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class OperatingHoursSection extends StatelessWidget {
  const OperatingHoursSection({
    super.key,
    required this.gymController,
    required this.gymEntity,
  });

  final GymController gymController;
  final GymEntity gymEntity;

  @override
  Widget build(BuildContext context) {
    final details = gymEntity.getGymDetailsList.data;
    if (details == null) return const SizedBox();

    // Normalize and trim time strings
    final Map<String, String> dailyTimings = {
      'Mon': '${_normalize(details.startTimeMonday)} - ${_normalize(details.endTimeMonday)}',
      'Tue': '${_normalize(details.startTimeTuesday)} - ${_normalize(details.endTimeTuesday)}',
      'Wed': '${_normalize(details.startTimeWednesday)} - ${_normalize(details.endTimeWednesday)}',
      'Thu': '${_normalize(details.startTimeThursday)} - ${_normalize(details.endTimeThursday)}',
      'Fri': '${_normalize(details.startTimeFriday)} - ${_normalize(details.endTimeFriday)}',
      'Sat': '${_normalize(details.startTimeSaturday)} - ${_normalize(details.endTimeSaturday)}',
      'Sun': '${_normalize(details.startTimeSunday)} - ${_normalize(details.endTimeSunday)}',
    };

    // Group consecutive days with same timing
    final Map<String, List<String>> groupedDays = {};
    for (var entry in dailyTimings.entries) {
      groupedDays.update(
        entry.value,
        (days) => [...days, entry.key],
        ifAbsent: () => [entry.key],
      );
    }

    List<Widget> timingWidgets = groupedDays.entries.map((entry) {
      final days = entry.value;
      final timing = entry.key;
      final displayDays = _formatDayRange(days);

      return Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(displayDays, style: const TextStyle(fontSize: 14)),
            Text(timing, style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
    }).toList();

    return Column(
      spacing: 5,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.access_time, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Operating Hours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
        ...timingWidgets,
      ],
    );
  }

  /// Normalize time strings (e.g. "10 AM", "6PM") to a consistent format
  static String _normalize(String? time) {
    final value = (time ?? '').trim().toUpperCase();
    return value.isEmpty ? '-' : value.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Format a list of days as a range (e.g., Mon–Fri) or comma-separated
  String _formatDayRange(List<String> days) {
    if (days.length == 1) return days.first;

    final dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    days.sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));

    final indices = days.map((d) => dayOrder.indexOf(d)).toList();
    for (int i = 0; i < indices.length - 1; i++) {
      if (indices[i + 1] != indices[i] + 1) {
        return days.join(', ');
      }
    }

    return '${days.first}–${days.last}';
  }
}

class AddressSection extends StatelessWidget {
  const AddressSection({super.key, required this.gymController, required this.gymEntity});
  final GymController gymController;
  final GymEntity gymEntity;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(gymEntity.getGymDetailsList.data?.address ?? ''),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 100,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(10.78673000, 76.65479300),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('gym_location'),
                  position: LatLng(10.78673000, 76.65479300),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              liteModeEnabled: true,
            ),
          ),
        ),
      ],
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.gymController, required this.gymEntity});
  final GymController gymController;
  final GymEntity gymEntity;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.phone, size: 24),
        SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Phone: ${gymEntity.getGymDetailsList.data?.phonecode}${gymEntity.getGymDetailsList.data?.mobile}'),
              Text('Email: ${gymEntity.getGymDetailsList.data?.email}'),
              SizedBox(height: 8),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: gymEntity.isRequestGymLoading
              ? CommonLoadingWidget()
              : ElevatedButton.icon(
                  onPressed: () {
                    gymController.requestGymPartner(context);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
        ),
      ],
    );
  }
}
