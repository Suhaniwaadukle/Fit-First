import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_listview/common_listview.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:orka_sports/presentation/view/body/product_screen/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ProviderScope.containerOf(context)
            .read(DiProviders.bodyIqControllerProvider.notifier)
            .getProductsByPartner(context);
      },
    );
    super.initState();
  }

  // Helper method to get stored subcategory ID
  String _getStoredSubcategoryId() {
    final prefs = GetItService.getIt<SharedPreferences>();
    return prefs.getString("subCategoryId") ?? '';
  }

  // Navigation method to ProductScreen
  void _navigateToProductScreen(String? partnerId) {
    if (partnerId != null && partnerId.isNotEmpty) {
      final subcategoryId = _getStoredSubcategoryId();
      
      CustomSmoothNavigator.push(
        context,
        ProductScreen(
          partnerId: partnerId,
          subcategoryId: subcategoryId,
        ),
      );
    } else {
      // Show error message if partner ID is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partner information not available'),
          backgroundColor: AppColors.kRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);

        return Scaffold(
          appBar: const CommonAppBar(title: "Partners"),
          body: SafeArea(
            child: bodyIqState.isProductsByPartnerLoading
                ? const CommonLoadingWidget()
                : (bodyIqState.getProductByPartnerModel.data?.isEmpty ?? true)
                    ? CommonErrorWidget(
                        message: bodyIqState.getProductByPartnerModel.message ?? 'No partners found',
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CommonListviewBuilder(
                          itemCount: bodyIqState.getProductByPartnerModel.data?.length ?? 0,
                          separatorBuilder: (context, index) => AppSize.kHeight10,
                          itemBuilder: (context, index) {
                            final partner = bodyIqState.getProductByPartnerModel.data?[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Navigate to ProductScreen with required parameters
                                  _navigateToProductScreen(partner?.id);
                                },
                                borderRadius: BorderRadius.circular(12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: partner?.partnerImage?.isNotEmpty == true
                                            ? CachedNetworkImage(
                                                imageUrl: partner!.partnerImage!,
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
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      partner?.name ?? "Unknown Partner",
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.kBlack,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   "₹${partner?.productPrice ?? "-"}",
                                                  //   style: const TextStyle(
                                                  //     fontWeight: FontWeight.bold,
                                                  //     fontSize: 16,
                                                  //     color: AppColors.kBlack,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              if (partner?.distance != null)
                                                Text(
                                                  'Distance: ${partner?.distance} km',
                                                  style: TextStyle(
                                                    color: AppColors.kBlack.withValues(alpha: 0.5),
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              if (partner?.mobile != null)
                                                // Text(
                                                //   'Phone: ${partner?.mobile}',
                                                //   style: TextStyle(
                                                //     color: AppColors.kBlack.withValues(alpha: 0.5),
                                                //     fontSize: 12,
                                                //   ),
                                                //   maxLines: 1,
                                                //   overflow: TextOverflow.ellipsis,
                                                // ),
                                              const SizedBox(height: 8),
                                              // Add visual indicator for tap
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.kPrimaryColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'Tap to view products',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.kPrimaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
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
                        ),
                      ),
          ),
        );
      },
    );
  }
}
