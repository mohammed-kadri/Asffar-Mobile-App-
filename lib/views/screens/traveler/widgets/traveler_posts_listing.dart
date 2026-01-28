import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/agency/widgets/post_card.dart';

class TravelerPostsListing extends StatefulWidget {
  final bool isTrip;
  final String destinationFilter;

  const TravelerPostsListing({
    super.key,
    required this.isTrip,
    required this.destinationFilter,
  });

  @override
  State<TravelerPostsListing> createState() => _TravelerPostsListingState();
}

class _TravelerPostsListingState extends State<TravelerPostsListing> {
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 10),
          Text(
            'لا توجد رحلات متاحة حاليا',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection(widget.isTrip ? 'trips' : 'services')
        .orderBy('postedDate', descending: true);

    // Apply destination filter if selected and not "All"
    if (widget.destinationFilter != 'All' && widget.destinationFilter.isNotEmpty) {
       // Note: This requires accurate exact match or we might need better filtering strategy later.
       // For now assuming 'destination' field exists and stores simple strings.
       // If destination is stored differently, adjustments are needed.
       query = query.where('destination', isEqualTo: widget.destinationFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 10, bottom: 80), // Padding for nav bar
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            // Construct agencyData from post details for PostCard
            final Map<String, dynamic> agencyData = {
              'agencyName': data['agencyName'] ?? 'Unknown Agency',
              'profilePictureUrl': data['agencyImageUrl'] ?? '',
              'uid': data['agencyId'], // Pass agencyId for fetching profile if needed
            };

            return PostCard(
              postId: doc.id,
              price: data['price'] ?? 0,
              agencyName: data['agencyName'] ?? '',
              destination: data['destination'] ?? '',
              date: data['date'] ?? '',
              departDate: data['departDate']?.toDate() ?? DateTime.now(),
              returnDate: data['returnDate']?.toDate() ?? DateTime.now(),
              isTrip: widget.isTrip,
              availableSeats: data['availableSeats'] ?? 0,
              duration: data['duration'] ?? 0,
              imageUrl: data['imageUrl'] ?? '',
              agencyImageUrl: data['agencyImageUrl'] ?? '',
              agencyData: agencyData,
            );
          },
        );
      },
    );
  }
}
