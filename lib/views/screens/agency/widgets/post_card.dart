import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/agency/post_details.dart';

class PostCard extends StatefulWidget {
  final String postId; // Add postId parameter
  final int price;
  final bool isTrip;
  final String agencyName;
  final String destination;
  final String date;
  final DateTime departDate;
  final DateTime returnDate;
  final int availableSeats;
  final int duration;
  final String imageUrl;
  final String agencyImageUrl;
  final Map<String, dynamic> agencyData;
  final bool showLikeButton; // Add this parameter

  const PostCard({
    Key? key,
    required this.postId,
    required this.price,
    required this.isTrip,
    required this.agencyName,
    required this.destination,
    required this.date,
    required this.departDate,
    required this.returnDate,
    required this.availableSeats,
    required this.duration,
    required this.imageUrl,
    required this.agencyImageUrl,
    required this.agencyData,
    this.showLikeButton = true, // Default to true
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: double.infinity,
        height: 250,
        margin: EdgeInsets.only(bottom: 17),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(12),
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 1,
                offset: Offset(1, 1),
              )
            ]),
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                'https://cdn.craft.cloud/101e4579-0e19-46b6-95c6-7eb27e4afc41/assets/uploads/pois/prague-czech-republic-frommers.jpg',
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
                top: 45,
                right: 15,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          Colors.grey.withOpacity(0.5), // Color of the border
                      width: 0.8, // Border width
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(
                        MediaQuery.sizeOf(context)
                            .width)), // Same borderRadius as in ClipRRect
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: Builder(
                      builder: (context) {
                        final String? directUrl = widget.agencyData['profilePictureUrl'];
                        final String? agencyId = widget.agencyData['uid'];

                        // 1. If we have the URL directly, show it
                        if (directUrl != null && directUrl.isNotEmpty) {
                          return Image.network(
                            directUrl,
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderAvatar(),
                          );
                        }

                        // 2. If no URL but we have ID, fetch it
                        if (agencyId != null && agencyId.isNotEmpty) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('agencies')
                                .doc(agencyId)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                final fetchedUrl = data['profilePictureUrl'];
                                if (fetchedUrl != null && fetchedUrl.isNotEmpty) {
                                  return Image.network(
                                    fetchedUrl,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildPlaceholderAvatar(),
                                  );
                                }
                              }
                              return _buildPlaceholderAvatar();
                            },
                          );
                        }

                        // 3. Fallback
                        return _buildPlaceholderAvatar();
                      },
                    ),
                  ),
                )),
                
            // Like Button
            if (widget.showLikeButton)
            Positioned(
              top: 10,
              left: 10,
              child: StreamBuilder<DocumentSnapshot>(
                stream: () {
                   final user = Provider.of<AuthService>(context, listen: false).currentUser;
                   if (user == null) {
                     return null;
                   }
                   return FirebaseFirestore.instance
                       .collection('travelers')
                       .doc(user.uid)
                       .collection('favorites')
                       .doc(widget.postId)
                       .snapshots();
                }(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // print("DEBUG: Stream error: ${snapshot.error}");
                  }
                  
                  final bool isLiked = snapshot.hasData && snapshot.data!.exists;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[600],
                        size: 24,
                      ),
                      onPressed: () async {
                         final user = Provider.of<AuthService>(context, listen: false).currentUser;
                         if (user == null) return;
                         
                         final favoritesRef = FirebaseFirestore.instance
                             .collection('travelers')
                             .doc(user.uid)
                             .collection('favorites')
                             .doc(widget.postId);

                         try {
                           if (isLiked) {
                             await favoritesRef.delete();
                           } else {
                             await favoritesRef.set({
                               'postId': widget.postId,
                               'isTrip': widget.isTrip,
                               'price': widget.price,
                               'agencyName': widget.agencyName,
                               'destination': widget.destination,
                               'date': widget.date,
                               'departDate': widget.departDate,
                               'returnDate': widget.returnDate,
                               'availableSeats': widget.availableSeats,
                               'duration': widget.duration,
                               'imageUrl': widget.imageUrl,
                               'agencyImageUrl': widget.agencyImageUrl,
                               'agencyData': widget.agencyData,
                               'savedAt': FieldValue.serverTimestamp(),
                             });
                           }
                         } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                         }
                      },
                    ),
                  );
                }
              ),
            ),
            Positioned(  
              right: 125,
              top: 102,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.agencyData['agencyName']}',
                    softWrap: false,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily),
                  ),
                  // SizedBox(height: 4),
                  Text(
                    'الوجهة: قسنطينة، سطيف',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 160,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('التاريخ: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500)),
                      Text( DateFormat('yyyy/MM/dd').format(widget.departDate).toString(),
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF313131),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppTheme.lightTheme.textTheme
                                  .bodyMedium!.fontFamily)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('الأماكن المتبقية: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500)),
                      Text('12',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF313131),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppTheme.lightTheme.textTheme
                                  .bodyMedium!.fontFamily)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 200,
              right: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('المدة (باليوم): ',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              fontWeight: FontWeight.w500)),
                      Text(widget!.duration.toString(),
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF313131),
                              fontWeight: FontWeight.w300,
                              fontFamily: AppTheme.lightTheme.textTheme
                                  .bodyMedium!.fontFamily)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('السعر للشخص: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              color: Color(0xFF313131))),
                      Text('${widget.price.toString()} دج ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              color: Color(0xFF313131))),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
                left: 10,
                bottom: 10,
                child: InkWell(
                  onTap: () {
                    // Navigate to post details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetails(
                          postId: widget.postId,
                          isTrip: widget.isTrip,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(
                      4), // Set the border radius for the container
                  child: Container(
                    padding: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 8,
                        bottom: 5), // Add padding inside the container
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: BorderRadius.circular(
                          4), // Same border radius as the button
                      border: Border.all(color: Colors.green), // Border color
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ensures the row takes up only as much space as needed
                      children: [
                        Text(
                          'التفاصيل',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green, // Text color
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                          ),
                        ),
                        SizedBox(
                            width:
                                8), // Add space between the icon and the text

                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.green,
                          size: 11, // Icon color
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey[100],
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey[400],
      ),
    );
  }
}

Widget buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
