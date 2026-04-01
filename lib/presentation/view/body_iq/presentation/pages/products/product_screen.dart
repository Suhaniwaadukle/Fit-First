import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_listview/common_listview.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/progress_tracker/progress_tracker.dart';

class ProductScreenBodyIq extends StatefulWidget {
  const ProductScreenBodyIq({super.key});

  @override
  State<ProductScreenBodyIq> createState() => _ProductScreenBodyIqState();
}

class _ProductScreenBodyIqState extends State<ProductScreenBodyIq> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        ProviderScope.containerOf(context)
            .read(DiProviders.bodyIqControllerProvider.notifier)
            .onInitRecoProduct(context);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
        final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);
        return Scaffold(
          appBar: CommonAppBar(),
          body: SafeArea(
            child: bodyIqState.isRecoProductsLoading
                ? CommonLoadingWidget()
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Header Card
                          Text('Recommended Products', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          AppSize.kHeight8,
                          Text('Natural products to support your wellness journey',
                              style: TextStyle(color: Colors.grey[600])),
                          SizedBox(height: 16),
                          bodyIqState.getRecoProductModel.status == "error"
                              ? Center(
                                  child: Text(bodyIqState.getRecoProductModel.message ?? ''),
                                )
                              :
                              // Content
                              CommonListviewBuilder(
                                  separatorBuilder: (context, index) {
                                    return AppSize.kHeight15;
                                  },
                                  itemCount: bodyIqState.getRecoProductModel.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    var item = bodyIqState.getRecoProductModel.data?[index];
                                    return InkWell(
                                      onTap: () {
                                        bodyIqProvider.onProductDetailsTap(
                                          context,
                                          product: item,
                                        );
                                      },
                                      child: Row(
                                        spacing: 15,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: item?.image != null && (item?.image?.isNotEmpty ?? false)
                                                  ? Image.network(
                                                      item?.image ?? '',
                                                      height: 100,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: AppColors.kPrimaryColor,
                                                          alignment: Alignment.center,
                                                          child: Icon(
                                                            Icons.image_not_supported,
                                                            color: AppColors.kWhite,
                                                            size: 40,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      height: 100,
                                                      color: AppColors.kPrimaryColor,
                                                      alignment: Alignment.center,
                                                      child: Icon(
                                                        Icons.photo,
                                                        color: AppColors.kWhite,
                                                        size: 40,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bodyIqProvider.formatter.checkValue(
                                                    item?.itemName,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: AppColors.kBlack,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  bodyIqProvider.formatter.checkValue(
                                                    item?.purpose,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: AppColors.kBlack.withValues(
                                                      alpha: 0.7,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
          ),
          bottomNavigationBar: Padding(
            padding: AppPaddings.bottomnavP,
            // child: SizedBox(
            //   width: double.infinity,
            //   child: ButtonWidget(
            //     text: "View Progress Tracking",
            //     borderRadius: BorderRadius.circular(15),
            //     backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
            //     style: Theme.of(
            //       context,
            //     ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
            //     onPressed: () {
            //       CustomSmoothNavigator.push(context, ProgressTrackerScreen());
            //     },
            //   ),
            // ),
          ),
        );
      },
    );
  }
}
