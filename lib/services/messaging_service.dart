import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Stream<QuerySnapshot> messageStream(String userId) {
    return _firestore
        .collection('support_chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteMessage(String userId, String messageId) async {
    await _firestore
        .collection('support_chats')
        .doc(userId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
