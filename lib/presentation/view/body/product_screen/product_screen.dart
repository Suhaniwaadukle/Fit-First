import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/data/models/product_model/prodcut_model.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart';
import 'package:orka_sports/presentation/blocs/product/product_bloc.dart';
import 'package:orka_sports/presentation/blocs/product/product_event.dart';
import 'package:orka_sports/presentation/blocs/product/product_state.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:orka_sports/presentation/view/body/product_screen/product_details_screen.dart';

class ProductScreen extends StatefulWidget {
  final String partnerId;
  final String subcategoryId;

  const ProductScreen({
    super.key,
    required this.partnerId,
    required this.subcategoryId,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ProductBloc(ActivityRepository()); // Initialize the bloc
    // Add event to load products when the screen initializes
    _bloc.add(
      LoadProductsByPartner(
        partnerId: widget.partnerId,
        subcategoryId: widget.subcategoryId,
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close(); // Dispose the bloc
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // Provide the bloc to the widget tree
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text("Products"), centerTitle: true),
        body: BlocBuilder<ProductBloc, ProductState>(
          // Build UI based on bloc state
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductLoaded) {
              if (state.products.isEmpty) {
                return const Center(
                  child: Text('No products found for this partner.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return _buildProductListItem(
                    context,
                    product,
                  ); // Pass context here
                },
              );
            } else if (state is ProductError) {
              return Center(child: Text(state.message));
            }
            // Initial state or other states could return a placeholder
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Method to build a single product item widget
  Widget _buildProductListItem(BuildContext context, ProductModel productModel) {
    // Accept context
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        // Wrap with InkWell for tap detection and ripple effect
        onTap: () {
          CustomSmoothNavigator.push(
            context,
            ProductDetailsScreen(
              partnerId: widget.partnerId,
              subCategoryId: widget.subcategoryId,
              productModel: productModel,
              productName: productModel.productName ?? '',
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Container(
                  // Wrap image in Container for placeholder background
                  width: 120,
                  height: 80,
                  color: Colors.grey[200], // Placeholder background color
                  child: productModel.imageFullPath!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: productModel.fullImageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ), // Fallback if no image URL
                ),
              ),
              const SizedBox(width: 12), // Spacing between image and text
              // Product Details
              Expanded(
                // Use Expanded to allow text column to take remaining space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      productModel.itemName ??
                          productModel.productName ??
                          'Unnamed Product', // Use itemName, fallback to productName
                      style: AppTextStyles.title.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Text(
                      '${productModel.price ?? productModel.productPrice ?? 'N/A'} ${productModel.priceType ?? ''}', // Use price, fallback to productPrice
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ), // Highlight price
                    ),
                    const SizedBox(height: 4),

                    // Size/Flavor (Optional)
                    if ((productModel.size != null && productModel.size!.isNotEmpty) ||
                        (productModel.flavor != null && productModel.flavor!.isNotEmpty))
                      Text(
                        '${productModel.size ?? ''} ${productModel.flavor ?? ''}'
                            .trim(), // Display size and flavor if available
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // You can add more details here like stock, discount, etc.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
