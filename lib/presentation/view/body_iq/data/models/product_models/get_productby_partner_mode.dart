import 'dart:convert';

GetProductByPartnerModel getProductByPartnerModelFromJson(String str) =>
    GetProductByPartnerModel.fromJson(json.decode(str));

String getProductByPartnerModelToJson(GetProductByPartnerModel data) => json.encode(data.toJson());

class GetProductByPartnerModel {
  String? status;
  List<ProductsPartner>? data;
  String? message;

  GetProductByPartnerModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetProductByPartnerModel.fromJson(Map<String, dynamic> json) => GetProductByPartnerModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<ProductsPartner>.from(json["data"]!.map((x) => ProductsPartner.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class ProductsPartner {
  String? id;
  String? name;
  String? email;
  String? phonecode;
  String? mobile;
  String? address;
  String? partnerImage;
  String? pId;
  String? productName;
  String? productWeight;
  String? productVariant;
  String? productImage;
  String? priceType;
  String? productPrice;
  String? productDescription;
  String? productDiscountPercentage;
  String? distance;

  ProductsPartner({
    this.id,
    this.name,
    this.email,
    this.phonecode,
    this.mobile,
    this.address,
    this.partnerImage,
    this.pId,
    this.productName,
    this.productWeight,
    this.productVariant,
    this.productImage,
    this.priceType,
    this.productPrice,
    this.productDescription,
    this.productDiscountPercentage,
    this.distance,
  });

  factory ProductsPartner.fromJson(Map<String, dynamic> json) => ProductsPartner(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phonecode: json["phonecode"],
        mobile: json["mobile"],
        address: json["address"],
        partnerImage: json["partner_image"],
        pId: json["p_id"],
        productName: json["product_name"],
        productWeight: json["product_weight"],
        productVariant: json["product_variant"],
        productImage: json["product_image"],
        priceType: json["price_type"],
        productPrice: json["product_price"],
        productDescription: json["product_description"],
        productDiscountPercentage: json["product_discount_percentage"],
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phonecode": phonecode,
        "mobile": mobile,
        "address": address,
        "partner_image": partnerImage,
        "p_id": pId,
        "product_name": productName,
        "product_weight": productWeight,
        "product_variant": productVariant,
        "product_image": productImage,
        "price_type": priceType,
        "product_price": productPrice,
        "product_description": productDescription,
        "product_discount_percentage": productDiscountPercentage,
        "distance": distance,
      };
}
