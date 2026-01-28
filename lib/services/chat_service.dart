import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled3/models/service_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or Create a chat between traveler and agency
  Future<String> getOrCreateChat({
    required String travelerId,
    required String agencyId,
    required String travelerName,
    required String agencyName,
    required String agencyImage,
  }) async {
    // Check if chat already exists
    final QuerySnapshot existingChats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: travelerId)
        .get();

    for (var doc in existingChats.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['participants'].contains(agencyId)) {
        return doc.id;
      }
    }

    // Create new chat if not exists
    final DocumentReference splitDoc = await _firestore.collection('chats').add({
      'participants': [travelerId, agencyId],
      'travelerId': travelerId,
      'agencyId': agencyId,
      'travelerName': travelerName,
      'agencyName': agencyName,
      'agencyImage': agencyImage,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': '',
    });

    return splitDoc.id;
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final timestamp = FieldValue.serverTimestamp();

    // Add message to subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    });

    // Update parent chat document with last message info
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': timestamp,
      'lastSenderId': senderId,
    });
  }

  // Stream messages for a specific chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Stream list of chats for a user
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
