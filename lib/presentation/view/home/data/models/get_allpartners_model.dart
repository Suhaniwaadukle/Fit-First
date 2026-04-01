import 'dart:convert';

GetAllPartnersModel gelAllPartnersModelFromJson(String str) => GetAllPartnersModel.fromJson(json.decode(str));

String gelAllPartnersModelToJson(GetAllPartnersModel data) => json.encode(data.toJson());

class GetAllPartnersModel {
  String? status;
  List<AllPartnersModel>? data;
  String? message;

  GetAllPartnersModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetAllPartnersModel.fromJson(Map<String, dynamic> json) => GetAllPartnersModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<AllPartnersModel>.from(json["data"]!.map((x) => AllPartnersModel.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

// ✅ UPDATED: Added products_and_services field
class AllPartnersModel {
  String? partnerId;
  String? partnerName;
  String? partnerProfile;
  String? partnerLat;
  String? partnerLong;
  String? partnerImage;
  String? distance;
  String? about;
  String? mobile; 
  String? startTimeMonday;
  String? endTimeMonday;
  String? startTimeTuesday;
  String? endTimeTuesday;
  String? startTimeWednesday;
  String? endTimeWednesday;
  String? startTimeThursday;
  String? endTimeThursday;
  String? startTimeFriday;
  String? endTimeFriday;
  String? startTimeSaturday;
  String? endTimeSaturday;
  String? startTimeSunday;
  String? endTimeSunday;
  List<Map<String, dynamic>>? productSubcategories; 
  List<ProductServiceModel>? productsAndServices; 

  AllPartnersModel({
    this.partnerId,
    this.partnerName,
    this.partnerProfile,
    this.partnerLat,
    this.partnerLong,
    this.partnerImage,
    this.distance,
    this.about,
    this.mobile, 
    this.startTimeMonday,
    this.endTimeMonday,
    this.startTimeTuesday,
    this.endTimeTuesday,
    this.startTimeWednesday,
    this.endTimeWednesday,
    this.startTimeThursday,
    this.endTimeThursday,
    this.startTimeFriday,
    this.endTimeFriday,
    this.startTimeSaturday,
    this.endTimeSaturday,
    this.startTimeSunday,
    this.endTimeSunday,
    this.productSubcategories, 
    this.productsAndServices, 
  });

  factory AllPartnersModel.fromJson(Map<String, dynamic> json) => AllPartnersModel(
        partnerId: json["partnerID"],
        partnerName: json["partnerName"],
        partnerProfile: json["partnerProfile"],
        partnerLat: json["partnerLat"] ?? "",
        partnerLong: json["partnerLong"] ?? "",
        partnerImage: json["partner_image"],
        distance: json["distance"],
        about: json["about"],
        mobile: json["mobile"],
        startTimeMonday: json["start_time_monday"],
        endTimeMonday: json["end_time_monday"],
        startTimeTuesday: json["start_time_tuesday"],
        endTimeTuesday: json["end_time_tuesday"],
        startTimeWednesday: json["start_time_wednesday"],
        endTimeWednesday: json["end_time_wednesday"],
        startTimeThursday: json["start_time_thursday"],
        endTimeThursday: json["end_time_thursday"],
        startTimeFriday: json["start_time_friday"],
        endTimeFriday: json["end_time_friday"],
        startTimeSaturday: json["start_time_saturday"],
        endTimeSaturday: json["end_time_saturday"],
        startTimeSunday: json["start_time_sunday"],
        endTimeSunday: json["end_time_sunday"],
        productSubcategories: json["product_subcategories"] != null 
            ? List<Map<String, dynamic>>.from(json["product_subcategories"]) 
            : [], 
        // ✅ Parse products_and_services array
        productsAndServices: json["products_and_services"] == null
            ? []
            : List<ProductServiceModel>.from(
                json["products_and_services"]!.map((x) => ProductServiceModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "partnerID": partnerId,
        "partnerName": partnerName,
        "partnerProfile": partnerProfile,
        "partnerLat": partnerLat,
        "partnerLong": partnerLong,
        "partner_image": partnerImage,
        "distance": distance,
        "about": about,
        "mobile": mobile, 
        "start_time_monday": startTimeMonday,
        "end_time_monday": endTimeMonday,
        "start_time_tuesday": startTimeTuesday,
        "end_time_tuesday": endTimeTuesday,
        "start_time_wednesday": startTimeWednesday,
        "end_time_wednesday": endTimeWednesday,
        "start_time_thursday": startTimeThursday,
        "end_time_thursday": endTimeThursday,
        "start_time_friday": startTimeFriday,
        "end_time_friday": endTimeFriday,
        "start_time_saturday": startTimeSaturday,
        "end_time_saturday": endTimeSaturday,
        "start_time_sunday": startTimeSunday,
        "end_time_sunday": endTimeSunday,
        "product_subcategories": productSubcategories,
        // ✅ Include products in JSON output
        "products_and_services": productsAndServices == null
            ? []
            : List<dynamic>.from(productsAndServices!.map((x) => x.toJson())),
      };
}

// ✅ NEW: Product/Service model class
class ProductServiceModel {
  String? id;
  String? partnersId;
  String? brandId;
  String? itemsId;
  String? productSubCategory;
  String? productName;
  String? productDescription;
  String? productImage;
  String? productWeight;
  String? productVariant;
  String? productDiscountPercentage;
  String? priceType;
  String? productPrice;
  String? metaTitle;
  String? metaKeyword;
  String? metaDescription;
  String? productSlug;
  String? enabled;
  String? createdAt;

  ProductServiceModel({
    this.id,
    this.partnersId,
    this.brandId,
    this.itemsId,
    this.productSubCategory,
    this.productName,
    this.productDescription,
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
    this.createdAt,
  });

  factory ProductServiceModel.fromJson(Map<String, dynamic> json) => ProductServiceModel(
        id: json["id"],
        partnersId: json["partners_id"],
        brandId: json["brand_id"],
        itemsId: json["items_id"],
        productSubCategory: json["product_sub_category"],
        productName: json["product_name"],
        productDescription: json["product_description"],
        productImage: json["product_image"],
        productWeight: json["product_weight"],
        productVariant: json["product_variant"],
        productDiscountPercentage: json["product_discount_percentage"],
        priceType: json["price_type"],
        productPrice: json["product_price"],
        metaTitle: json["meta_title"],
        metaKeyword: json["meta_keyword"],
        metaDescription: json["meta_description"],
        productSlug: json["product_slug"],
        enabled: json["enabled"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "partners_id": partnersId,
        "brand_id": brandId,
        "items_id": itemsId,
        "product_sub_category": productSubCategory,
        "product_name": productName,
        "product_description": productDescription,
        "product_image": productImage,
        "product_weight": productWeight,
        "product_variant": productVariant,
        "product_discount_percentage": productDiscountPercentage,
        "price_type": priceType,
        "product_price": productPrice,
        "meta_title": metaTitle,
        "meta_keyword": metaKeyword,
        "meta_description": metaDescription,
        "product_slug": productSlug,
        "enabled": enabled,
        "created_at": createdAt,
      };
}
