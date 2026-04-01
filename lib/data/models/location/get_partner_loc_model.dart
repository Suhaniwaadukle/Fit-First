class GetPartnerLocModel {
  String? status;
  List<PartnerData>? data;
  String? message;

  GetPartnerLocModel({this.status, this.data, this.message});

  factory GetPartnerLocModel.fromJson(Map<String, dynamic> json) {
    return GetPartnerLocModel(
      status: json['status'],
      data: (json['data'] as List<dynamic>?)
          ?.map(
            (e) => PartnerData.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      message: json['message'],
    );
  }
}

class PartnerData {
  String? id;
  String? userId;
  String? name;
  String? slug;
  String? email;
  String? phonecode;
  String? mobile;
  String? locationUrl;
  String? website;
  String? address;
  String? description;
  String? productCategory;
  String? productSubCategory;
  String? latitude;
  String? longitude;
  String? industry;
  String? subIndustry;
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
  String? visibility;
  String? features;
  String? promoVideoUrl;
  String? partnerImage;
  String? priceRange;
  String? discount;
  String? discountText;
  String? cuisines;
  String? country;
  String? state;
  String? city;
  String? cityManual;
  String? linkedinProfileLink;
  String? twitterProfileLink;
  String? facebookProfileLink;
  String? wikipediaProfileLink;
  String? instagramProfileLink;
  String? pinterestProfileLink;
  String? youtubeProfileLink;
  String? metaKeywords;
  String? metaDescription;
  String? subscriptionDuration;
  String? subscriptionAmount;
  String? subscriptionEndDate;
  String? paymentStatus;
  String? enabled;
  String? createdAt;
  String? distance;

  PartnerData({
    this.id,
    this.userId,
    this.name,
    this.slug,
    this.email,
    this.phonecode,
    this.mobile,
    this.locationUrl,
    this.website,
    this.address,
    this.description,
    this.productCategory,
    this.productSubCategory,
    this.latitude,
    this.longitude,
    this.industry,
    this.subIndustry,
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
    this.visibility,
    this.features,
    this.promoVideoUrl,
    this.partnerImage,
    this.priceRange,
    this.discount,
    this.discountText,
    this.cuisines,
    this.country,
    this.state,
    this.city,
    this.cityManual,
    this.linkedinProfileLink,
    this.twitterProfileLink,
    this.facebookProfileLink,
    this.wikipediaProfileLink,
    this.instagramProfileLink,
    this.pinterestProfileLink,
    this.youtubeProfileLink,
    this.metaKeywords,
    this.metaDescription,
    this.subscriptionDuration,
    this.subscriptionAmount,
    this.subscriptionEndDate,
    this.paymentStatus,
    this.enabled,
    this.createdAt,
    this.distance,
  });

  factory PartnerData.fromJson(Map<String, dynamic> json) {
    return PartnerData(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      slug: json['slug'],
      email: json['email'],
      phonecode: json['phonecode'],
      mobile: json['mobile'],
      locationUrl: json['location_url'],
      website: json['website'],
      address: json['address'],
      description: json['description'],
      productCategory: json['product_category'],
      productSubCategory: json['product_sub_category'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      industry: json['industry'],
      subIndustry: json['sub_industry'],
      startTimeMonday: json['start_time_monday'],
      endTimeMonday: json['end_time_monday'],
      startTimeTuesday: json['start_time_tuesday'],
      endTimeTuesday: json['end_time_tuesday'],
      startTimeWednesday: json['start_time_wednesday'],
      endTimeWednesday: json['end_time_wednesday'],
      startTimeThursday: json['start_time_thursday'],
      endTimeThursday: json['end_time_thursday'],
      startTimeFriday: json['start_time_friday'],
      endTimeFriday: json['end_time_friday'],
      startTimeSaturday: json['start_time_saturday'],
      endTimeSaturday: json['end_time_saturday'],
      startTimeSunday: json['start_time_sunday'],
      endTimeSunday: json['end_time_sunday'],
      visibility: json['visibility'],
      features: json['features'],
      promoVideoUrl: json['promo_video_url'],
      partnerImage: json['partner_image'],
      priceRange: json['price_range'],
      discount: json['discount'],
      discountText: json['discount_text'],
      cuisines: json['cuisines'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      cityManual: json['city_manual'],
      linkedinProfileLink: json['linkedin_profile_link'],
      twitterProfileLink: json['twitter_profile_link'],
      facebookProfileLink: json['facebook_profile_link'],
      wikipediaProfileLink: json['wikipedia_profile_link'],
      instagramProfileLink: json['instagram_profile_link'],
      pinterestProfileLink: json['pinterest_profile_link'],
      youtubeProfileLink: json['youtube_profile_link'],
      metaKeywords: json['meta_keywords'],
      metaDescription: json['meta_description'],
      subscriptionDuration: json['subscription_duration'],
      subscriptionAmount: json['subscription_amount'],
      subscriptionEndDate: json['subscription_end_date'],
      paymentStatus: json['payment_status'],
      enabled: json['enabled'],
      createdAt: json['created_at'],
      distance: json['distance'],
    );
  }
}
