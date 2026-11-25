part of pawlink_admin;

class AdminNotificationService {
  AdminNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('admin_notifications');

  Stream<List<AdminNotification>> getNotificationsStream() {
    return _notificationsRef
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _adminNotificationFromFirestore(doc)).toList();
    });
  }

  Future<void> addNotification(AdminNotification notification) async {
    await _notificationsRef.doc(notification.id).set({
      'title': notification.title,
      'message': notification.message,
      'time': FieldValue.serverTimestamp(),
      'pageIndex': notification.pageIndex,
      'read': notification.read,
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({
      'read': true,
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRef.doc(notificationId).delete();
  }

  AdminNotification _adminNotificationFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime time;
    final timeValue = data['time'];
    if (timeValue is Timestamp) {
      time = timeValue.toDate();
    } else if (timeValue is DateTime) {
      time = timeValue;
    } else {
      time = DateTime.now();
    }

    return AdminNotification(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      time: time,
      pageIndex: data['pageIndex'] is int ? data['pageIndex'] as int : int.tryParse(data['pageIndex']?.toString() ?? '') ?? 0,
      read: data['read'] == true,
    );
  }
}