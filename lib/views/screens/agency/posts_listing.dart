import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/views/screens/agency/widgets/post_card.dart';
import 'package:rxdart/rxdart.dart';
import '../../../theme/app_theme.dart';

class PostsListing extends StatefulWidget {
  const PostsListing({super.key});

  @override
  State<PostsListing> createState() => _PostsListingState();
}

class _PostsListingState extends State<PostsListing> {
  Map<String, dynamic>? agencyData;

  var data;
  @override
  void initState() {
    super.initState();
    _fetchAgencyData();
  }

  Future<void> _fetchAgencyData() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('agencies')
            .doc(user.uid)
            .get();
        setState(() {
          agencyData = doc.data();
        });
      } catch (e) {
        print('Error fetching agency data: $e');
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/home_add_post.jpg',
            width: MediaQuery.of(context).size.width * 0.75,
          ),
          SizedBox(height: 10),
          Text(
            'لم تقم باضافة أي منشور بعد',
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
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    if (agencyData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20, top: 18, bottom: 10),
              child: data != null
                  ? Text(
                      'منشوراتي:',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                          fontWeight: FontWeight.w600),
                    )
                  : SizedBox(),
            )
          ],
        ),
        Expanded(
          child: StreamBuilder<List<QuerySnapshot>>(
            stream: CombineLatestStream.list([
              FirebaseFirestore.instance
                  .collection('services')
                  .where('agencyId', isEqualTo: user!.uid)
                  .orderBy('postedDate', descending: true)
                  .snapshots(),
              FirebaseFirestore.instance
                  .collection('trips')
                  .where('agencyId', isEqualTo: user!.uid)
                  .orderBy('postedDate', descending: true)
                  .snapshots(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return _buildEmptyState();
              }

              // Combine both collections
              List<DocumentSnapshot> allDocs = [];
              snapshot.data![0].docs.forEach((doc) => allDocs.add(doc));
              snapshot.data![1].docs.forEach((doc) => allDocs.add(doc));

              // Sort by posted date
              allDocs.sort((a, b) {
                DateTime dateA =
                    (a.data() as Map<String, dynamic>)['postedDate'].toDate();
                DateTime dateB =
                    (b.data() as Map<String, dynamic>)['postedDate'].toDate();
                return dateB.compareTo(dateA);
              });

              if (allDocs.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: allDocs.length,
                itemBuilder: (context, index) {
                  final doc = allDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isTrip = doc.reference.path.contains('trips');

                  return PostCard(
                    postId: doc.id, // Pass the post ID
                    price: data['price'] ?? 0,
                    agencyName: data['agencyName'] ?? '',
                    destination: data['destination'] ?? '',
                    date: data['date'] ?? '',
                    departDate: data['departDate']?.toDate() ?? DateTime.now(),
                    returnDate: data['returnDate']?.toDate() ?? DateTime.now(),
                    isTrip: isTrip, // Use the determined isTrip value
                    availableSeats: data['availableSeats'] ?? 0,
                    duration: data['duration'] ?? 0,
                    imageUrl: data['imageUrl'] ?? '',
                    agencyImageUrl: data['agencyImageUrl'] ?? '',
                    agencyData: agencyData ?? {},
                    showLikeButton: false, // Disable like
                    // isTrip: isTrip,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
