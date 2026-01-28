import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/services/chat_service.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/shared/chat_screen.dart';
import 'package:intl/intl.dart';

class TravelerChatList extends StatelessWidget {
  const TravelerChatList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    final chatService = ChatService();

    if (user == null) {
      return const Center(child: Text('Please log in to view messages'));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly grey background for contrast
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getUserChats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد رسائل',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
             padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Determine current user role to show correct other party name/image
              // For Traveler: Show Agency Name/Image
              final String otherName = data['agencyName'] ?? 'Agency';
              final String? otherImage = data['agencyImage'];
              
              final timestamp = data['lastMessageTime'] as Timestamp?;
              final timeString = timestamp != null 
                  ? DateFormat('dd/MM HH:mm').format(timestamp.toDate()) 
                  : '';

              return ListTile(
                tileColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: otherImage != null && otherImage.isNotEmpty
                      ? NetworkImage(otherImage)
                      : null,
                  child: otherImage == null || otherImage.isEmpty
                      ? Icon(Icons.business, color: Colors.grey[400])
                      : null,
                ),
                title: Text(
                  otherName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
                subtitle: Text(
                  data['lastMessage'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                  ),
                ),
                trailing: Text(
                  timeString,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: doc.id,
                        otherUserName: otherName,
                        otherUserImage: otherImage,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
