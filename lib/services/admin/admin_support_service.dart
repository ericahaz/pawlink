part of pawlink_admin;

class AdminSupportService {
  AdminSupportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _supportRef =>
      _firestore.collection('support_messages');

  Stream<List<SupportMessage>> getSupportMessagesStream() {
    return _supportRef
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _supportMessageFromFirestore(doc)).toList();
    });
  }

  SupportMessage _supportMessageFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime time;
    final timeValue = data['time'];
    if (timeValue is Timestamp) {
      time = timeValue.toDate();
    } else if (timeValue is DateTime) {
      time = timeValue;
    } else if (timeValue is String) {
      time = DateTime.tryParse(timeValue) ?? DateTime.now();
    } else {
      time = DateTime.now();
    }

    return SupportMessage(
      id: doc.id,
      sender: data['sender']?.toString() ?? data['name']?.toString() ?? 'Anonymous',
      email: data['email']?.toString() ?? '',
      subject: data['subject']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      time: time,
      status: data['status']?.toString() ?? 'New',
    );
  }

  Future<void> updateSupportMessageStatus(String messageId, String status) async {
    await _supportRef.doc(messageId).update({
      'status': status,
    });
  }

  Future<void> deleteSupportMessage(String messageId) async {
    await _supportRef.doc(messageId).delete();
  }

  Future<void> addSupportMessage(SupportMessage message) async {
    await _supportRef.doc(message.id).set({
      'sender': message.sender,
      'email': message.email,
      'subject': message.subject,
      'message': message.message,
      'time': FieldValue.serverTimestamp(),
      'status': message.status,
    });
  }
}