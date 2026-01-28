import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:untitled3/views/screens/agency/agency_navbar.dart';
import 'package:untitled3/views/screens/agency/home.dart';
import 'package:untitled3/views/screens/traveler/home.dart';
import 'package:untitled3/views/screens/auth/login_traveler.dart';

import '../models/user_model.dart';
import '../theme/app_theme.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> login(String email, String password, String expectedUserType,
      BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;

      // Check both collections for the user type
      DocumentSnapshot? userDoc;
      String? userType;

      // Check in travelers collection
      userDoc = await _firestore.collection('travelers').doc(user?.uid).get();
      if (userDoc.exists) {
        userType = 'Traveler';
      } else {
        // Check in agencies collection
        userDoc = await _firestore.collection('agencies').doc(user?.uid).get();
        if (userDoc.exists) {
          userType = 'Agency';
        }
      }

      if (userType == null) {
        await _auth.signOut();
        throw Exception('User type not found');
      }

      // Check if the user type matches the expected user type
      if (userType != expectedUserType) {
        await _auth.signOut();
        throw Exception('User type does not match');
      }

      return user;
    } catch (e) {
      print('Login error: $e');
      // Only show error if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'الإيميل أو كلمة المرور التي أدخلتها غير صحيحة. الرجاء المحاولة مرة أخرى..',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ));
      }
      return null;
    }
  }

  Future<User?> register(
      String email,
      String ownerName,
      String agencyName,
      String phone,
      String password,
      String userType,
      BuildContext context) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      await user?.updateDisplayName(agencyName);

      // Save user data to the appropriate Firestore collection
      await _firestore
          .collection(userType == 'Agency' ? 'agencies' : 'travelers')
          .doc(user?.uid)
          .set({
        'id': user?.uid,
        'agencyName': agencyName,
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
        'userType': userType,
        'emailVerified': false,
        'phoneVerified': false,
        'registrationTime': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      print('Registration error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${e.toString()}')));
      }
      return null;
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('agencies').doc(userId).update(data);
  }

  Future<DocumentSnapshot> getUserData(String userId, String userType) async {
    return await _firestore
        .collection(userType == 'Agency' ? 'agencies' : 'travelers')
        .doc(userId)
        .get();
  }

  Future<String?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }
/*
  Future<String> uploadImage(String filePath, String userId, String fileName,
      String folderName) async {
    File file = File(filePath);
    try {
      await _storage.ref('$folderName/$userId/$fileName').putFile(file);
      String downloadURL =
          await _storage.ref('$folderName/$userId/$fileName').getDownloadURL();
      return downloadURL;
    } catch (e) {
      print(e);
      throw Exception('File upload failed');
    }
  }
*/

  Future<String> uploadImage(String filePath, String userId, String fileName,
      String folderName) async {
    File file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File does not exist: $filePath');
    }

    try {
      print('Starting upload for file: $filePath');
      final ref = _storage.ref('$folderName/$userId/$fileName');
      final uploadTask = ref.putFile(file);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });

      await uploadTask;
      final downloadURL = await ref.getDownloadURL();
      print('Upload complete. Download URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Error in uploadImage: $e');
      throw Exception('File upload failed: $e');
    }
  }

  Future<void> submitDocuments(String userId, List<String> imageUrls,
      String documentsVerificationNote) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('agencies').doc(userId).get();
    await _firestore.collection('documents_verification').doc(userId).set({
      'submittedDate': FieldValue.serverTimestamp(),
      'registrationDate': userDoc['registrationTime'],
      'imageUrls': imageUrls,
      'documentsVerificationNote': documentsVerificationNote,
    });
    await _firestore
        .collection('agencies')
        .doc(userId)
        .update({'submittedDocuments': true});
  }

  Future<String> uploadProfilePicture(String filePath, String userId) async {
    File file = File(filePath);
    try {
      await _storage
          .ref('agencies_profile_pictures/$userId/profile_picture.jpg')
          .putFile(file);
      String downloadURL = await _storage
          .ref('agencies_profile_pictures/$userId/profile_picture.jpg')
          .getDownloadURL();
      return downloadURL;
    } catch (e) {
      print(e);
      throw Exception('Profile picture upload failed');
    }
  }

  Future<void> verifyEmail(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'تم إرسال رابط التحقق في بريدك الإلكتروني..',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<bool> checkEmailVerification(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // Reload user to get the latest info
      user = _auth.currentUser;
      if (user!.emailVerified) {
        // Update Firestore only if the email is verified
        await _firestore
            .collection('agencies')
            .doc(user.uid)
            .update({'emailVerified': true});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'تم تأكيد البريد الإلكتروني بنجاح..',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          backgroundColor: Colors.green,
        ));
        return true; // Email verification successful
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'لم يتم تأكيد البريد الإلكتروني بعد..',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ));
        return false; // Email verification failed
      }
    }
    return false; // No user found
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> verifyAgencyAccount(String agencyId) async {
    final url =
        'https://verifyagencyaccount-fnzltfhora-uc.a.run.app/?agencyId=$agencyId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Account verified successfully');
      } else {
        print('Failed to verify account: ${response.body}');
      }
    } catch (e) {
      print('Error verifying account: $e');
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut().then((value) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginTraveler()),
            (route) => false));
  }
}
