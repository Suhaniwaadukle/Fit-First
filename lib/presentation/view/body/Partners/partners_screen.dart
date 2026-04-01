// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/partners/partners_bloc.dart';
import 'package:orka_sports/presentation/blocs/partners/partners_event.dart';
import 'package:orka_sports/presentation/blocs/partners/partners_state.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:orka_sports/presentation/view/body/product_screen/product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnersScreen extends StatefulWidget {
  final String userId;
  final String subcategoryId;
  const PartnersScreen({super.key, required this.userId, required this.subcategoryId});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  late PartnersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PartnersBloc(ActivityRepository());
    _bloc.add(LoadPartners(
      userId: widget.userId,
      subcategoryId: widget.subcategoryId,
    ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Partners"),
          centerTitle: true,
        ),
        body: BlocBuilder<PartnersBloc, PartnersState>(
          builder: (context, state) {
            if (state is PartnersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PartnersLoaded) {
              if (state.partners.isEmpty) {
                return const Center(child: Text('No partners found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: state.partners.length,
                itemBuilder: (context, index) {
                  final partner = state.partners[index];
                  return GestureDetector(
                    onTap: () async {
                      final sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setString('partnerNumer', "${partner.phoneCode}${partner.mobile}");
                      CustomSmoothNavigator.push(
                          context,
                          ProductScreen(
                            partnerId: partner.id,
                            subcategoryId: widget.subcategoryId,
                          ));
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: partner.partnerImage.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: partner.partnerImage,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(child: Icon(Icons.business, size: 50, color: Colors.grey)),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Center(child: Icon(Icons.business, size: 50, color: Colors.grey)),
                                    ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.kWhite,
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      partner.name,
                                      style: AppTextStyles.headline.copyWith(
                                        color: AppColors.kBlack,
                                        fontSize: 18,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Distance: ${partner.distance} km',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.kBlack.withValues(alpha: 0.5),
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is PartnersError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
