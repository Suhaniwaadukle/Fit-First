import 'dart:convert';

GetRecoProductModel getRecoProductModelFromJson(String str) => GetRecoProductModel.fromJson(json.decode(str));

String getRecoProductModelToJson(GetRecoProductModel data) => json.encode(data.toJson());

class GetRecoProductModel {
  String? status;
  List<Product>? data;
  String? message;

  GetRecoProductModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetRecoProductModel.fromJson(Map<String, dynamic> json) => GetRecoProductModel(
        status: json["status"],
        data: json["data"] == null ? [] : List<Product>.from(json["data"]!.map((x) => Product.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class Product {
  String? name;
  String? productId;
  String? itemName;
  String? image;
  String? productSubCategoryId;
  String? purpose;

  Product({
    this.name,
    this.productId,
    this.itemName,
    this.image,
    this.productSubCategoryId,
    this.purpose,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json["name"],
        productId: json["product_id"],
        itemName: json["item_name"],
        image: json["image"],
        productSubCategoryId: json["product_sub_category_id"],
        purpose: json["purpose"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "product_id": productId,
        "item_name": itemName,
        "image": image,
        "product_sub_category_id": productSubCategoryId,
        "purpose": purpose,
      };
}
