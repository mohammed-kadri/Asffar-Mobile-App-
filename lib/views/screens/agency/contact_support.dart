import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added import for FirebaseAuth
import 'package:untitled3/app_localizations.dart';
import '../../../services/messaging_service.dart';

import '../../../theme/app_theme.dart';

class ContactSupport extends StatefulWidget {
  const ContactSupport({super.key});

  @override
  State<ContactSupport> createState() => _ContactSupportState();
}

class _ContactSupportState extends State<ContactSupport> {
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
          AppLocalizations.of(context)!.translate('contactSupport'),
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
      body: contactSupportPlaceholder(),
    );
  }
}

class contactSupportPlaceholder extends StatefulWidget {
  const contactSupportPlaceholder({super.key});

  @override
  State<contactSupportPlaceholder> createState() =>
      _contactSupportPlaceholderState();
}

class _contactSupportPlaceholderState extends State<contactSupportPlaceholder> {
  final ScrollController _scrollController = ScrollController();
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Add listener to scroll controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(() {});
    });
  }

  // Add this to get userId
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Add this method in your _contactSupportPlaceholderState class
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';

    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main content scrollable
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            reverse: true,
            child: Padding(
              padding:
                  // xxk
                  EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.2,
              ),
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _messagingService.messageStream(userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final messages = snapshot.data!.docs;
                      if (messages.isEmpty) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Image.asset(
                                      'assets/images/contact_support.jpg'),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('welcomeSupport'),
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF313131),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('teamReplyTime'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF313131).withAlpha(100),
                                  fontFamily: AppTheme.lightTheme.textTheme
                                      .bodyMedium!.fontFamily,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                            )
                          ],
                        );
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        physics: ClampingScrollPhysics(),
                        reverse: true,
                        shrinkWrap: true,
                        // physics: NeverScrollableScrollPhysics(),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg =
                              messages[index].data() as Map<String, dynamic>;
                          final isMe = msg['senderId'] == userId;
                          final messageId =
                              messages[index].id; // Get the message ID

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: isMe
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => SimpleDialog(
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .translate('messageOptions'),
                                            style: TextStyle(
                                              fontFamily: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium!
                                                  .fontFamily,
                                            ),
                                          ),
                                          children: [
                                            SimpleDialogOption(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'messageDetails'),
                                                      style: TextStyle(
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'sentOn'),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          _formatTimestamp(msg[
                                                                  'timestamp']
                                                              as Timestamp?),
                                                          style: TextStyle(
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'message'),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          msg['text'] ?? '',
                                                          style: TextStyle(
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'close'),
                                                          style: TextStyle(
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.info_outline,
                                                        color: Colors.blue),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'viewDetails'),
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SimpleDialogOption(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'deleteMessage'),
                                                      style: TextStyle(
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'deleteMessageConfrim'),
                                                      style: TextStyle(
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'cancel'),
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await _messagingService
                                                              .deleteMessage(
                                                                  userId,
                                                                  messageId);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'delete'),
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily: AppTheme
                                                                .lightTheme
                                                                .textTheme
                                                                .bodyMedium!
                                                                .fontFamily,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline,
                                                        color: Colors.red),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Delete Message',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontFamily: AppTheme
                                                            .lightTheme
                                                            .textTheme
                                                            .bodyMedium!
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  : null,
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.7),

                                // width: MediaQuery.of(context).size.width * 0.7,
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.grey[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  msg['text'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Input row always at the bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (_controller.text.trim().isNotEmpty) {
                        await _messagingService
                            .sendMessage(
                          userId: userId,
                          text: _controller.text,
                        )
                            .then((_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                        });
                        _controller.clear();
                        _scrollController.animateTo(
                          0.0,
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.easeOut,
                        );
                        Future.delayed(Duration(milliseconds: 1000), () {
                          _scrollToBottom();
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Transform.rotate(
                        angle: 180 *
                            (3.141592653589793 /
                                180), // Convert 45 degrees to radians
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .translate('typeMessageHere'),
                      hintStyle: TextStyle(
                        color: Color(0xFF313131).withOpacity(0.5),
                        fontSize: 16,
                        fontFamily: AppTheme
                            .lightTheme.textTheme.bodyMedium!.fontFamily,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
