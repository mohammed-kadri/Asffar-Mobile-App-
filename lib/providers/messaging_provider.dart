import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessagingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message to support
  Future<void> sendMessage({
    required String userId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    await _firestore
        .collection('support_chats')
        .doc(userId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream messages for a user
  Stream<QuerySnapshot> messageStream(String userId) {
    return _firestore
        .collection('support_chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}