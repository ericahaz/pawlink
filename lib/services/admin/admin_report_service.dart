part of pawlink_admin;

class AdminReportService {
  AdminReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection('reports');

  Stream<List<AnimalReport>> getReportsStream() {
    return _reportsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _animalReportFromFirestore(doc)).toList();
    });
  }

  Stream<List<AnimalReport>> getReportsByTypeStream(String type) {
    return _reportsRef
        .where('type', isEqualTo: type.toLowerCase())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _animalReportFromFirestore(doc)).toList();
    });
  }

  Future<AnimalReport?> getReport(String reportId) async {
    final doc = await _reportsRef.doc(reportId).get();
    if (!doc.exists) return null;
    return _animalReportFromFirestore(doc);
  }

  AnimalReport _animalReportFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final type = data['type']?.toString() ?? 'unknown';
    final animalType = _getAnimalType(type);

    return AnimalReport(
      id: doc.id,
      type: type,
      animalType: animalType,
      petName: data['petName']?.toString() ?? data['name']?.toString() ?? '',
      breed: data['breed']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      sex: data['sex']?.toString() ?? '',
      reporter: data['reportedBy']?.toString() ??
          data['reporterEmail']?.toString() ??
          'Anonymous',
      location: data['location']?.toString() ??
          data['locationName']?.toString() ??
          data['lastSeenLocation']?.toString() ??
          data['foundLocation']?.toString() ??
          '',
      date: _formatDate(data['createdAt']),
      description: data['details']?.toString() ??
          data['description']?.toString() ??
          data['message']?.toString() ??
          '',
      photoLabel: data['photoUrl']?.toString() ?? '',
      petId: data['petId']?.toString(),
      status: data['status']?.toString() ?? 'active',
      qrScanned: data['petId'] != null && data['petId'].toString().isNotEmpty,
    );
  }

  String _getAnimalType(String type) {
    switch (type.toLowerCase()) {
      case 'lost':
      case 'found':
      case 'sighting':
        return 'Pet';
      case 'barangay':
      case 'stray':
        return 'Stray';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';

    if (value is Timestamp) {
      return _formatDateTime(value.toDate());
    }

    if (value is DateTime) {
      return _formatDateTime(value);
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return _formatDateTime(parsed);
      return value;
    }

    return '';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    await _reportsRef.doc(reportId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReport(String reportId) async {
    await _reportsRef.doc(reportId).delete();
  }

  Future<void> addReport(AnimalReport report) async {
    await _reportsRef.doc(report.id).set({
      'type': report.type,
      'petName': report.petName,
      'breed': report.breed,
      'color': report.color,
      'sex': report.sex,
      'reportedBy': report.reporter,
      'location': report.location,
      'details': report.description,
      'photoUrl': report.photoLabel,
      'petId': report.petId,
      'status': report.status,
      'qrScanned': report.qrScanned,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}