import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart';
import 'package:orka_sports/presentation/blocs/product_details/product_details_event.dart';
import 'package:orka_sports/presentation/blocs/product_details/product_details_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsBloc extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final ActivityRepository _repository;
  List<String> _allWeights = [];
  
  ProductDetailsBloc({ActivityRepository? repository})
      : _repository = repository ?? ActivityRepository(),
        super(ProductDetailsInitial()) {
    on<LoadProductDetails>(_onLoadProductDetails);
    on<LoadVariantsByWeight>(_onLoadVariantsByWeight);
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductDetailsState> emit,
  ) async {
    try {
      emit(ProductDetailsLoading());

      final products = await _repository.getProductDetails(
        partnerId: event.partnerId,
        subCategoryId: event.subCategoryId,
        productName: event.productName,
      );
      if (products.isNotEmpty) {
        _allWeights = products.first.productWeight;
      }
      emit(ProductDetailsLoaded(products));
    } catch (e) {
      emit(ProductDetailsError(e.toString()));
    }
  }

  Future<void> _onLoadVariantsByWeight(
    LoadVariantsByWeight event,
    Emitter<ProductDetailsState> emit,
  ) async {
    try {
      emit(ProductDetailsLoading());

      final variants = await _repository.getVariantsByWeight(
        partnerId: event.partnerId,
        subCategoryId: event.subCategoryId,
        productName: event.productName,
        productWeight: event.productWeight,
      );

      emit(ProductVariantsByWeightLoaded(variants, _allWeights));
    } catch (e) {
      emit(ProductDetailsError(e.toString()));
    }
  }

  // 🆕 New method for placing order and opening WhatsApp
  Future<Map<String, dynamic>> placeOrderAndShareOnWhatsApp({
    required String userId,
    required String itemId,
    required String partnersId,
    required String productSubCategory,
    required String productName,
    required String productDescription,
    required String productRealPrice,
    required String productDiscountPrice,
    required String productImage,
    required String productWeight,
    required String productVariant,
    required String partnersMobile,
    required String productDiscountPercentage,
    required String phoneNumber,
    required String status,
    String? price,
  }) async {
    try {
      print("🔍 Placing order...");
      
      // Step 1: Place the order via API
      final orderResponse = await _repository.placeOrder(
        userId: userId,
        itemId: itemId,
        partnersId: partnersId,
        productSubCategory: productSubCategory,
        productName: productName,
        productDescription: productDescription,
        productRealPrice: productRealPrice,
        productDiscountPrice: productDiscountPrice,
        productImage: productImage,
        productWeight: productWeight,
        productVariant: productVariant,
        partnersMobile: partnersMobile,
        productDiscountPercentage: productDiscountPercentage,
        status: status,
      );

      print("🔍 Order placed successfully: ${orderResponse['order_id']}");

      // Step 2: If order is successful, open WhatsApp
      if (orderResponse['status'] == 'success') {
        await _shareProductOnWhatsApp(
          phoneNumber: phoneNumber,
          productName: productName,
          weight: productWeight,
          flavor: productVariant,
          price: price,
          orderId: orderResponse['order_id'].toString(),
        );
      }

      return orderResponse;
    } catch (e) {
      print("❌ Error in placeOrderAndShareOnWhatsApp: $e");
      throw e;
    }
  }

  // ✅ FIXED: Enhanced WhatsApp method with proper message formatting
  Future<void> _shareProductOnWhatsApp({
    required String phoneNumber,
    required String productName,
    required String weight,
    required String flavor,
    required String? price,
    String? orderId,
  }) async {
    try {
      // Clean the phone number
      final cleanPhoneNumber = phoneNumber.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');
      
      print("🔍 === WhatsApp Launch Debug ===");
      print("🔍 Original phone number: '$phoneNumber'");
      print("🔍 Cleaned phone number: '$cleanPhoneNumber'");
      
      // ✅ FIXED: Proper message formatting without escaped characters and extra lines
      final message = '''🛍️ *$productName*
Weight: $weight
Flavor: $flavor
Price: ₹$price${orderId != null ? '\nOrder ID: #$orderId' : ''}

Order confirmed! Thank you for choosing Orka Sports!''';

      print("🔍 Message to send: $message");
      
      // Try multiple WhatsApp methods
      await _tryMultipleWhatsAppMethods(cleanPhoneNumber, message);
      
    } catch (e, stackTrace) {
      print("❌ WhatsApp launch error: $e");
      print("❌ Stack trace: $stackTrace");
      throw 'Error opening WhatsApp: $e';
    }
  }

  // ✅ ENHANCED: Better alternative methods with multiple encoding approaches
  Future<void> _tryMultipleWhatsAppMethods(String phoneNumber, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    
    print("🔍 Trying multiple WhatsApp methods...");
    print("🔍 Encoded message length: ${encodedMessage.length}");
    
    // Method 1: Standard WhatsApp web URL
    final webUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    print("🔍 Method 1 - Web URL: $webUrl");
    
    try {
      final webUri = Uri.parse(webUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        print("✅ WhatsApp web URL worked");
        return;
      }
    } catch (e) {
      print("❌ WhatsApp web URL failed: $e");
    }
    
    // Method 2: WhatsApp app scheme
    final appUrl = 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage';
    print("🔍 Method 2 - App scheme: $appUrl");
    
    try {
      final appUri = Uri.parse(appUrl);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        print("✅ WhatsApp app scheme worked");
        return;
      }
    } catch (e) {
      print("❌ WhatsApp app scheme failed: $e");
    }
    
    // Method 3: Alternative manual encoding (for compatibility)
    final altMessage = message
        .replaceAll(' ', '%20')
        .replaceAll('\n', '%0A')
        .replaceAll('*', '%2A')
        .replaceAll('₹', '%E2%82%B9')
        .replaceAll('#', '%23');
    final altUrl = 'https://wa.me/$phoneNumber?text=$altMessage';
    print("🔍 Method 3 - Alternative encoding: $altUrl");
    
    try {
      final altUri = Uri.parse(altUrl);
      if (await canLaunchUrl(altUri)) {
        await launchUrl(altUri, mode: LaunchMode.externalApplication);
        print("✅ Alternative encoding worked");
        return;
      }
    } catch (e) {
      print("❌ Alternative encoding failed: $e");
    }
    
    // Method 4: Simple WhatsApp URL without message (fallback)
    final simpleUrl = 'https://wa.me/$phoneNumber';
    print("🔍 Method 4 - Simple URL: $simpleUrl");
    
    try {
      final simpleUri = Uri.parse(simpleUrl);
      if (await canLaunchUrl(simpleUri)) {
        await launchUrl(simpleUri, mode: LaunchMode.externalApplication);
        print("⚠️ WhatsApp opened without message (simple URL worked)");
        return;
      }
    } catch (e) {
      print("❌ Simple WhatsApp URL failed: $e");
    }
    
    // Method 5: Different launch mode
    try {
      print("🔍 Method 5 - Platform default mode");
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.platformDefault);
      print("✅ Platform default mode worked");
      return;
    } catch (e) {
      print("❌ Platform default failed: $e");
    }
    
    throw 'Could not launch WhatsApp with any method. Please check if WhatsApp is installed.';
  }
}
