import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/app_localizations.dart';
import '../../../theme/app_theme.dart';

class SubmitPaymentConfirmation extends StatefulWidget {
  @override
  _SubmitPaymentConfirmationState createState() =>
      _SubmitPaymentConfirmationState();
}

class _SubmitPaymentConfirmationState extends State<SubmitPaymentConfirmation> {
  List<String> _imagePaths = List<String>.filled(5, '', growable: false);
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  late AuthService authService;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  var user;
  var data;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    authService = Provider.of<AuthService>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    user = authService.currentUser;
    print(user!.uid);
    data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  Future<void> _submitPictures(String folderName, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (user == null) {
        throw Exception('User not found');
      }

      List<String> imageUrls = [];
      for (int i = 0; i < _imagePaths.length; i++) {
        if (_imagePaths[i].isNotEmpty) {
          String imageUrl = await authService.uploadImage(
            _imagePaths[i],
            user.uid,
            'document_$i.jpg',
            folderName,
          );
          imageUrls.add(imageUrl);
        }
      }

      await FirebaseFirestore.instance
          .collection('payment_verification')
          .doc(user.uid)
          .set({
        'submittingDate': FieldValue.serverTimestamp(),
        'subscriptionType': data['selectedSubscriptionType'],
        'price': data['price'],
        'duration': data['selectedPeriod'],
        'couponId': data['couponId'] ?? '',
        'status': 'pending',
        'userId': user.uid,
        'additionalComment': _textController.text,
        'reviewed': false,
        'imageUrls': imageUrls,
        'adminFeedback': '',
      });

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/agency_navbar', (Route<dynamic> route) => false);
    } catch (e) {
      print('Error submitting payment verification: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب')),
      );
    }
  }

  Future<void> _pickImage(int index) async {
    String? imagePath = await authService.pickImage();
    if (imagePath != null) {
      setState(() {
        _imagePaths[index] = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          AppLocalizations.of(context)!
              .translate('sendPaymentConfirmationImages'),
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .translate('chooseImages'),
                          style: TextStyle(
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily,
                              color: Color(0xFF313131),
                              fontWeight: FontWeight.w700,
                              fontSize: 17),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              for (int i = 0; i < _imagePaths.length; i++) {
                                if (_imagePaths[i].isEmpty) {
                                  _pickImage(i);
                                  break;
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.translate('add'),
                              style: TextStyle(
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                                color: Color(0xFF313131).withAlpha(100),
                                fontWeight: FontWeight.w400,
                              ),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(
                      color: Color(0xFF313131).withOpacity(0.1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                      for (int i = 0; i < 5; i++) ...[
                        if (_imagePaths[i].isNotEmpty) ...[
                          Column(
                            children: [
                              Image.file(
                                File(_imagePaths[i]),
                                height: 100,
                                width: 100,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _imagePaths[i] = '';
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('delete'),
                                  style: TextStyle(
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _textController,
                      maxLength: 200,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF313131).withAlpha(200)),
                        ),
                        labelStyle: TextStyle(),
                        label: Text(
                          AppLocalizations.of(context)!
                              .translate('enterAdditionalInfo'),
                          style: TextStyle(
                              fontSize: 17,
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Check if any image is selected
                              if (_imagePaths.every((path) => path.isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .translate('pleaseSelectImages'),
                                      style: TextStyle(
                                        fontFamily: AppTheme.lightTheme
                                            .textTheme.bodyMedium!.fontFamily,
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              _submitPictures('payment_verification', context)
                                  .then((_) {
                                QuickAlert.show(
                                    context: context,
                                    confirmBtnText:
                                        AppLocalizations.of(context)!
                                            .translate('done'),
                                    confirmBtnColor:
                                        AppTheme.lightTheme.primaryColor,
                                    type: QuickAlertType.success,
                                    text: AppLocalizations.of(context)!
                                        .translate('paymentConfirmationSent'),
                                    title: AppLocalizations.of(context)!
                                        .translate('success'));
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: 17, bottom: 12),
                              child: Text(
                                AppLocalizations.of(context)!.translate('send'),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
