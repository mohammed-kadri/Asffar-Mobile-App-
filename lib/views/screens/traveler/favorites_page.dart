import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/agency/widgets/post_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    if (user == null) {
      return Center(child: Text('Please log in to see favorites'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('travelers')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('savedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading favorites'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                SizedBox(height: 10),
                Text(
                  'لم تقم باضافة أي مفضلة بعد',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final departDate = data['departDate'] is Timestamp
                ? (data['departDate'] as Timestamp).toDate()
                : DateTime.now();
            final returnDate = data['returnDate'] is Timestamp
                ? (data['returnDate'] as Timestamp).toDate()
                : DateTime.now();

            // Handle nested agencyData safely
            Map<String, dynamic> agencyData = {};
            if (data['agencyData'] != null) {
               agencyData = Map<String, dynamic>.from(data['agencyData']);
            }

            return PostCard(
              postId: data['postId'] ?? doc.id,
              price: data['price'] ?? 0,
              isTrip: data['isTrip'] ?? true, // Default to true or handle error
              agencyName: data['agencyName'] ?? '',
              destination: data['destination'] ?? '',
              date: data['date'] ?? '',
              departDate: departDate,
              returnDate: returnDate,
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
