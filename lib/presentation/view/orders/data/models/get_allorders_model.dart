import 'dart:convert';

GetAllOrdersModel getAllOrdersModelFromJson(String str) => GetAllOrdersModel.fromJson(json.decode(str));

String getAllOrdersModelToJson(GetAllOrdersModel data) => json.encode(data.toJson());

class GetAllOrdersModel {
  String? status;
  List<AllOrdersData>? data;

  GetAllOrdersModel({
    this.status,
    this.data,
  });

  factory GetAllOrdersModel.fromJson(Map<String, dynamic> json) => GetAllOrdersModel(
        status: json["status"],
        data: json["data"] == null ? [] : List<AllOrdersData>.from(json["data"]!.map((x) => AllOrdersData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AllOrdersData {
  String? id;
  String? userid;
  String? itemId;
  String? partnersId;
  String? productSubCategory;
  String? productName;
  String? productDescription;
  String? productRealPrice;
  String? productDiscountPercentage;
  String? productDiscountPrice;
  String? productImage;
  String? productWeight;
  String? productVariant;
  dynamic partnersMobile;
  String? status;
  DateTime? visitTimestamp;
  dynamic partnerName;
  dynamic phonecode;
  dynamic mobile;

  AllOrdersData({
    this.id,
    this.userid,
    this.itemId,
    this.partnersId,
    this.productSubCategory,
    this.productName,
    this.productDescription,
    this.productRealPrice,
    this.productDiscountPercentage,
    this.productDiscountPrice,
    this.productImage,
    this.productWeight,
    this.productVariant,
    this.partnersMobile,
    this.status,
    this.visitTimestamp,
    this.partnerName,
    this.phonecode,
    this.mobile,
  });

  factory AllOrdersData.fromJson(Map<String, dynamic> json) => AllOrdersData(
        id: json["id"],
        userid: json["userid"],
        itemId: json["item_id"],
        partnersId: json["partners_id"],
        productSubCategory: json["product_sub_category"],
        productName: json["product_name"],
        productDescription: json["product_description"],
        productRealPrice: json["product_real_price"],
        productDiscountPercentage: json["product_discount_percentage"],
        productDiscountPrice: json["product_discount_price"],
        productImage: json["product_image"],
        productWeight: json["product_weight"],
        productVariant: json["product_variant"],
        partnersMobile: json["partners_mobile"],
        status: json["status"],
        visitTimestamp: json["visit_timestamp"] == null ? null : DateTime.parse(json["visit_timestamp"]),
        partnerName: json["partner_name"],
        phonecode: json["phonecode"],
        mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userid": userid,
        "item_id": itemId,
        "partners_id": partnersId,
        "product_sub_category": productSubCategory,
        "product_name": productName,
        "product_description": productDescription,
        "product_real_price": productRealPrice,
        "product_discount_percentage": productDiscountPercentage,
        "product_discount_price": productDiscountPrice,
        "product_image": productImage,
        "product_weight": productWeight,
        "product_variant": productVariant,
        "partners_mobile": partnersMobile,
        "status": status,
        "visit_timestamp": visitTimestamp?.toIso8601String(),
        "partner_name": partnerName,
        "phonecode": phonecode,
        "mobile": mobile,
      };
}
