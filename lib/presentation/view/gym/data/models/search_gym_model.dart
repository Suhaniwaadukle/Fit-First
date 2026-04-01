class SearchGymModel {
  final String? status;
  final List<SearchGymData>? data;
  final String? message;

  SearchGymModel({
    this.status,
    this.data,
    this.message,
  });

  factory SearchGymModel.fromJson(Map<String, dynamic> json) {
    return SearchGymModel(
      status: json['status'],
      data: json['data'] != null ? List<SearchGymData>.from(json['data'].map((x) => SearchGymData.fromJson(x))) : [],
      message: json['message'],
    );
  }
}

class SearchGymData {
  final String? id;
  final String? userId;
  final String? name;
  final String? slug;
  final String? email;
  final String? phonecode;
  final String? mobile;
  final String? locationUrl;
  final String? website;
  final String? address;
  final String? description;
  final String? productCategory;
  final String? productSubCategory;
  final String? latitude;
  final String? longitude;
  final String? industry;
  final String? subIndustry;
  final String? startTimeMonday;
  final String? endTimeMonday;
  final String? startTimeTuesday;
  final String? endTimeTuesday;
  final String? startTimeWednesday;
  final String? endTimeWednesday;
  final String? startTimeThursday;
  final String? endTimeThursday;
  final String? startTimeFriday;
  final String? endTimeFriday;
  final String? startTimeSaturday;
  final String? endTimeSaturday;
  final String? startTimeSunday;
  final String? endTimeSunday;
  final String? visibility;
  final String? features;
  final String? promoVideoUrl;
  final String? partnerImage;
  final String? priceRange;
  final String? discount;
  final String? discountText;
  final String? cuisines;
  final String? country;
  final String? state;
  final String? city;
  final String? cityManual;
  final String? linkedinProfileLink;
  final String? twitterProfileLink;
  final String? facebookProfileLink;
  final String? wikipediaProfileLink;
  final String? instagramProfileLink;
  final String? pinterestProfileLink;
  final String? youtubeProfileLink;
  final String? metaKeywords;
  final String? metaDescription;
  final String? subscriptionDuration;
  final String? subscriptionAmount;
  final String? subscriptionEndDate;
  final String? paymentStatus;
  final String? enabled;
  final String? gymCode;
  final String? createdAt;
  final String? distance;

  SearchGymData({
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
    this.gymCode,
    this.createdAt,
    this.distance,
  });

  factory SearchGymData.fromJson(Map<String, dynamic> json) {
    return SearchGymData(
      id: json['id'] ?? '',
      userId: json['user_id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      email: json['email'] ?? '',
      phonecode: json['phonecode'] ?? '',
      mobile: json['mobile'] ?? '',
      locationUrl: json['location_url'],
      website: json['website'],
      address: json['address'] ?? '',
      description: json['description'],
      productCategory: json['product_category'],
      productSubCategory: json['product_sub_category'],
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      industry: json['industry'] ?? '',
      subIndustry: json['sub_industry'] ?? '',
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
      partnerImage: json['partner_image'] ?? '',
      priceRange: json['price_range'],
      discount: json['discount'],
      discountText: json['discount_text'],
      cuisines: json['cuisines'],
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
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
      paymentStatus: json['payment_status'] ?? '',
      enabled: json['enabled'] ?? '',
      gymCode: json['gym_code'] ?? '',
      createdAt: json['created_at'] ?? '',
      distance: json['distance'] ?? '',
    );
  }
}
