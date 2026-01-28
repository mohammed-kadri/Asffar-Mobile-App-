import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/providers/auth_provider.dart';
import 'package:untitled3/services/auth_service.dart';

import '../../../theme/app_theme.dart';

class SubmitDocuments extends StatefulWidget {
  @override
  _SubmitDocumentsState createState() => _SubmitDocumentsState();
}

class _SubmitDocumentsState extends State<SubmitDocuments> {
  List<String> _imagePaths = List<String>.filled(3, '', growable: false);
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage(int index) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String? imagePath = await authService.pickImage();
    if (imagePath != null) {
      setState(() {
        _imagePaths[index] = imagePath;
      });
    }
  }

  Future<void> _submitDocuments(String folderName) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        print('Error: User is null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
        return;
      }

      List<String> imageUrls = [];

      // Check if at least one image is selected
      if (_imagePaths.every((path) => path.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .translate('pleaseSelectImages'))),
        );
        return;
      }

      for (int i = 0; i < _imagePaths.length; i++) {
        if (_imagePaths[i].isNotEmpty) {
          try {
            String imageUrl = await authService.uploadImage(
              _imagePaths[i],
              user.uid,
              'document_$i.jpg',
              folderName,
            );
            imageUrls.add(imageUrl);
          } catch (e) {
            print('Error uploading image $i: $e');
            throw e;
          }
        }
      }

      await authService.submitDocuments(
          user.uid, imageUrls, _textController.text);

      // Verify account only after successful document submission
      await Provider.of<AuthService>(context, listen: false)
          .verifyAgencyAccount(user.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('documentsSubmittedSuccessfully')),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error in _submitDocuments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('errorSubmittingDocuments')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context, listen: false);
    var user = authProvider.currentUser;

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
          AppLocalizations.of(context)!.translate('submitRequiredDocuments'),
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
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .translate('commercialRegisterImage'),
                            style:
                                TextStyle(
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                    color: Color(0xFF313131),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17)),
                        ElevatedButton(
                            onPressed: () async {
                              _pickImage(0);
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
                  SizedBox(
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .translate('tourismLicenseImage'),
                            style: TextStyle(
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                                color: Color(0xFF313131),
                                fontWeight: FontWeight.w700,
                                fontSize: 17)),
                        ElevatedButton(
                            onPressed: () {
                              _pickImage(1);
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
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 3; i++) ...[
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
                                  )),
                            ],
                          ),
                        ],
                        SizedBox(height: 20),
                      ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      textDirection: TextDirection.rtl,
                      controller: _textController,
                      maxLength: 200,
                      decoration: InputDecoration(
                        alignLabelWithHint:
                            true, // Aligns with the hint text if multiline
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF313131).withAlpha(200)),
                        ),
                        labelStyle: TextStyle(),
                        // labelText: 'Enter additional information',
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
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            _submitDocuments('documents_verification')
                                .then((_) async {
                              await Provider.of<AuthService>(context,
                                      listen: false)
                                  .verifyAgencyAccount(user?.uid ?? '');
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 17, bottom: 12),
                            child: Text(
                              AppLocalizations.of(context)!.translate('submit'),
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
                      ))
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
