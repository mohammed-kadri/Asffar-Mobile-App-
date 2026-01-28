import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/app_localizations.dart';
import 'package:untitled3/services/auth_service.dart';
import 'package:untitled3/theme/app_theme.dart';
import 'package:untitled3/views/screens/agency/add_post.dart';
import 'package:untitled3/services/chat_service.dart';
import 'package:untitled3/views/screens/shared/chat_screen.dart';

class PostDetails extends StatefulWidget {
  final String postId;
  final bool isTrip;

  const PostDetails({
    Key? key,
    required this.postId,
    required this.isTrip,
  }) : super(key: key);

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _deletePost() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا المنشور؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'حذف',
              style: TextStyle(
                fontFamily:
                    AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final collection = widget.isTrip ? 'trips' : 'services';
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.postId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حذف المنشور بنجاح',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ أثناء الحذف: $e',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily:
                      AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'التفاصيل',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.isTrip ? 'trips' : 'services')
            .doc(widget.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ في تحميل البيانات'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('المنشور غير موجود'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final currentUser =
              Provider.of<AuthService>(context, listen: false).currentUser;
          final isOwner =
              currentUser != null && data['agencyId'] == currentUser.uid;

          // Convert Timestamp to DateTime
          final departDate = data['departDate'] is Timestamp
              ? (data['departDate'] as Timestamp).toDate()
              : data['departDate'] as DateTime? ?? DateTime.now();
          final returnDate = data['returnDate'] is Timestamp
              ? (data['returnDate'] as Timestamp).toDate()
              : data['returnDate'] as DateTime? ?? DateTime.now();

          // Use data from post if available, otherwise fetch/use separate call (optimized to use post data)
          final String agencyName = data['agencyName'] ?? '';
          final String agencyImage = data['agencyImageUrl'] ?? '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Image
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: data['mainImageUrl'] != null
                          ? Image.network(
                              data['mainImageUrl'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                      child: Icon(Icons.image,
                                          size: 60, color: Colors.grey)),
                            )
                          : Center(
                              child: Icon(Icons.image,
                                  size: 60, color: Colors.grey)),
                    ),
                  ),
                ),

                // Agency Info Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: agencyImage.isNotEmpty
                            ? Image.network(
                                agencyImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[200],
                                        child: Icon(Icons.person,
                                            color: Colors.grey)),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: Icon(Icons.person, color: Colors.grey)),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agencyName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                              ),
                            ),
                            Text(
                              'الوجهة: ${data['destination'] ?? ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Section
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('السعر للشخص', '${data['price'] ?? 0}DA',
                          isPrice: true),

                      if (widget.isTrip) ...[
                        _buildDetailRow('تاريخ الانطلاق',
                            DateFormat('dd/MM/yyyy').format(departDate)),
                        _buildDetailRow('المدة (باليوم)',
                            '${data['duration'] ?? data['period'] ?? 0}'),
                        _buildDetailRow('تاريخ العودة',
                            DateFormat('dd/MM/yyyy').format(returnDate)),
                        _buildDetailRow(
                            'أماكن الزيارة',
                            data['places'] is List
                                ? (data['places'] as List).join(', ')
                                : (data['places'] ?? data['hotelName'] ?? 'نعم')
                                    .toString()), // Adjusted key
                        _buildDetailRow('الإقامة', data['hotelName'] ?? 'نعم'),
                        _buildDetailRow('عدد المشتركين حاليا',
                            '${data['subscribers'] ?? 0}'), // Adjusted key approximation
                        _buildDetailRow('الأماكن المتبقية',
                            '${data['availablePlaces'] ?? data['availableSeats'] ?? 0}'),
                        _buildDetailRow(
                            'عائلي', data['family'] == true ? 'نعم' : 'لا'),
                      ] else ...[
                        _buildDetailRow('النوع', data['type'] ?? ''),
                        _buildDetailRow('الدولة', data['country'] ?? ''),
                        if (data['visaType'] != null)
                          _buildDetailRow(
                              'نوع التأشيرة', data['visaType'] ?? ''),
                      ],

                      SizedBox(height: 20),
                      Text(
                        'الوصف:',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTheme
                              .lightTheme.textTheme.bodyMedium!.fontFamily,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['description'] ?? '',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                            fontFamily: AppTheme
                                .lightTheme.textTheme.bodyMedium!.fontFamily,
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // Action Buttons
                      if (isOwner)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _deletePost,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  side: BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  'حذف',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPost(
                                        postId: widget.postId,
                                        isTrip: widget.isTrip,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  'تعديل',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppTheme.lightTheme.textTheme
                                        .bodyMedium!.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (currentUser != null && !isOwner)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final chatService = ChatService();
                                final travelerName =
                                    'Traveler'; // Placeholder or fetch actual user name

                                final chatId =
                                    await chatService.getOrCreateChat(
                                  travelerId: currentUser.uid,
                                  agencyId: data['agencyId'],
                                  travelerName: travelerName,
                                  agencyName: agencyName,
                                  agencyImage: agencyImage,
                                );

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        chatId: chatId,
                                        otherUserName: agencyName,
                                        otherUserImage: agencyImage,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            icon: const Icon(Icons.chat_bubble_outline,
                                color: Colors.white),
                            label: Text(
                              'تواصل مع الوكالة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: AppTheme.lightTheme.textTheme
                                    .bodyMedium!.fontFamily,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: isPrice ? 16 : 14,
              fontWeight: isPrice ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black,
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF313131).withOpacity(0.6),
              fontFamily: AppTheme.lightTheme.textTheme.bodyMedium!.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
