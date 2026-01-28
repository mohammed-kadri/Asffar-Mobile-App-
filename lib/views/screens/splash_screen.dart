import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/views/screens/agency/agency_navbar.dart';
import 'package:untitled3/views/screens/auth/login_traveler.dart';
import 'package:untitled3/views/screens/agency/home.dart';
import 'package:untitled3/views/screens/traveler/home.dart';

import 'auth/login_agency.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void startTimer() {
    Timer(
      Duration(seconds: 3),
      () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return StreamBuilder<User?>(
                stream: Provider.of<AuthProvider>(context, listen: false)
                    .authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final authProvider =
                        Provider.of<AuthService>(context, listen: false);
                    if (authProvider.currentUser != null) {
                      print('user took data ${authProvider.currentUser!.uid}');
                      return FutureBuilder<String?>(
                        future: _getUserType(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasData) {
                            final userType = snapshot.data;
                            if (userType == 'Traveler') {
                              return HomeTraveler();
                            } else if (userType == 'Agency') {
                              return AgencyNavbar();
                            } else {
                              return LoginAgency();
                            }
                          } else {
                            return LoginAgency();
                          }
                        },
                      );
                    } else {
                      return LoginAgency();
                    }
                  } else {
                    return LoginAgency();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_screen.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
