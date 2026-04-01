class WeightVariantModel {
  final String variant;
  final String image;
  final String price;
  final String priceType;
  final String subCategoryId;

  WeightVariantModel({
    required this.variant,
    required this.image,
    required this.price,
    required this.priceType,
    required this.subCategoryId,
  });

  factory WeightVariantModel.fromJson(Map<String, dynamic> json) {
    return WeightVariantModel(
      variant: json['product_variant'] ?? '',
      image: json['product_image'] ?? '',
      price: json['product_price'] ?? '',
      priceType: json['price_type'] ?? '',
      subCategoryId: json['product_sub_category_id'] ?? '',
    );
  }
}
