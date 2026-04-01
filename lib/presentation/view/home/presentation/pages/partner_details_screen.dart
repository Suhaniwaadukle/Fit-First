import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/body/product_screen/product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> partner;
  const PartnerDetailsScreen({
    super.key,
    required this.partner,
  });
  @override
  State<PartnerDetailsScreen> createState() => _PartnerDetailsScreenState();
}

class _PartnerDetailsScreenState extends State<PartnerDetailsScreen> {
  String _readableAddress = 'Fetching address...';
  
  // ✅ Gallery state variables
  List<String> _galleryImages = [];
  bool _isGalleryLoading = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _getReadableAddress();
    _fetchGalleryImages();
  }

  // ✅ Enhanced function to remove HTML tags AND HTML entities
  String _cleanHtmlText(String htmlText) {
    if (htmlText.isEmpty) return '';
    
    // Remove HTML tags
    String cleaned = htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove common HTML entities
    cleaned = cleaned.replaceAll('&rsquo;', "'");
    cleaned = cleaned.replaceAll('&lsquo;', "'");
    cleaned = cleaned.replaceAll('&rdquo;', '"');
    cleaned = cleaned.replaceAll('&ldquo;', '"');
    cleaned = cleaned.replaceAll('&amp;', '&');
    cleaned = cleaned.replaceAll('&lt;', '<');
    cleaned = cleaned.replaceAll('&gt;', '>');
    cleaned = cleaned.replaceAll('&nbsp;', ' ');
    
    // Remove extra whitespace and newlines
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  // ✅ Convert lat/long to readable address
  Future<void> _getReadableAddress() async {
    try {
      final latStr = widget.partner['partnerLat']?.toString() ?? '';
      final longStr = widget.partner['partnerLong']?.toString() ?? '';

      if (latStr.isEmpty || longStr.isEmpty) {
        setState(() {
          _readableAddress = 'Location not available';
        });
        return;
      }

      final latitude = double.parse(latStr);
      final longitude = double.parse(longStr);

      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        final addressParts = [
          place.street,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.country,
        ].where((part) => part != null && part.isNotEmpty).toList();

        setState(() {
          _readableAddress = addressParts.join(', ');
        });
      } else {
        setState(() {
          _readableAddress = 'Address not found';
        });
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      if (mounted) {
        setState(() {
          _readableAddress = 'Unable to fetch address';
        });
      }
    }
  }

  // ✅ ADDED: Google Maps navigation method (same as HomeScreen)
Future<void> _openGoogleMaps() async {
  try {
    final latStr = widget.partner['partnerLat']?.toString() ?? '';
    final longStr = widget.partner['partnerLong']?.toString() ?? '';
    
    if (latStr.isEmpty || longStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location coordinates not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final lat = double.tryParse(latStr) ?? 0.0;
    final lng = double.tryParse(longStr) ?? 0.0;

    // Check if coordinates are valid
    if (lat == 0.0 && lng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available for this partner'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create Google Maps URL with destination
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Fallback to basic maps URL
      final fallbackUrl = 'https://maps.google.com/?q=$lat,$lng';
      if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch Google Maps';
      }
    }
  } catch (e) {
    debugPrint('Error launching Google Maps: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open Google Maps'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  // ✅ Fetch gallery images from API
  Future<void> _fetchGalleryImages() async {
    setState(() {
      _isGalleryLoading = true;
    });

    try {
      final partnerId = widget.partner['partnerID']?.toString() ?? '';
      
      if (partnerId.isEmpty) {
        setState(() {
          _isGalleryLoading = false;
        });
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://fitfirst.online/Api/getGymGallery'),
      );
      
      request.fields['partner_id'] = partnerId;

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseString);
        
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> photos = data['data'];
          if (mounted) {
            setState(() {
              _galleryImages = photos
                  .map<String>((photo) => photo['photo']?.toString() ?? '')
                  .where((url) => url.isNotEmpty)
                  .toList();
              _currentImageIndex = 0;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching gallery images: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGalleryLoading = false;
        });
      }
    }
  }

  // ✅ Navigate to previous image
  void _showPreviousImage() {
    if (_galleryImages.isNotEmpty) {
      setState(() {
        _currentImageIndex = (_currentImageIndex - 1 + _galleryImages.length) % _galleryImages.length;
      });
    }
  }

  // ✅ Navigate to next image
  void _showNextImage() {
    if (_galleryImages.isNotEmpty) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _galleryImages.length;
      });
    }
  }

  // ✅ Launch WhatsApp with partner's mobile number
  Future<void> _launchWhatsApp() async {
    try {
      final mobile = widget.partner['mobile']?.toString() ?? '';
      final partnerName = widget.partner['partnerName'] ?? 'Partner';
      
      if (mobile.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partner contact number not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Format phone number (assuming UAE +971 - adjust as needed)
      final formattedPhone = mobile.startsWith('+') ? mobile.substring(1) : '971$mobile';
      final message = Uri.encodeComponent('Hi $partnerName, I found you on Fit First app and would like to know more about your services.');
      final whatsappUrl = 'https://wa.me/$formattedPhone?text=$message';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp not installed or unable to open'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ NEW: Build day-wise timings widget
  Widget _buildDayWiseTimings() {
    final days = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
    ];
    
    final dayLabels = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    List<Widget> timingRows = [];
    
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final startTimeKey = 'start_time_$day';
      final endTimeKey = 'end_time_$day';
      
      final startTime = widget.partner[startTimeKey]?.toString() ?? '';
      final endTime = widget.partner[endTimeKey]?.toString() ?? '';
      
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        timingRows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayLabels[i],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$startTime - $endTime',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    if (timingRows.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Operating Hours',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...timingRows,
      ],
    );
  }

  // ✅ NEW: Build separate Partner Description card
  Widget _buildPartnerDescriptionCard() {
    final about = widget.partner['about']?.toString() ?? '';
    final cleanAbout = _cleanHtmlText(about);
    
    if (cleanAbout.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partner Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              cleanAbout,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    appBar: AppBar(
      title: Text(widget.partner['partnerName'] ?? 'Partner Details'),
      backgroundColor: AppColors.kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Partner Image
          if (widget.partner['partnerProfile'] != null && 
              widget.partner['partnerProfile'].toString().isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.partner['partnerProfile'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.business,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),

          // ✅ FIXED: Partner Information Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partner Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Partner Name', widget.partner['partnerName']),
                  _buildInfoRow('Distance', '${widget.partner['distance'] ?? 'N/A'} km'),
                  _buildInfoRow('Location', _readableAddress),
                  
                  // Day-wise timings
                  _buildDayWiseTimings(),
                  
                  // ✅ FIXED: Action Buttons Row (both buttons side by side)
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Navigate Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.navigation, size: 20, color: Colors.white),
                          label: const Text(
                            'Navigate',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12), // Space between buttons
                      
                      // WhatsApp Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchWhatsApp,
                          icon: const Icon(Icons.chat, size: 20, color: Colors.white),
                          label: const Text(
                            'WhatsApp',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366), // WhatsApp green
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ✅ Separate Partner Description Card
          _buildPartnerDescriptionCard(),

          // ✅ Add spacing only if description card was shown
          if (widget.partner['about']?.toString().isNotEmpty ?? false)
            const SizedBox(height: 24),

          // ✅ Product Subcategories Section
          _buildSubcategoriesSection(),

          const SizedBox(height: 24),

          // ✅ Gallery Section
          if (_galleryImages.isNotEmpty || _isGalleryLoading)
            _buildGallerySection(),
        ],
      ),
    ),
  );
}

  
  // ✅ Build product subcategories section - hide card if empty
  Widget _buildSubcategoriesSection() {
    final subcategories = widget.partner['product_subcategories'] as List<dynamic>? ?? [];
    
    // ✅ Return nothing if no categories available
    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final category = subcategories[index];
                return InkWell(
                  onTap: () {
                    // ✅ Navigate to ProductScreen with required parameters
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen(
                          partnerId: widget.partner['partnerID']?.toString() ?? '',
                          subcategoryId: category['subcat_id']?.toString() ?? '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category Icon
                          Container(
                            width: 40,
                            height: 35,
                            child: category['subcat_icon'] != null && 
                                   category['subcat_icon'].toString().isNotEmpty
                                ? Image.network(
                                    category['subcat_icon'],
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.category,
                                        size: 30,
                                        color: AppColors.kPrimaryColor,
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.category,
                                    size: 30,
                                    color: AppColors.kPrimaryColor,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Category Name
                          Text(
                            _cleanHtmlText(category['subcat_name']?.toString() ?? 'Category'),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATED: Gallery section - only show if images are available
  Widget _buildGallerySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gallery',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isGalleryLoading)
              Container(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.kPrimaryColor,
                  ),
                ),
              )
            else if (_galleryImages.isEmpty)
              Container(
                height: 250,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No photos available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // ✅ Image Carousel with Left/Right Arrows
              Column(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // ✅ Current Image
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _galleryImages[_currentImageIndex],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[100],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.kPrimaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // ✅ Left Arrow Button
                        if (_galleryImages.length > 1)
                          Positioned(
                            left: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _showPreviousImage,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        // ✅ Right Arrow Button
                        if (_galleryImages.length > 1)
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _showNextImage,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        // ✅ Image Counter Badge
                        if (_galleryImages.length > 1)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentImageIndex + 1} / ${_galleryImages.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // ✅ Optional: Dot Indicators
                  if (_galleryImages.length > 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _galleryImages.asMap().entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == entry.key ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentImageIndex == entry.key
                                ? AppColors.kPrimaryColor
                                : Colors.grey[400],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
