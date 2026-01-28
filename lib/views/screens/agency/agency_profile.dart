import 'package:draggable_home/draggable_home.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/views/screens/agency/widgets/post_card.dart';

import '../../../providers/auth_provider.dart';

class AgencyProfile extends StatefulWidget {
  const AgencyProfile({Key? key}) : super(key: key);

  @override
  State<AgencyProfile> createState() => _AgencyProfileState();
}

class _AgencyProfileState extends State<AgencyProfile> {
  bool isTrips = true;
  Map<String, dynamic>? agencyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAgencyData();
  }

  Future<void> _fetchAgencyData() async {
    final userId =
        Provider.of<AuthService>(context, listen: false).currentUser!.uid;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('agencies')
          .doc(userId)
          .get();
      if (doc.exists) {
        setState(() {
          agencyData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching agency data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        Provider.of<AuthService>(context, listen: false).currentUser!.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      // body: isLoading
      //     ? Center(child: CircularProgressIndicator())
      //     : Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           ProfileHeader(
      //             agencyData: agencyData ?? {},
      //           ),
      //           AnimatedButtonBar(
      //             elevation: 0.0,
      //             radius: 5.0,
      //             padding: const EdgeInsets.only(
      //                 top: 5.0, bottom: 0, left: 16, right: 16),
      //             invertedSelection: true,
      //             backgroundColor: Color(0xFFFAFAFA),
      //             foregroundColor: AppTheme.lightTheme.colorScheme.primary,
      //             children: [
      //               ButtonBarEntry(
      //                   onTap: () {
      //                     setState(() {
      //                       isTrips = true;
      //                     });
      //                   },
      //                   child: Text(
      //                     'Trips',
      //                     textDirection: TextDirection.rtl,
      //                     style: TextStyle(
      //                       fontSize: 16,
      //                       // color: Color(0xFF313131).withOpacity(0.3),
      //                       // fontWeight: _selectedPeriod == 2 ? FontWeight.w700:  FontWeight.w400,
      //                       fontFamily: AppTheme
      //                           .lightTheme.textTheme.bodyMedium!.fontFamily,
      //                     ),
      //                   )),
      //               ButtonBarEntry(
      //                   onTap: () {
      //                     setState(() {
      //                       isTrips = false;
      //                     });
      //                   },
      //                   child: Text(
      //                     'Services',
      //                     style: TextStyle(
      //                       fontSize: 16,
      //                       // fontWeight: FontWeight.w600,
      //                       fontFamily: AppTheme
      //                           .lightTheme.textTheme.bodyMedium!.fontFamily,
      //                     ),
      //                   )),
      //             ],
      //           ),
      //           Expanded(
      //             child: isTrips
      //                 ? TripsTab(userId: userId)
      //                 : ServicesTab(userId: userId),
      //           ),
      //         ],
      //       ),
      body: DraggableHome(
        backgroundColor: Colors.white,
        appBarColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.translate('posts'),
          style: TextStyle(
            color: Colors.black,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add_post');
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
        headerWidget: ProfileHeader(
          agencyData: agencyData ?? {},
        ),

        body: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isTrips = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isTrips
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('trips'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isTrips ? Colors.white : Colors.grey[600],
                          fontSize: 16,
                          fontWeight:
                              isTrips ? FontWeight.w600 : FontWeight.normal,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isTrips = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isTrips
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('services'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !isTrips ? Colors.white : Colors.grey[600],
                          fontSize: 16,
                          fontWeight:
                              !isTrips ? FontWeight.w600 : FontWeight.normal,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                // Tab Bar

                // Content

                isTrips
                    ? TripsTab(userId: userId)
                    : ServicesTab(userId: userId),
              ],
            ),
          ),
        ],
        fullyStretchable: false,
        // expandedBody: Container(),
        curvedBodyRadius: 20,
      ),
    );
  }
}

class TripsTab extends StatefulWidget {
  final String userId;

  TripsTab({
    required this.userId,
  });

  @override
  _TripsTabState createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  Map<String, dynamic>? agencyData;
  // removed duplicate

