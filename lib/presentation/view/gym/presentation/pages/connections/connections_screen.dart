import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';

class ConnectionsScreen extends StatefulWidget {
  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  List<dynamic> pendingRequests = [];
  List<dynamic> connections = [];
  bool isLoading = true;

  // ✅ SIMPLIFIED - Just list of rating options (no numbers needed)
  final List<String> ratingOptions = [
    "Very Motivating",
    "Average",
    "Not Consistent",
  ];

  @override
  void initState() {
    super.initState();
    _loadConnections();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Got notification: ${message.notification?.title}");
        _loadConnections(); // Refresh when notification arrives
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification?.title ?? 'New notification'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });
  }

  Future<void> _loadConnections() async {
    try {
      setState(() => isLoading = true);
      
      final prefs = await SharedPreferences.getInstance();
      final user_id = prefs.getString("userId");
      
      final response = await http.get(
        Uri.parse('https://fitfirst.online/Api/getConnections?user_id=$user_id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            pendingRequests = jsonResponse['requests'] ?? [];
            connections = jsonResponse['connections'] ?? [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading connections: $e");
    }
  }

  Future<void> _respondToRequest(int requestId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('https://fitfirst.online/Api/respondToRequest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'request_id': requestId,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${action}ed successfully!'),
            backgroundColor: action == 'accept' ? Colors.green : Colors.orange,
          ),
        );
        _loadConnections();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ✅ RATING FUNCTIONALITY WITH DECISION FLOW
  Future<void> _rateBuddy(int buddyId, String buddyName, String rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");

      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Step 1: Submit Rating
      final response = await http.post(
        Uri.parse('https://fitfirst.online/Api/rateBuddy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': int.parse(userId),
          'buddy_id': buddyId,
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          // Step 2: Show Decision Dialog
          _showBuddyDecisionDialog(int.parse(userId), buddyId, buddyName, rating);
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Failed to submit rating');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ BUDDY DECISION DIALOG
  void _showBuddyDecisionDialog(int userId, int buddyId, String buddyName, String rating) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to make a decision
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Thank you message
              Text(
                'Thank you for rating!',
                style: AppTextStyles.headline.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Rating feedback
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRatingColor(rating).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'You rated $buddyName as "$rating"',
                  style: AppTextStyles.body.copyWith(
                    color: _getRatingColor(rating),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Decision question
              Text(
                'What would you like to do next?',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Decision Buttons
              Row(
                children: [
                  // Continue Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _submitBuddyDecision(userId, buddyId, buddyName, "continue");
                      },
                      icon: const Icon(Icons.handshake, color: Colors.white),
                      label: const Text(
                        'Continue\nWorkout',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Replace Button  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _submitBuddyDecision(userId, buddyId, buddyName, "replace");
                      },
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      label: const Text(
                        'Find New\nBuddy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Skip for now option
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can make this decision anytime from your profile'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                },
                child: Text(
                  'Decide later',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ SUBMIT BUDDY DECISION
  Future<void> _submitBuddyDecision(int userId, int buddyId, String buddyName, String decision) async {
    try {
      final response = await http.post(
        Uri.parse('https://fitfirst.online/Api/buddyDecision'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'buddy_id': buddyId,
          'decision': decision,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          // Show appropriate success message
          String message;
          Color backgroundColor;
          
          if (decision == "continue") {
            message = '🤝 Great! You\'ll continue working out with $buddyName';
            backgroundColor = Colors.green;
          } else {
            message = '🔄 We\'ll help you find a new workout buddy soon!';
            backgroundColor = Colors.orange;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          _loadConnections(); // Refresh the connections
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception('Failed to record decision');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording decision: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ RATING DIALOG
  void _showRatingDialog(int buddyId, String buddyName, String? buddyImage) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rate $buddyName',
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Buddy Avatar
              CircleAvatar(
                radius: 35,
                backgroundImage: buddyImage != null 
                  ? NetworkImage(buddyImage) 
                  : null,
                backgroundColor: AppColors.primary,
                child: buddyImage == null
                    ? const Icon(Icons.person, color: Colors.white, size: 35)
                    : null,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'How was your workout experience with $buddyName?',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // ✅ SIMPLIFIED RATING BUTTONS
              ...ratingOptions.map((rating) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close rating dialog
                      _rateBuddy(buddyId, buddyName, rating); // This will trigger decision dialog
                    },
                    icon: Icon(_getRatingIcon(rating), color: Colors.white),
                    label: Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getRatingColor(rating),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ SIMPLIFIED HELPER METHODS
  Color _getRatingColor(String rating) {
    switch (rating) {
      case "Very Motivating": return Colors.green;
      case "Average": return Colors.orange;
      case "Not Consistent": return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getRatingIcon(String rating) {
    switch (rating) {
      case "Very Motivating": return Icons.thumb_up;
      case "Average": return Icons.thumbs_up_down;
      case "Not Consistent": return Icons.thumb_down;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadConnections,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Pending Requests'),
                        Tab(text: 'My Connections'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPendingRequests(),
                          _buildConnections(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPendingRequests() {
    if (pendingRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending requests', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: request['sender_image'] != null
                  ? NetworkImage(request['sender_image'])
                  : null,
              backgroundColor: AppColors.primary,
              child: request['sender_image'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              request['sender_name'] ?? 'Unknown',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request['message'] ?? 'Wants to be your gym buddy'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _respondToRequest(
                        int.parse(request['id'].toString()),
                        'accept'
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(80, 36),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _respondToRequest(
                        int.parse(request['id'].toString()),
                        'reject'
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(80, 36),
                      ),
                      child: const Text('Decline'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ CONNECTIONS WITH RATE BUTTON
// ✅ IMPROVED CONNECTIONS WITH SMALLER RATE BUTTON & SINGLE LINE NAME
Widget _buildConnections() {
  if (connections.isEmpty) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No connections yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: connections.length,
    itemBuilder: (context, index) {
      final connection = connections[index];
      final buddyId = int.parse(connection['buddy_id'].toString());
      final buddyName = connection['buddy_name'] ?? 'Unknown';
      final buddyImage = connection['buddy_image'];
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ✅ BUDDY AVATAR
              CircleAvatar(
                radius: 25,
                backgroundImage: buddyImage != null
                    ? NetworkImage(buddyImage)
                    : null,
                backgroundColor: AppColors.primary,
                child: buddyImage == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // ✅ BUDDY INFO (SINGLE LINE NAME)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buddyName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1, // ✅ FORCE SINGLE LINE
                      overflow: TextOverflow.ellipsis, // ✅ ADD ... IF TOO LONG
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connected',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // ✅ SMALLER RATE BUTTON
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () => _showRatingDialog(buddyId, buddyName, buddyImage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(50, 30), // ✅ SMALLER SIZE
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // ✅ LESS PADDING
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // ✅ SMALLER RADIUS
                    ),
                  ),
                  child: const Text(
                    'Rate',
                    style: TextStyle(
                      fontSize: 11, // ✅ SMALLER FONT
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // ✅ CHAT BUTTON (ICON ONLY)
              IconButton(
                icon: const Icon(Icons.message, color: Colors.grey, size: 20), // ✅ SMALLER ICON
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat feature coming soon!')),
                  );
                },
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36), // ✅ SMALLER TOUCH AREA
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
