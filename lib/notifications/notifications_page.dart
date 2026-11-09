
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<void> _markAsRead(String documentId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(documentId)
        .update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _markAllAsRead(
      List<QueryDocumentSnapshot> notifications) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final notification in notifications) {
      final data = notification.data() as Map<String, dynamic>;

      if (data['isRead'] != true) {
        batch.update(notification.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          elevation: 1,
        ),
        body: const Center(
          child: Text('Please log in to view notifications.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No notifications yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          final unreadCount = notifications.where((notification) {
            final data =
                notification.data() as Map<String, dynamic>;
            return data['isRead'] != true;
          }).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      unreadCount == 0
                          ? 'You are all caught up!'
                          : '$unreadCount unread notification(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: unreadCount == 0
                          ? null
                          : () async {
                              try {
                                await _markAllAsRead(notifications);
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Unable to mark notifications as read.',
                                    ),
                                  ),
                                );
                              }
                            },
                      child: const Text('Mark all as read'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final document = notifications[index];
                    final data =
                        document.data() as Map<String, dynamic>;

                    final event =
                        data['title'] ?? 'Notification';
                    final message = data['message'] ?? '';
                    final isRead = data['isRead'] == true;
                    final timestamp = data['createdAt'];

                    String dateText = '';

                    if (timestamp is Timestamp) {
                      dateText = timestamp
                          .toDate()
                          .toLocal()
                          .toString()
                          .substring(0, 16);
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      elevation: 2,
                      color: isRead
                          ? Colors.white
                          : Colors.deepPurple.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: isRead
                            ? null
                            : () async {
                                try {
                                  await _markAsRead(document.id);
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Unable to update notification.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: Colors.deepPurple,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                message.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              if (dateText.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (!isRead) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap to mark as read',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
