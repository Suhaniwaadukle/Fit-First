import 'dart:convert';

class ProductModel {
  final String id;
  final String? brandId;
  final String? productCategoryId;
  final String? productSubCategoryId;
  final String? itemName;
  final String? price;
  final String? stock;
  final String? discount;
  final String? image;
  final String? size;
  final String? flavor;
  final String? description;
  final String? suggestedUs;
  final String? healthNotes;
  final String? specification;
  final String? servingSize;
  final String? servingsPerContainer;
  final String? ingredients;
  final String? createdAt;
  final List<NutritionFact>? nutritionFacts;
  final String? note;
  final String? partnersId;
  final String? itemsId;
  final String? productSubCategory;
  final String? productName;
  final String? productImage;
  final String? productWeight;
  final String? productVariant;
  final String? productDiscountPercentage;
  final String? priceType;
  final String? productPrice;
  final String? metaTitle;
  final String? metaKeyword;
  final String? metaDescription;
  final String? productSlug;
  final String? enabled;
  final String? imageFullPath;

  const ProductModel({
    required this.id,
    this.brandId,
    this.productCategoryId,
    this.productSubCategoryId,
     this.itemName,
    this.price,
    this.stock,
    this.discount,
     this.image,
     this.size,
     this.flavor,
     this.description,
     this.suggestedUs,
     this.healthNotes,
     this.specification,
     this.servingSize,
    this.servingsPerContainer,
     this.ingredients,
     this.createdAt,
    this.nutritionFacts,
     this.note,
    this.partnersId,
    this.itemsId,
     this.productSubCategory,
     this.productName,
     this.productImage,
     this.productWeight,
     this.productVariant,
    this.productDiscountPercentage,
     this.priceType,
    this.productPrice,
     this.metaTitle,
     this.metaKeyword,
     this.metaDescription,
     this.productSlug,
    this.enabled,
    this.imageFullPath
  });

  String get fullImageUrl {
    if(imageFullPath != null && imageFullPath!.isNotEmpty){
      return imageFullPath!;
    }
    return '';
  }
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<NutritionFact>? parsedNutritionFacts;
    if (json['nutrition_facts'] is String && json['nutrition_facts'].isNotEmpty) {
      try {
        final List<dynamic> factsList = jsonDecode(json['nutrition_facts']);
        parsedNutritionFacts = factsList.map((factJson) => NutritionFact.fromJson(factJson)).toList();
      } catch (e) {
        parsedNutritionFacts = null;
      }
    }

    return ProductModel(
      id: json['id'].toString(),
      brandId: json['brand_id']?.toString(),
      productCategoryId: json['product_category_id']?.toString(),
      productSubCategoryId: json['product_sub_category_id']?.toString(),
      itemName: json['item_name']?.toString(),
      price: json['price']?.toString(), // Use null-aware access
      stock: json['stock']?.toString(),
      discount: json['discount']?.toString(), // Use null-aware access
      image: json['image']?.toString() ?? json['product_image']?.toString(),
      size: json['size']?.toString() ?? json['product_weight']?.toString(),
      flavor: json['flavor']?.toString() ?? json['product_variant']?.toString(),
      description: json['description']?.toString(),
      suggestedUs: json['suggested_Us']?.toString(),
      healthNotes: json['health_notes']?.toString(),
      specification: json['specification']?.toString(),
      servingSize: json['serving_size']?.toString(),
      servingsPerContainer: json['servings_per_container']?.toString(),
      ingredients: json['ingredients']?.toString(),
      createdAt: json['created_at']?.toString(),
      nutritionFacts: parsedNutritionFacts,
      note: json['note']?.toString(), // Use null-aware access
      partnersId: json['partners_id']?.toString(),
      itemsId: json['items_id']?.toString(),
      productSubCategory: json['product_sub_category']?.toString(), // Use null-aware access
      productName: json['product_name']?.toString(),
      productImage: json['product_image']?.toString(),
      productWeight: json['product_weight']?.toString(),
      productVariant: json['product_variant']?.toString(),
      productDiscountPercentage: json['product_discount_percentage']?.toString(),
      priceType: json['price_type']?.toString(),
      productPrice: json['product_price']?.toString(),
      metaTitle: json['meta_title']?.toString(),
      metaKeyword: json['meta_keyword']?.toString(),
      metaDescription: json['meta_description']?.toString(), // Use null-aware access
      productSlug: json['product_slug']?.toString(),
      imageFullPath: json['image_full_path']?.toString(),
      enabled: json['enabled']?.toString(),
    );
  }
}

class ProductResponse {
  final String status;
  final List<ProductModel> data;
  final String message;

  ProductResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
     final dataList = json['data'];
    return ProductResponse(
      status: json['status'],
      data: (dataList is List)? dataList.map((e)=> ProductModel.fromJson(e)).toList() : [],
      message: json['message'] ?? '',
    );
  }
}

class NutritionFact {
  final String nutrientName;
  final String amount;
  final String dailyValue;

  const NutritionFact({
    required this.nutrientName,
    required this.amount,
    required this.dailyValue,
  });

  factory NutritionFact.fromJson(Map<String, dynamic> json) {
    return NutritionFact(
      nutrientName: json['nutrient_name'] ?? '',
      amount: json['amount'] ?? '',
      dailyValue: json['daily_value'] ?? '',
    );
  }
} 