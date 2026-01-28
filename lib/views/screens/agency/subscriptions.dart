import 'dart:convert';
import 'dart:math';
import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/subscription_service.dart';
import 'package:untitled3/views/screens/agency/widgets/subscription_cards.dart';

import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  var couponApplied = false;
  var usedCouponId = '';
  var _selectedPeriod = 0;
  var _selectedSybscriptionType;

  var paymentVerificationObject = null;
  var paymentVerificationSent;
  var paymentVerificationStatus;
  var subscriptionObject;
  var subscriptionType;
  var paymentVerificationChecked = false;
  var subscriptionChecked = false;

  final TextEditingController _discountCodeController = TextEditingController();

  Map<String, dynamic> prices = {
    '1': {
      'starter': 0,
      'basic': 0,
      'silver': 0,
      'golden': 0,
    },
    '3': {
      'starter': 0,
      'basic': 0,
      'silver': 0,
      'golden': 0,
    },
    '12': {
      'starter': 0,
      'basic': 0,
      'silver': 0,
      'golden': 0,
    }
  };

  Map<String, dynamic> newPrices = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();
    _checkPaymentStatus();
    _checkSubscriptionStatus();
  }

  Future<void> _checkPaymentStatus() async {
    setState(() {
      paymentVerificationChecked = false; // Reset before checking
    });

    var user = Provider.of<AuthService>(context, listen: false).currentUser;
    final response = await http.get(Uri.parse(
        'https://checkpaymentverification-fnzltfhora-uc.a.run.app?userId=${user!.uid}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['exists']) {
        setState(() {
          paymentVerificationObject = data['data'];
          paymentVerificationStatus = data['data']['status'];
        });
      }
    }

    setState(() {
      paymentVerificationChecked = true;
    });
  }

  Future<void> _checkSubscriptionStatus() async {
    setState(() {
      subscriptionChecked = false; // Reset before checking
    });

    try {
      var user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) {
        print('User is null, cannot check subscription status.');
        return;
      }

      final subscriptionResponse = await http.get(Uri.parse(
          'https://checksubscription-fnzltfhora-uc.a.run.app?userId=${user.uid}'));

      if (subscriptionResponse.statusCode == 200) {
        final subscriptionData = json.decode(subscriptionResponse.body);
        if (subscriptionData != null && subscriptionData['data'] != null) {
          setState(() {
            subscriptionObject = subscriptionData['data'];
            subscriptionType = subscriptionData['data']['type'];
          });
        }
      }

      setState(() {
        subscriptionChecked = true;
      });
    } catch (e) {
      print('Error checking subscription status: $e');
      setState(() {
        subscriptionChecked = true;
      });
    }
  }

  Future<void> _loadPrices() async {
    final subscriptionService = SubscriptionService();
    final loadedPrices = await subscriptionService.getSubscriptionPrices();
    if (loadedPrices != null) {
      setState(() {
        prices = loadedPrices;
      });
      print(prices);
    }
  }

  Future<void> _applyCoupon() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: _discountCodeController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot couponDoc = querySnapshot.docs.first;
        Timestamp endDate = couponDoc['endDate'];
        if (endDate.toDate().isAfter(DateTime.now())) {
          setState(() {
            newPrices = couponDoc['newPrices'];
            couponApplied = true;
            _discountCodeController.text = '';
            usedCouponId = couponDoc.id;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.translate('couponExpired'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('invalidCoupon'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print('Error applying coupon: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  String _getEndDate(DateTime startDate, int duration) {
    DateTime endDate;
    switch (duration) {
      case 1:
        endDate = startDate.add(Duration(days: 30));
        break;
      case 3:
        endDate = startDate.add(Duration(days: 90));
        break;
      case 12:
        endDate = startDate.add(Duration(days: 365));
        break;
      default:
        endDate = startDate;
    }
    return _formatDate(endDate);
  }

  String getDurationText(int duration) {
    switch (duration) {
      case 0:
        return AppLocalizations.of(context)!.translate('month');
      case 1:
        return AppLocalizations.of(context)!.translate('sixMonths');
      case 2:
        return AppLocalizations.of(context)!.translate('year');
      default:
        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {

    priceGetter(String duration, String subscriptionType) {
      if (!couponApplied) {
        if (duration == "0") {
          switch (subscriptionType) {
            case 'starter':
              return prices['1']['starter'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['starter'];
              break;
            case 'basic':
              return prices['1']['basic'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['basic'];
              break;
            case 'silver':
              return prices['1']['silver'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['silver'];
              break;
            case 'golden':
              return prices['1']['golden'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "1") {
          switch (subscriptionType) {
            case 'starter':
              return prices['3']['starter'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['3']['starter'];
              break;
            case 'basic':
              return prices['3']['basic'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['3']['basic'];
              break;
            case 'silver':
              return prices['3']['silver'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['3']['silver'];
              break;
            case 'golden':
              return prices['3']['golden'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['3']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "2") {
          switch (subscriptionType) {
            case 'starter':
              return prices['12']['starter'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['12']['starter'];
              break;
            case 'basic':
              return prices['12']['basic'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['12']['basic'];
              break;
            case 'silver':
              return prices['12']['silver'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['12']['silver'];
              break;
            case 'golden':
              return prices['12']['golden'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['12']['golden'];
              break;
            default:
              return 0;
          }
        }
      } else {
        if (duration == "0") {
          switch (subscriptionType) {
            case 'starter':
              return prices['1']['starter'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['starter'];
              break;
            case 'basic':
              return prices['1']['basic'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['basic'];
              break;
            case 'silver':
              return prices['1']['silver'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['silver'];
              break;
            case 'golden':
              return prices['1']['golden'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['1']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "1") {
          switch (subscriptionType) {
            case 'starter':
              return newPrices['3']['starter'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : newPrices['3']['starter'];
              break;
            case 'basic':
              return newPrices['3']['basic'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : newPrices['3']['basic'];
              break;
            case 'silver':
              return newPrices['3']['silver'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : newPrices['3']['silver'];
              break;
            case 'golden':
              return newPrices['3']['golden'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : prices['3']['golden'];
              break;
            default:
              return 0;
          }
        } else if (duration == "2") {
          switch (subscriptionType) {
            case 'starter':
              return newPrices['12']['starter'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : newPrices['12']['starter'];
              break;
            case 'basic':
              return newPrices['12']['basic'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : newPrices['12']['basic'];
              break;
            case 'silver':
              return newPrices['12']['silver'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : newPrices['12']['silver'];
              break;
            case 'golden':
              return newPrices['12']['golden'] == 0
                  ? AppLocalizations.of(context)!.translate('loading')
                  : newPrices['12']['golden'];
              break;
            default:
              return 0;
          }
        }
      }
    }

    // Add these helper methods to your _SubscribePageState class:
    String _formatDateFromTimestamp(dynamic timestamp) {
      if (timestamp == null) return '--/--/--';

      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is Map) {
        date =
            DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
      } else {
        return '--/--/--';
      }
      return '${date.year}/${date.month}/${date.day}';
    }

    String _getEndDateFromTimestamp(dynamic timestamp, int duration) {
      DateTime startDate;
      if (timestamp is Map) {
        startDate =
            DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
      } else {
        startDate = DateTime.now();
      }

      DateTime endDate;
      switch (duration) {
        case 0:
          endDate = startDate.add(Duration(days: 30));
          break;
        case 1:
          endDate = startDate.add(Duration(days: 90));
          break;
        case 2:
          endDate = startDate.add(Duration(days: 365));
          break;
        default:
          endDate = startDate;
      }
      return '${endDate.year}/${endDate.month}/${endDate.day}';
    }

    List<Widget> testcard = buildSubscriptionCards(
        selectedSubscriptionType: _selectedSybscriptionType,
        onSubscriptionSelect: (type) {
          setState(() {
            _selectedSybscriptionType = type;
          });
        },
        priceGetter: priceGetter,
        selectedPeriod: _selectedPeriod,
        context: context);

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    Widget subscriptionStatus() {
      if (subscriptionChecked == true && paymentVerificationChecked == true) {
        if (subscriptionType == 'free') {
          if (paymentVerificationObject == null) {
            // show coupon and stuff like nothing is paied
            return !couponApplied
                ? Column(
                    children: [
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0.1,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: Color(0xFF141414).withOpacity(0.12),
                              width: 0.4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Header text
                              Text(
                                AppLocalizations.of(context)!
                                    .translate('enterDiscountCode'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),

                              // Discount code text field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextField(
                                  controller: _discountCodeController,
                                  enableSuggestions: false,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    hintText: '...',
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Apply button
                              SizedBox(
                                width: 200,
                                child: OutlinedButton(
                                  onPressed: _applyCoupon,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('apply'),
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppTheme.lightTheme.textTheme
                                          .bodyMedium!.fontFamily,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 0.2,
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Color(0xFF141414).withOpacity(0.12),
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('freeMonthFrom6'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Second option card

                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.white,
                        elevation: 0.1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Color(0xFF141414).withOpacity(0.12),
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('free3MonthsFrom12'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Bottom navigation buttons
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            // Back button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Handle back navigation
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 17, bottom: 15),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('back'),
                                  style: TextStyle(
                                    color: Color(0xFF313131).withAlpha(200),
                                    height: 1,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Continue button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final user = Provider.of<AuthService>(context,
                                          listen: false)
                                      .currentUser;

                                  if (user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)!
                                              .translate('userNotFound'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme
                                                .lightTheme
                                                .textTheme
                                                .bodyMedium!
                                                .fontFamily,
                                          ),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    return;
                                  }

                                  final doc = await FirebaseFirestore.instance
                                      .collection('payment_verification')
                                      .doc(user.uid)
                                      .get();

                                  if (doc.exists) {
                                    final status = doc['status'];
                                    if (status == 'approved') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'subscriptionInProcess'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    } else if (status == 'pending') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'verificationPending'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (_selectedSybscriptionType != null &&
                                        prices['1']['golden'] != 0) {
                                      if (couponApplied == true) {
                                        Navigator.pushNamed(
                                            context, '/subscription_guide',
                                            arguments: {
                                              'selectedPeriod': _selectedPeriod,
                                              'selectedSubscriptionType':
                                                  _selectedSybscriptionType,
                                              'price': priceGetter(
                                                  _selectedPeriod.toString(),
                                                  _selectedSybscriptionType
                                                      .toString()),
                                              'couponId': usedCouponId,
                                            });
                                      } else {
                                        Navigator.pushNamed(
                                            context, '/subscription_guide',
                                            arguments: {
                                              'selectedPeriod': _selectedPeriod,
                                              'selectedSubscriptionType':
                                                  _selectedSybscriptionType,
                                              'price': priceGetter(
                                                  _selectedPeriod.toString(),
                                                  _selectedSybscriptionType
                                                      .toString())
                                            });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'chooseSubscriptionFirst'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 17, bottom: 15),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('continue'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    height: 1,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          child: Center(
                            child: Stack(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.green,
                                    highlightColor: Colors.lightGreen,
                                    child: Container(
                                      // width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 22.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('couponApplied'),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: AppTheme.lightTheme
                                            .textTheme.bodyMedium!.fontFamily,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        couponApplied = false;
                                        usedCouponId = '';
                                      });
                                    },
                                    child: Icon(
                                      Iconsax.close_circle5,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Navigation buttons (same as before)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('back'),
                                  style: TextStyle(
                                    color: Color(0xFF313131).withAlpha(200),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final user = Provider.of<AuthService>(context,
                                          listen: false)
                                      .currentUser;

                                  if (user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)!
                                              .translate('userNotFound'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme
                                                .lightTheme
                                                .textTheme
                                                .bodyMedium!
                                                .fontFamily,
                                          ),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    return;
                                  }

                                  final doc = await FirebaseFirestore.instance
                                      .collection('payment_verification')
                                      .doc(user.uid)
                                      .get();

                                  if (doc.exists) {
                                    final status = doc['status'];
                                    if (status == 'approved') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'subscriptionInProcess'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    } else if (status == 'pending') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'verificationPending'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (_selectedSybscriptionType != null &&
                                        prices['1']['golden'] != 0) {
                                      if (couponApplied == true) {
                                        Navigator.pushNamed(
                                            context, '/subscription_guide',
                                            arguments: {
                                              'selectedPeriod': _selectedPeriod,
                                              'selectedSubscriptionType':
                                                  _selectedSybscriptionType,
                                              'price': priceGetter(
                                                  _selectedPeriod.toString(),
                                                  _selectedSybscriptionType
                                                      .toString()),
                                              'couponId': usedCouponId,
                                            });
                                      } else {
                                        Navigator.pushNamed(
                                            context, '/subscription_guide',
                                            arguments: {
                                              'selectedPeriod': _selectedPeriod,
                                              'selectedSubscriptionType':
                                                  _selectedSybscriptionType,
                                              'price': priceGetter(
                                                  _selectedPeriod.toString(),
                                                  _selectedSybscriptionType
                                                      .toString())
                                            });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!
                                                .translate(
                                                    'chooseSubscriptionFirst'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('continue'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  );
          } else {
            // show payment details
            if (paymentVerificationStatus == 'pending') {
              return Container(
                margin: EdgeInsets.all(20),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Colors.blue.shade300.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150,
                        child: Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.blue.shade50.withOpacity(0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('underReview'),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                                SpinKitPouringHourGlass(
                                  color: Colors.blue.shade300,
                                  size: 30.0,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('paymentVerificationUnderReview'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                                color: Color(0xFF313131).withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 0),
                            // Row(
                            //   mainAxisAlignment:
                            //       MainAxisAlignment.center,
                            //   children: [
                            //     SpinKitThreeBounce(
                            //       color:
                            //           Colors.blue.shade300,
                            //       size: 20.0,
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (paymentVerificationStatus == 'refused') {
              return Container(
                margin: EdgeInsets.all(20),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Colors.red.shade300.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        child: Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.red.shade50.withOpacity(0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('requestRejected'),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red.shade400,
                                  size: 28,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  paymentVerificationObject['adminFeedback'] ??
                                      AppLocalizations.of(context)!
                                          .translate('noReasonProvided'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                    color: Colors.red.shade700,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final user = Provider.of<AuthService>(
                                            context,
                                            listen: false)
                                        .currentUser;
                                    if (user != null) {
                                      // First get the document data before deleting
                                      final verificationDoc =
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  'payment_verification')
                                              .doc(user.uid)
                                              .get();

                                      if (verificationDoc.exists) {
                                        // Create archived document with timestamp
                                        final archivedData = {
                                          ...verificationDoc
                                              .data()!, // Spread existing data
                                          'archivedAt':
                                              FieldValue.serverTimestamp(),
                                          'originalDocId': user.uid,
                                        };

                                        // Save to archived collection with nested structure
                                        await FirebaseFirestore.instance
                                            .collection(
                                                'archived_payment_verifications')
                                            .doc(user.uid)
                                            .collection('refused')
                                            .add(archivedData);

                                        // Then delete the original document
                                        await FirebaseFirestore.instance
                                            .collection('payment_verification')
                                            .doc(user.uid)
                                            .delete();

                                        // Reset local state
                                        setState(() {
                                          paymentVerificationObject = null;
                                          paymentVerificationStatus = null;
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(context)!
                                                  .translate(
                                                      'verificationCanceled'),
                                              style: TextStyle(
                                                fontFamily: AppTheme
                                                    .lightTheme
                                                    .textTheme
                                                    .bodyMedium!
                                                    .fontFamily,
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print(
                                        'Error archiving/canceling verification: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)!
                                              .translate(
                                                  'verificationCancelError'),
                                          style: TextStyle(
                                            fontFamily: AppTheme
                                                .lightTheme
                                                .textTheme
                                                .bodyMedium!
                                                .fontFamily,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('cancelAndRetry'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                    color: Colors.white,
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
              );
            }
          }
        } else {
          //show current subscription details
          return Container(
            margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Colors.yellow.shade600.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 270, // Increased height to accommodate new rows
                    child: Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.yellow.shade100.withOpacity(0.1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20.0, right: 20, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('currentSubscription'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                                color: Colors.yellow.shade700,
                              ),
                            ),
                            Icon(
                              Iconsax.crown5,
                              color: Colors.yellow.shade700,
                              size: 28,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildSubscriptionDetailRow(
                          AppLocalizations.of(context)!
                              .translate('subscriptionType'),
                          subscriptionObject['type'].toString().toUpperCase(),
                          Iconsax.wallet_check,
                        ),
                        SizedBox(height: 15),
                        _buildSubscriptionDetailRow(
                          AppLocalizations.of(context)!.translate('duration'),
                          getDurationText(subscriptionObject['duration'] ?? 0),
                          Iconsax.timer_1,
                        ),
                        SizedBox(height: 15),
                        _buildSubscriptionDetailRow(
                          AppLocalizations.of(context)!.translate('startDate'),
                          _formatDateFromTimestamp(
                              subscriptionObject['startDate']),
                          Iconsax.calendar_1,
                        ),
                        SizedBox(height: 15),
                        _buildSubscriptionDetailRow(
                          AppLocalizations.of(context)!.translate('endDate'),
                          _formatDateFromTimestamp(
                            subscriptionObject['endDate'],
                          ),
                          Iconsax.calendar_1,
                        ),
                        SizedBox(height: 15),
                        _buildSubscriptionDetailRow(
                          AppLocalizations.of(context)!.translate('status'),
                          AppLocalizations.of(context)!.translate('active'),
                          Icons.check_circle_outline_rounded,
                          valueColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        // show loader
        return SpinKitWave(
          color: AppTheme.lightTheme.primaryColor,
          size: 30.0,
        );
      }
      return SizedBox();
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: Color(0xFF313131).withOpacity(0.1),
                height: 1,
              )),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.translate('subscriptions'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          leading: IconButton(
            padding: const EdgeInsets.only(left: 12),
            splashRadius: 24,
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Reset states
              setState(() {
                paymentVerificationChecked = false;
                subscriptionChecked = false;
              });

              // Execute both checks simultaneously
              await Future.wait([
                _checkPaymentStatus(),
                _checkSubscriptionStatus(),
              ]);

              // Optional: Add a small delay to make the refresh feel more natural
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(), // Add this line

              // fit: FlexFit.loose,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: Row(children: [
                      Text(
                        AppLocalizations.of(context)!
                            .translate('chooseDuration'),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                            fontSize: 17,
                            color: Color(0xFF313131)),
                      )
                    ]),
                  ),

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
                            onTap: () => setState(() => _selectedPeriod = 2),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedPeriod == 2
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.translate('year'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedPeriod == 2
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: _selectedPeriod == 2
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedPeriod == 1
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('threeMonths'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedPeriod == 1
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: _selectedPeriod == 1
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = 0),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedPeriod == 0
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('month'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedPeriod == 0
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: _selectedPeriod == 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  CarouselSlider(
                    items: testcard,
                    options: CarouselOptions(
                        // enlargeFactor: 1.2,
                        height: 350.0,
                        viewportFraction: 0.7,
                        pageSnapping: false,
                        padEnds: false,
                        enableInfiniteScroll: false,
                        disableCenter: true,
                        initialPage: 0
                        // reverse: true,
                        // enlargeCenterPage: true,
                        // padEnds: false,
                        // enableInfiniteScroll: false
                        ),
                  ),
                  const SizedBox(height: 0),
                  subscriptionStatus(),
                ],
              ),
            ),
          ),
        ));
  }
}

Widget _buildSubscriptionDetailRow(String label, String value, IconData icon,
    {Color? valueColor}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Color(0xFF313131).withOpacity(0.7),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              color: Color(0xFF313131).withOpacity(0.7),
            ),
          ),
        ],
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          color: valueColor ?? Color(0xFF313131),
        ),
      ),
    ],
  );
}
