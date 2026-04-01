import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:orka_sports/core/constants/app_colors.dart';

class CoachDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> coach;

  const CoachDetailsScreen({
    super.key, 
    required this.coach,
  });

  // ✅ WhatsApp launcher method (unchanged)
  Future<void> _launchWhatsApp(BuildContext context) async {
    try {
      final phoneNumber = coach['contact_number']?.toString() ?? '';
      
      if (phoneNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coach contact number not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final phoneWithCountryCode = cleanedPhone.startsWith('+') 
          ? cleanedPhone 
          : '+91$cleanedPhone';

      final message = Uri.encodeComponent(
        'Hi ${coach['full_name'] ?? 'Coach'}, I found your profile on Fit First app and would like to connect with you regarding fitness coaching.'
      );

      String whatsappUrl;
      if (Platform.isAndroid) {
        whatsappUrl = 'whatsapp://send?phone=$phoneWithCountryCode&text=$message';
      } else {
        whatsappUrl = 'https://wa.me/$phoneWithCountryCode?text=$message';
      }

      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening WhatsApp...'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WhatsApp not installed or unable to open'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Call launcher method (unchanged)
  Future<void> _launchCall(BuildContext context) async {
    try {
      final phoneNumber = coach['contact_number']?.toString() ?? '';
      
      if (phoneNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact number not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final url = 'tel:$phoneNumber';
      await launchUrl(Uri.parse(url));
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to make phone call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(coach['full_name'] ?? 'Coach Details'),
        backgroundColor: AppColors.kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coach Profile Image
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.kPrimaryColor,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: coach['coach_image'] != null && 
                                 coach['coach_image'].toString().isNotEmpty
                      ? NetworkImage(coach['coach_image'])
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: coach['coach_image'] == null || 
                          coach['coach_image'].toString().isEmpty
                      ? Icon(
                          Icons.person, 
                          size: 80, 
                          color: Colors.grey[400],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Coach Details Card
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
                      'Coach Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // ✅ Dynamic fields display - added "open_to_online", removed "distance"
                    ..._buildCoachFields(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact Actions Card (unchanged)
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
                      'Contact Coach',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // WhatsApp Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchWhatsApp(context),
                        icon: Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'Chat on WhatsApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Call Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _launchCall(context),
                        icon: Icon(
                          Icons.phone,
                          color: AppColors.kPrimaryColor,
                          size: 20,
                        ),
                        label: Text(
                          'Call Coach',
                          style: TextStyle(
                            color: AppColors.kPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.kPrimaryColor, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATED: Added "open_to_online", removed "distance" - completely dynamic
  List<Widget> _buildCoachFields() {
    final fieldsToShow = [
      'full_name',
      'dob',
      'gender', 
      'country',
      'state',
      'city',
      'address',
      'contact_number',
      'alt_number',
      'email',
      'open_to_online', // ✅ ADDED: New field from API
      // ✅ REMOVED: 'distance' field is no longer displayed
    ];

    final fieldLabels = {
      'full_name': 'Full Name',
      'dob': 'Date of Birth',
      'gender': 'Gender',
      'country': 'Country',
      'state': 'State',
      'city': 'City',
      'address': 'Address',
      'contact_number': 'Contact Number',
      'alt_number': 'Alternate Number',
      'email': 'Email',
      'open_to_online': 'Open to Online', // ✅ ADDED: Label for online availability
    };

    List<Widget> widgets = [];
    
    for (String key in fieldsToShow) {
      final value = coach[key];
      if (value != null && value.toString().isNotEmpty) {
        // ✅ Special handling for open_to_online field - completely dynamic
        String displayValue;
        Widget? trailingWidget;
        
        if (key == 'open_to_online') {
          // ✅ Dynamic check for "Yes" value from API (no hardcoding)
          final isOnlineAvailable = value.toString().toLowerCase() == 'yes' || 
                                   value.toString().toLowerCase() == 'true' ||
                                   value.toString() == '1';
          
          displayValue = value.toString(); // ✅ Use actual API value
          
          // ✅ Dynamic visual indicator based on API response
          trailingWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOnlineAvailable 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOnlineAvailable ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnlineAvailable ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isOnlineAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  displayValue, // ✅ Shows actual API value ("Yes" or "No")
                  style: TextStyle(
                    color: isOnlineAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
          displayValue = ''; // Don't show text separately, only the chip
        } else {
          displayValue = value.toString(); // ✅ All other fields show API value directly
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    '${fieldLabels[key] ?? key}:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: trailingWidget ?? Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
}
