import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/home/data/models/get_allpartners_model.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/home_screen.dart'; // For Partner model
import 'package:orka_sports/presentation/view/home/presentation/pages/partner_details_screen.dart'; // ✅ Add this import

class AllPartnersScreen extends StatefulWidget {
  final List<AllPartnersModel> partners;

  const AllPartnersScreen({
    super.key,
    required this.partners,
  });

  @override
  State<AllPartnersScreen> createState() => _AllPartnersScreenState();
}

class _AllPartnersScreenState extends State<AllPartnersScreen> {
  String _searchQuery = '';
  List<Partner> _filteredPartners = [];
  List<Partner> _allPartners = [];

  @override
  void initState() {
    super.initState();
    // Convert API data to Partner models
    _allPartners = widget.partners.map((apiPartner) => _convertToPartner(apiPartner)).toList();
    _filteredPartners = _allPartners;
  }

  Partner _convertToPartner(AllPartnersModel apiPartner) {
    return Partner(
      id: apiPartner.partnerId ?? '',
      name: apiPartner.partnerName ?? 'Unknown Partner',
      type: 'Partner',
      specialization: 'Fitness Center',
      rating: 4.5,
      distance: double.tryParse(apiPartner.distance ?? '0.0') ?? 0.0,
      imageUrl: apiPartner.partnerProfile ?? 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      level: 'All Levels',
      price: 0,
      isOnline: true,
      address: 'Location available',
      hours: 'Open today',
      amenities: ['Fitness', 'Training'],
      // ✅ Include products data if available
      productsAndServices: apiPartner.productsAndServices
          ?.map((product) => product.toJson())
          .toList() ?? [],
    );
  }

  void _filterPartners(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPartners = _allPartners;
      } else {
        _filteredPartners = _allPartners.where((partner) {
          return partner.name.toLowerCase().contains(query.toLowerCase()) ||
                 partner.address?.toLowerCase().contains(query.toLowerCase()) == true;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'All Partners',
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
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterPartners,
              decoration: InputDecoration(
                hintText: 'Search partners...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _filteredPartners.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? 'No partners available' : 'No partners found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Try different search terms',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPartners.length,
              itemBuilder: (context, index) {
                final partner = _filteredPartners[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildPartnerListCard(partner, index),
                );
              },
            ),
    );
  }

  // ✅ UPDATED: Removed Call button and added navigation to Partner Details
  Widget _buildPartnerListCard(Partner partner, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: InkWell( // ✅ Make entire card clickable
              onTap: () {
                // ✅ Navigate to Partner Details on card tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartnerDetailsScreen(
                      partner: _getPartnerDataForNavigation(partner),
                    ),
                  ),
                );
              },
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
                    // Partner Image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          partner.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.business,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.kPrimaryColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Partner Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  partner.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Open',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${partner.rating}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                partner.hours ?? 'Closes 8:00 PM',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  partner.address ?? 'Location available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // ✅ UPDATED: Only Details button, Call button removed
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // ✅ Navigate to Partner Details Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PartnerDetailsScreen(
                                      partner: _getPartnerDataForNavigation(partner),
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.info, size: 16),
                              label: Text('View Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.kPrimaryColor,
                                foregroundColor: Colors.white,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ Helper method to prepare partner data for navigation
  Map<String, dynamic> _getPartnerDataForNavigation(Partner partner) {
    // Find the matching API partner data to get complete information
    final matchingApiPartner = widget.partners.firstWhere(
      (apiPartner) => apiPartner.partnerId == partner.id,
      orElse: () => AllPartnersModel(),
    );

    return {
      'partnerID': matchingApiPartner.partnerId ?? partner.id,
      'partnerName': matchingApiPartner.partnerName ?? partner.name,
      'partnerProfile': matchingApiPartner.partnerProfile ?? partner.imageUrl,
      'distance': matchingApiPartner.distance ?? partner.distance.toString(),
      'partnerLat': matchingApiPartner.partnerLat ?? '0.0',
      'partnerLong': matchingApiPartner.partnerLong ?? '0.0',
      'about': matchingApiPartner.about,
      'mobile': matchingApiPartner.mobile, 
      'product_subcategories': matchingApiPartner.productSubcategories,
      // ✅ Include products and services data
      'products_and_services': matchingApiPartner.productsAndServices
          ?.map((product) => product.toJson())
          .toList() ?? [],
    };
  }
}