  @override
  void initState() {
    // TODO: implement initState
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
        if (mounted) {
            setState(() {
            agencyData = doc.data();
            });
        }
      } catch (e) {
        print('Error fetching agency data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
      limit: 5,
      viewType: ViewType.list,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      query: FirebaseFirestore.instance
          .collection('trips')
          .where('agencyId',
              isEqualTo: Provider.of<AuthService>(context, listen: false)
                  .currentUser!
                  .uid)
          .orderBy('postedDate', descending: true), // Add ordering
      bottomLoader: const Center(
        //piotr raison
        // done when adding a post it has to go check if it has the permission
        // when it's 00:00 it will run a cloud function that will remove subscriptions
        // when deleting a payment verification it must save it in archive and delete the payment
        // when accepting a payment verification it must save it in archive and delete the payment
        //      and then create the subscription
        // when deleting a subscription it must save it in archive and delete the subscription

        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.blue,
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {
        // Access the document snapshot correctly
        final doc = documentSnapshots[index];
        // Get the data as a Map
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) return Container();

        // Convert Timestamp to DateTime
        final departDate = data['departDate'] is Timestamp
            ? (data['departDate'] as Timestamp).toDate()
            : data['departDate'] as DateTime? ?? DateTime.now();
        final returnDate = data['returnDate'] is Timestamp
            ? (data['returnDate'] as Timestamp).toDate()
            : data['returnDate'] as DateTime? ?? DateTime.now();

        return PostCard(
          postId: doc.id, // Pass the post ID
          price: data['price'] ?? 0,
          agencyName: data['agencyName'] ?? '',
          destination: data['destination'] ?? '',
          date: data['date'] ?? '',
          availableSeats: data['availableSeats'] ?? 0,
          departDate: departDate,
          returnDate: returnDate,
          isTrip: true,
          duration: data['duration'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
          agencyImageUrl: data['agencyImageUrl'] ?? '',
          agencyData: agencyData ?? {}, // Pass agency data
          showLikeButton: false, 
        );
      },
      // Add empty state

      onEmpty: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/home_add_post.jpg',
              width: MediaQuery.of(context).size.width * 0.75,
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.translate('noPostsYet'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              ),
            ),
          ],
        ),
      ),
      // Add error handling
    );
  }
}

class ServicesTab extends StatefulWidget {
  final String userId;

  ServicesTab({required this.userId});

  @override
  _ServicesTabState createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  Map<String, dynamic>? agencyData;
  // removed duplicate

  @override
  void initState() {
    // TODO: implement initState
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
         if (mounted) {
            setState(() {
            agencyData = doc.data();
            });
         }
      } catch (e) {
        print('Error fetching agency data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
      limit: 5,
      viewType: ViewType.list,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      query: FirebaseFirestore.instance
          .collection('services')
          .where('agencyId',
              isEqualTo: Provider.of<AuthService>(context, listen: false)
                  .currentUser!
                  .uid)
          .orderBy('postedDate', descending: true), // Add ordering
      bottomLoader: const Center(
        //piotr raison
        // done when adding a post it has to go check if it has the permission
        // when it's 00:00 it will run a cloud function that will remove subscriptions
        // when deleting a payment verification it must save it in archive and delete the payment
        // when accepting a payment verification it must save it in archive and delete the payment
        //      and then create the subscription
        // when deleting a subscription it must save it in archive and delete the subscription

        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.blue,
        ),
      ),
      itemBuilder: (context, documentSnapshots, index) {
        // Access the document snapshot correctly
        final doc = documentSnapshots[index];
        // Get the data as a Map
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) return Container();

        // Convert Timestamp to DateTime
        final departDate = data['departDate'] is Timestamp
            ? (data['departDate'] as Timestamp).toDate()
            : data['departDate'] as DateTime? ?? DateTime.now();
        final returnDate = data['returnDate'] is Timestamp
            ? (data['returnDate'] as Timestamp).toDate()
            : data['returnDate'] as DateTime? ?? DateTime.now();

        return PostCard(
          postId: doc.id, // Pass the post ID
          price: data['price'] ?? 0,
          agencyName: data['agencyName'] ?? '',
          destination: data['destination'] ?? '',
          date: data['date'] ?? '',
          departDate: departDate,
          returnDate: returnDate,
          isTrip: false, // Services are not trips
          availableSeats: data['availableSeats'] ?? 0,
          duration: data['duration'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
          agencyImageUrl: data['agencyImageUrl'] ?? '',
          agencyData: agencyData ?? {}, // Pass agency data
          showLikeButton: false,
        );
      },
      // Add empty state

      onEmpty: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/home_add_post.jpg',
              width: MediaQuery.of(context).size.width * 0.75,
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.translate('noPostsYet'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              ),
            ),
          ],
        ),
      ),
      // Add error handling
    );
  }
}

class ChangeAgencyInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.translate('changeAgencyInfos')),
      ),
      body: Center(
        child: Text(
            AppLocalizations.of(context)!.translate('changeAgencyInfosPage')),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> agencyData;

  ProfileHeader({required this.agencyData});

  @override
  Widget build(BuildContext context) {
    final hasBlueBadge = agencyData['hasBlueBadge'] ?? false;
    final agencyName = agencyData['agencyName'] ?? '';
    final profileImageUrl = agencyData['profilePictureUrl'] ?? '';
    final profileCoverPictureUrl = agencyData['profileCoverPictureUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Cover Image
              Container(
                width: double.infinity,
                height: 110,
                child: profileCoverPictureUrl.isNotEmpty
                    ? Image.network(
                        profileCoverPictureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFFEEEEEE),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Color(0xFFEEEEEE),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                      ),
              ),

              // Profile Picture
              Positioned(
                bottom: -40,
                child: ClipOval(
                  child: Image.network(
                    profileImageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),

          // Agency Name and Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                agencyName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              if (hasBlueBadge)
                Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 24,
                ),
            ],
          ),
          SizedBox(height: 15),

          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/agency_edit_profile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      overlayColor: Colors.transparent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                            color: Color(0xFF313131).withOpacity(0.2)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate('editAgencyInfo'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF313131).withAlpha(200),
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: 10,),
        ],
      ),
    );
  }
}
