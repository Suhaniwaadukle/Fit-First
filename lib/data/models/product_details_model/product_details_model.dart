class ProductDetailsModel {
  final List<String> itemId;
  final String productName;
  final String productSubCategoryId;
  final List<String> productWeight;
  final List<String> productVariant;
  final List<String> productPrice;
  final List<ProductImageModel> productImage;

  ProductDetailsModel({
    required this.itemId,
    required this.productName,
    required this.productSubCategoryId,
    required this.productWeight,
    required this.productVariant,
    required this.productPrice,
    required this.productImage,
  });

  // factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
  //   return ProductDetailsModel(
  //     itemId: json['item_id'] ?? '',
  //     productName: json['product_name'] ?? '',
  //     productSubCategoryId: json['product_sub_category_id'] ?? '',
  //     productWeight: List<String>.from(json['product_weight'] ?? []),
  //     productVariant: List<String>.from(json['product_variant'] ?? []),
  //     productPrice: List<String>.from(json['product_price'] ?? []),
  //     productImage: (json['product_image'] as List).map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>)).toList(),
  //   );
  // }
  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
  return ProductDetailsModel(
    itemId: (json['item_id'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    productName: json['product_name'] ?? '',
    productSubCategoryId: json['product_sub_category_id'] ?? '',
    productWeight: (json['product_weight'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    productVariant: (json['product_variant'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    productPrice: (json['product_price'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    productImage: (json['product_image'] as List<dynamic>?)
            ?.map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
} 


class ProductImageModel {
  final String file;
  final String url;

  ProductImageModel({
    required this.file,
    required this.url,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      file: json['file'] ?? '',
      url: json['url'] ?? '',
    );
  }
}