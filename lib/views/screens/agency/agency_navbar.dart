import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/agency/agency_profile.dart';
import 'package:untitled3/views/screens/agency/home.dart';
import 'package:untitled3/views/screens/agency/messages.dart';
import 'package:untitled3/views/screens/agency/statistics.dart';
import 'package:untitled3/views/screens/agency/submit_documents.dart';
import 'package:untitled3/views/screens/agency/add_post.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../services/auth_service.dart';

class AgencyNavbar extends StatefulWidget {
  @override
  _AgencyNavbarState createState() => _AgencyNavbarState();
}

class _AgencyNavbarState extends State<AgencyNavbar> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  late final HomeAgency homeAgency;
  late final List<Widget> _pages;
  final PageStorageBucket _bucket = PageStorageBucket();

    @override
  void initState() {
    super.initState();
    // Initialize _homeAgency in initState
    homeAgency = HomeAgency(key: const PageStorageKey('Home'));
    _pages = [
      homeAgency,
      Statistics(),
      Messages(),
      AgencyProfile(),
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return AppLocalizations.of(context)!.translate('home');
      case 1:
        return AppLocalizations.of(context)!.translate('statistics');
      case 2:
        return AppLocalizations.of(context)!.translate('messages');
      case 3:
        return AppLocalizations.of(context)!.translate('agencyProfile');
      default:
        return AppLocalizations.of(context)!.translate('home');
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var isConnected = false;
      // Check internet connection
      // var result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 1));
      isConnected = await InternetConnectionChecker.instance.hasConnection
          .whenComplete(() {
        if (isConnected) {}
      });

      if (isConnected) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushNamed(context, '/subscriptions');

        // // Internet connection is available
        // final user =
        //     Provider.of<AuthService>(context, listen: false).currentUser;
        // if (user == null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         "User not found",
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 16,
        //           fontWeight: FontWeight.w500,
        //           fontFamily:
        //               AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
        //         ),
        //       ),
        //       backgroundColor: Colors.redAccent,
        //       duration: Duration(seconds: 1),
        //     ),
        //   );
        //   return;
        // }
        //
        // // Call the Google Cloud Function
        // final response = await http.get(Uri.parse(
        //     'https://checkpaymentverification-fnzltfhora-uc.a.run.app?userId=${user.uid}'));
        //
        // if (response.statusCode == 200) {
        //   final data = json.decode(response.body);
        //   if (data['exists']) {
        //     final status = data['data']['status'];
        //     if (status == 'approved') {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(
        //           content: Text(
        //             "You already have a subscription in process",
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 16,
        //               fontWeight: FontWeight.w500,
        //               fontFamily:
        //                   AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
        //             ),
        //           ),
        //           backgroundColor: Colors.redAccent,
        //           duration: Duration(seconds: 1),
        //         ),
        //       );
        //
        //       Navigator.pushNamed(context, '/subscriptions', arguments: data);
        //
        //     } else if (status == 'pending') {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(
        //           content: Text(
        //             "Your payment verification is still under process",
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 16,
        //               fontWeight: FontWeight.w500,
        //               fontFamily:
        //                   AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
        //             ),
        //           ),
        //           backgroundColor: Colors.redAccent,
        //           duration: Duration(seconds: 1),
        //         ),
        //       );
        //       Navigator.pushNamed(context, '/subscriptions', arguments: data);
        //     }
        //   } else {
        //     Navigator.pushNamed(context, '/subscriptions', arguments: data);
        //   }
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         "Failed to check subscription status",
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 16,
        //           fontWeight: FontWeight.w500,
        //           fontFamily:
        //               AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
        //         ),
        //       ),
        //       backgroundColor: Colors.redAccent,
        //       duration: Duration(seconds: 1),
        //     ),
        //   );
        // }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No internet connection",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              ),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } on SocketException catch (_) {
      // No internet connection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No internet connection",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.translate('menu'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(
                AppLocalizations.of(context)!.translate('home'),
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 16,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text(
                AppLocalizations.of(context)!.translate('statistics'),
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 16,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text(
                AppLocalizations.of(context)!.translate('addPost'),
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 16,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/add_post');
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(
                AppLocalizations.of(context)!.translate('changeLanguage'),
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 16,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/change_language');
              },
            ),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text(
                AppLocalizations.of(context)!.translate('contactSupport'),
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 16,
                  fontFamily:
                  AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/contact_support');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                AppLocalizations.of(context)!.translate('logout'),
                style: TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 16,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              onTap: () async {
                await Provider.of<AuthService>(context, listen: false)
                    .signOut(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Color(0xFF313131).withOpacity(0.1),
              height: 1,
            )),
        title: Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(appBarTitle,
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              )),
        )),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.crown5,
              color: Colors.yellow,
              size: 26,
            ),
            onPressed: _checkSubscriptionStatus,
          ),
        ],
      ),
      body: Stack(
        children: [
          PageStorage(
            bucket: _bucket,
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: SpinKitChasingDots(
                  color: AppTheme.lightTheme.primaryColor,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppTheme.lightTheme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            rippleColor: Colors.white,
            color: Colors.white,
            textStyle: TextStyle(color: Colors.white),
            iconSize: 24,
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Colors.white.withAlpha(100),
            tabs: [
              GButton(
                textColor: Colors.white,
                icon: _selectedIndex == 0 ? Iconsax.home5 : Iconsax.home,
                text: AppLocalizations.of(context)!.translate('home'),
                textStyle: TextStyle(
                    color: Colors.white,
                    height: 2.1,
                    fontWeight: FontWeight.w900,
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily),
              ),
              GButton(
                icon:
                    _selectedIndex == 1 ? Iconsax.activity5 : Iconsax.activity,
                text: AppLocalizations.of(context)!.translate('statistics'),
                textStyle: TextStyle(
                    color: Colors.white,
                    height: 2.1,
                    fontWeight: FontWeight.w900,
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily
                ),
              ),
              GButton(
                icon: _selectedIndex == 2
                    ? Iconsax.messages_25
                    : Iconsax.messages_2,
                text: AppLocalizations.of(context)!.translate('messages'),
                textStyle: TextStyle(
                    color: Colors.white,
                    height: 2.1,
                    fontWeight: FontWeight.w900,
                    fontFamily:
                     AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily),
              ),
              GButton(
                icon: _selectedIndex == 3
                    ? Iconsax.profile_circle5
                    : Iconsax.profile_circle,
                iconSize: _selectedIndex == 3 ? 26 : 25,
                text: AppLocalizations.of(context)!.translate('profile'),
                textStyle: TextStyle(
                    color: Colors.white,
                    height: 2.1,
                    fontWeight: FontWeight.w900,
                    fontFamily:
                        AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
