import 'dart:convert';

GetFullRecoProductModel getFullRecoProductModelFromJson(String str) =>
    GetFullRecoProductModel.fromJson(json.decode(str));

String getFullRecoProductModelToJson(GetFullRecoProductModel data) => json.encode(data.toJson());

class GetFullRecoProductModel {
  String? status;
  List<FullProducts>? data;
  String? message;

  GetFullRecoProductModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetFullRecoProductModel.fromJson(Map<String, dynamic> json) => GetFullRecoProductModel(
        status: json["status"],
        data: json["data"] == null ? [] : List<FullProducts>.from(json["data"]!.map((x) => FullProducts.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class FullProducts {
  String? pId;
  String? productName;
  String? productWeight;
  String? productVariant;
  String? productImage;
  String? priceType;
  String? productPrice;
  String? productDescription;
  String? productDiscountPercentage;

  FullProducts({
    this.pId,
    this.productName,
    this.productWeight,
    this.productVariant,
    this.productImage,
    this.priceType,
    this.productPrice,
    this.productDescription,
    this.productDiscountPercentage,
  });

  factory FullProducts.fromJson(Map<String, dynamic> json) => FullProducts(
        pId: json["p_id"],
        productName: json["product_name"],
        productWeight: json["product_weight"],
        productVariant: json["product_variant"],
        productImage: json["product_image"],
        priceType: json["price_type"],
        productPrice: json["product_price"],
        productDescription: json["product_description"],
        productDiscountPercentage: json["product_discount_percentage"],
      );

  Map<String, dynamic> toJson() => {
        "p_id": pId,
        "product_name": productName,
        "product_weight": productWeight,
        "product_variant": productVariant,
        "product_image": productImage,
        "price_type": priceType,
        "product_price": productPrice,
        "product_description": productDescription,
        "product_discount_percentage": productDiscountPercentage,
      };
}
