import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/coach_details_screen.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for CoachModel

class AllCoachesScreen extends StatefulWidget {
  final List<CoachModel> coaches;
  final String? initialFilter; // ✅ Add this parameter


  const AllCoachesScreen({
    super.key,
    required this.coaches,
    this.initialFilter, // ✅ Optional parameter
  });

  @override
  State<AllCoachesScreen> createState() => _AllCoachesScreenState();
}

class _AllCoachesScreenState extends State<AllCoachesScreen> {
  String _selectedFilter = 'All';
  List<CoachModel> _filteredCoaches = [];
   bool _isLoading = false;
  final List<String> _filters = ['All', 'Gym', 'Yoga', 'Zumba'];

  @override
  void initState() {
    super.initState();
     // ✅ Set initial filter from parameter
    _selectedFilter = widget.initialFilter ?? 'All';
    _loadCoachesFromAPI();
  }

    Future<void> _loadCoachesFromAPI() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("userId");
      
      if (userId == null || userId.isEmpty) {
        debugPrint('No user ID found in SharedPreferences');
        return;
      }

      final response = await http.post(
        Uri.parse('https://fitfirst.online/Api/getcoaches'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'userid': userId,
          'type': _selectedFilter.toLowerCase(), // ✅ Use selected filter
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final List<dynamic> coachesJson = data['data'] ?? [];
          if (mounted) {
            setState(() {
              _filteredCoaches = coachesJson.map((json) => CoachModel.fromJson(json)).toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading coaches: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterCoaches() {
    _loadCoachesFromAPI();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        'All Coaches',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = filter == _selectedFilter;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: Material(
                  borderRadius: BorderRadius.circular(25),
                  elevation: isSelected ? 4 : 0,
                  shadowColor: AppColors.kPrimaryColor.withOpacity(0.3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _filterCoaches();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected 
                            ? LinearGradient(
                                colors: [
                                  AppColors.kPrimaryColor,
                                  AppColors.kPrimaryColor.withOpacity(0.8),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected 
                              ? Colors.transparent 
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
    body: _isLoading  // ✅ FIX: Add proper ternary operator
        ? Center(
            child: CircularProgressIndicator(color: AppColors.kPrimaryColor), // ✅ FIX: Remove semicolon
          )
        : _filteredCoaches.isEmpty  // ✅ FIX: Add proper ternary operator
            ? Center(  // ✅ FIX: Add Center widget
                child: Column(  // ✅ FIX: Add child: property
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No coaches found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : Padding(  // ✅ FIX: Complete the ternary operator
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredCoaches.length,
                  itemBuilder: (context, index) {
                    final coach = _filteredCoaches[index];
                    return _buildCoachCard(coach, index);
                  },
                ),
              ),
  );
}


Widget _buildCoachCard(CoachModel coach, int index) {
  return TweenAnimationBuilder(
    duration: Duration(milliseconds: 300 + (index * 50)),
    tween: Tween<double>(begin: 0, end: 1),
    builder: (context, double value, child) {
      return Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(
          opacity: value,
          child: InkWell(  // ✅ Add InkWell for tap handling
            onTap: () {
              // ✅ Navigate to Coach Details Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoachDetailsScreen(
                    coach: coach.toMap(), // Pass coach data as Map
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coach Image
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: coach.fullImageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                coach.fullImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ),
                  
                  // Coach Info
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              coach.fullName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4), // ✅ Fixed spacing
                          Center(
                            child: Text(
                              'Professional Coach',
                              style: TextStyle(
                                fontSize: 12, // ✅ Fixed font size
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

}
