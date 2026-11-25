part of pawlink_admin;

class AdminActivityService {
  AdminActivityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _activitiesRef =>
      _firestore.collection('admin_activities');

  Stream<List<AdminActivity>> getActivitiesStream() {
    return _activitiesRef
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _adminActivityFromFirestore(doc)).toList();
    });
  }

  Future<void> logActivity(String action, String target, String adminName) async {
    await _activitiesRef.add({
      'action': action,
      'target': target,
      'admin': adminName,
      'time': FieldValue.serverTimestamp(),
    });
  }

  AdminActivity _adminActivityFromFirestore(
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

    return AdminActivity(
      action: data['action']?.toString() ?? '',
      target: data['target']?.toString() ?? '',
      time: time,
    );
  }
}