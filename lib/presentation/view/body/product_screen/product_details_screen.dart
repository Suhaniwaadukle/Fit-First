// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/data/models/product_model/prodcut_model.dart';
import 'package:orka_sports/presentation/blocs/product_details/product_details_event.dart';
import 'package:orka_sports/presentation/blocs/product_details/product_details_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../blocs/product_details/product_details_bloc.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String partnerId;
  final String subCategoryId;
  final String productName;
  final ProductModel productModel;

  const ProductDetailsScreen({
    super.key,
    required this.partnerId,
    required this.subCategoryId,
    required this.productModel,
    required this.productName,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedWeight;
  String? selectedFlavor;
  List<String> availableVariants = [];
  String? selectedImageUrl;
  String? selectedPrice;

  @override
  void initState() {
    context.read<ProductDetailsBloc>().add(
          LoadProductDetails(
            partnerId: widget.partnerId,
            subCategoryId: widget.subCategoryId,
            productName: widget.productName,
          ),
        );
    super.initState();
  }

  // Helper method to determine original price
  String getOriginalPrice() {
    // Try ProductModel fields first
    if (widget.productModel.price != null && widget.productModel.price!.isNotEmpty) {
      return widget.productModel.price!;
    }
    
    if (widget.productModel.productPrice != null && widget.productModel.productPrice!.isNotEmpty) {
      return widget.productModel.productPrice!;
    }
    
    // Calculate from discount percentage if available
    final discountPercentage = double.tryParse(widget.productModel.productDiscountPercentage ?? "0") ?? 0;
    if (discountPercentage > 0) {
      final discountPrice = double.tryParse(selectedPrice ?? "0") ?? 0;
      if (discountPrice > 0) {
        return (discountPrice / (1 - discountPercentage / 100)).toStringAsFixed(2);
      }
    }
    
    // Fallback: Use current price
    return selectedPrice ?? "0";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProductDetailsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is ProductDetailsLoaded) {
            final product = state.products.first;
            final allWeights = product.productWeight.toSet().toList();
            selectedWeight ??= allWeights.first;

            context.read<ProductDetailsBloc>().add(
                  LoadVariantsByWeight(
                    partnerId: widget.partnerId,
                    subCategoryId: widget.subCategoryId,
                    productName: widget.productName,
                    productWeight: selectedWeight!,
                  ),
                );

            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductVariantsByWeightLoaded) {
            final variants = state.variants;
            final allWeights = state.allWeights;

            // ✅ CORRECTED: Filter out null/empty variants FIRST
            availableVariants = variants
                .where((variant) => 
                    variant.variant != null && 
                    variant.variant!.trim().isNotEmpty
                )
                .map((e) => e.variant!)
                .toList();

            // 🔍 DEBUG: Check what we got after filtering
            print("🔍 Filtered availableVariants: $availableVariants");
            print("🔍 availableVariants.length: ${availableVariants.length}");

            if (selectedFlavor == null || !availableVariants.contains(selectedFlavor)) {
              selectedFlavor = availableVariants.isNotEmpty ? availableVariants.first : null;
            }

            final selectedVariant = variants.firstWhere(
              (e) => e.variant == selectedFlavor,
              orElse: () => variants.first,
            );

            selectedImageUrl = selectedVariant.image;
            selectedPrice = selectedVariant.price;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedImageUrl != null && selectedImageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: CachedNetworkImage(
                          imageUrl: selectedImageUrl!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.productModel.productName ?? '',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${selectedPrice ?? '--'}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          AppSize.kHeight10,
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              // ✅ CORRECTED: Button works when no variants are needed OR when flavor is selected
                              onPressed: (availableVariants.isEmpty || selectedFlavor != null)
                                  ? () async {
                                      // 🔍 DEBUG PRINTS ADDED HERE
                                      print("🔍 === PRODUCT MODEL DEBUG ===");
                                      print("🔍 ProductModel.price: ${widget.productModel.price}");
                                      print("🔍 ProductModel.productPrice: ${widget.productModel.productPrice}");
                                      print("🔍 ProductModel.discount: ${widget.productModel.discount}");
                                      print("🔍 ProductModel.productDiscountPercentage: ${widget.productModel.productDiscountPercentage}");
                                      print("🔍 Selected variant price (discount price): $selectedPrice");
                                      print("🔍 === END PRODUCT MODEL DEBUG ===");
                                      
                                      try {
                                        final sharedPreferences = await SharedPreferences.getInstance();
                                        
                                        // Get all required parameters
                                        final userId = sharedPreferences.getString("userId") ?? "";
                                        final partnersMobile = sharedPreferences.getString("partnerNumer") ?? "";
                                        
                                        // Validate required parameters
                                        if (userId.isEmpty) {
                                          throw Exception("User ID not found. Please login again.");
                                        }
                                        
                                        if (partnersMobile.isEmpty) {
                                          throw Exception("Partner contact not found.");
                                        }

                                        // Show loading indicator
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );

                                        // Place order and open WhatsApp
                                        await context.read<ProductDetailsBloc>().placeOrderAndShareOnWhatsApp(
                                          userId: userId,
                                          itemId: widget.productModel.id,
                                          partnersId: widget.productModel.partnersId ?? widget.partnerId,
                                          productSubCategory: widget.productModel.productSubCategoryId ?? widget.subCategoryId,
                                          productName: widget.productModel.productName ?? widget.productModel.itemName ?? '',
                                          productDescription: widget.productModel.description ?? "Premium quality product from Orka Sports",
                                          productRealPrice: getOriginalPrice(),
                                          productDiscountPrice: selectedPrice ?? '0',
                                          productImage: selectedImageUrl ?? widget.productModel.imageFullPath ?? '',
                                          productWeight: selectedWeight ?? widget.productModel.size ?? '',
                                          productVariant: selectedFlavor ?? widget.productModel.flavor ?? '',
                                          partnersMobile: partnersMobile,
                                          productDiscountPercentage: widget.productModel.productDiscountPercentage ?? "0",
                                          phoneNumber: partnersMobile,
                                          status: "Pending",
                                          price: selectedPrice,
                                        );

                                        // Hide loading indicator
                                        Navigator.of(context).pop();

                                        // Show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Order placed successfully! Opening WhatsApp...'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );

                                      } catch (e) {
                                        // Hide loading indicator if it's showing
                                        if (Navigator.canPop(context)) {
                                          Navigator.of(context).pop();
                                        }
                                        
                                        // Show error message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (availableVariants.isEmpty || selectedFlavor != null) 
                                    ? Colors.green 
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              icon: const FaIcon(FontAwesomeIcons.whatsapp),
                              label: const Text('Order by WhatsApp'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Size:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            children: allWeights.map((weight) {
                              final isSelected = weight == selectedWeight;
                              return ChoiceChip(
                                label: Text(
                                  weight,
                                  style: TextStyle(color: isSelected ? AppColors.kWhite : AppColors.kBlack),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.kPrimaryColor,
                                onSelected: (selected) {
                                  setState(() {
                                    selectedWeight = weight;
                                    selectedFlavor = null;
                                    selectedPrice = null;
                                    selectedImageUrl = null;
                                  });
                                  context.read<ProductDetailsBloc>().add(
                                        LoadVariantsByWeight(
                                          partnerId: widget.partnerId,
                                          subCategoryId: widget.subCategoryId,
                                          productName: widget.productName,
                                          productWeight: weight,
                                        ),
                                      );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // ✅ CORRECTED: Only show Flavour/Colour section if there are valid variants
                          if (availableVariants.isNotEmpty) ...[
                            const Text(
                              'Flavour/Colour:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              children: availableVariants.map((flavor) {
                                final isSelected = flavor == selectedFlavor;
                                return ChoiceChip(
                                  label: Text(
                                    flavor,
                                    style: TextStyle(color: isSelected ? AppColors.kWhite : AppColors.kBlack),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.kPrimaryColor,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedFlavor = flavor;
                                      final match = variants.firstWhere(
                                        (v) => v.variant == flavor,
                                        orElse: () => variants.first,
                                      );
                                      selectedPrice = match.price;
                                      selectedImageUrl = match.image;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // ✅ REMOVED: The else block with "No variants available" message
                          AppSize.kHeight10,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No products found'));
        },
      ),
    );
  }
}
