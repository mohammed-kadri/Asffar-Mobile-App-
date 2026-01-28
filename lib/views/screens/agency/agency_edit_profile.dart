import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/app_localizations.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';

class AgencyEditProfile extends StatefulWidget {
  @override
  _AgencyEditProfileState createState() => _AgencyEditProfileState();
}

class _AgencyEditProfileState extends State<AgencyEditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile(String userId) async {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text;

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('agencies')
          .doc(userId)
          .update({
        'phone': phone,
        if (_profileImage != null)
          'profileImageUrl': await _uploadProfileImage(userId),
      });

      // Update the AuthProvider
      Provider.of<AuthProvider>(context, listen: false).updateUserData({
        'phone': phone,
        if (_profileImage != null)
          'profilePictureUrl': await _uploadProfileImage(userId),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('profileUpdatedSuccessfully'))),
      );

      Navigator.of(context).pop();
    }
  }

  Future<String> _uploadProfileImage(String userId) async {
    // Implement your image upload logic here and return the image URL
    // For example, you can use Firebase Storage to upload the image and get the URL
    // This is a placeholder implementation
    return 'https://example.com/profile_image.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    final authProvider = Provider.of<AuthService>(context, listen: false);
    var user = authProvider.currentUser;

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
          AppLocalizations.of(context)!.translate('editProfile'),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('agencies')
            .doc(user!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
                child: Text(
                    AppLocalizations.of(context)!.translate('noDataFound')));
          }

          final agencyData = snapshot.data!.data() as Map<String, dynamic>;
          _phoneController.text = agencyData['phone'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    maxLength: 15,
                    decoration: InputDecoration(
                      counterText: '',
                      label: Text(
                          AppLocalizations.of(context)!
                              .translate('phoneNumber'),
                          // textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF313131).withAlpha(200),
                              fontFamily: AppTheme
                                  .lightTheme.textTheme.bodyMedium!.fontFamily),
                        ),
                      border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF313131).withAlpha(200)),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .translate('pleaseEnterPhoneNumber');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .uploadProfilePicture(context);
                    },
                    hoverColor: Colors.transparent,
                    child: Column(
                      children: [
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('changeProfilePicture'),
                              style: TextStyle(
                                color: Color(0xFF313131).withAlpha(200),
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium?.fontFamily,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 15),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(color: Colors.black.withAlpha(300), height: 0),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .uploadCoverPicture(context);
                    },
                    hoverColor: Colors.transparent,
                    child: Column(
                      children: [
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('changeCoverPicture'),
                              style: TextStyle(
                                color: Color(0xFF313131).withAlpha(200),
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium?.fontFamily,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 15),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(color: Colors.black.withAlpha(300), height: 0),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _updateProfile(user!.uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('confirm'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
