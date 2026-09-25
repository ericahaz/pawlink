import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // CREATE LOST PET REPORT
  // ============================================================

  Future<String> createLostPetReport({
    required String petId,
    required String petName,
    required String lastSeenLocation,
    required String details,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to report a lost pet.');
    }

    final document = _reports.doc();

    final now = FieldValue.serverTimestamp();

    await document.set({
      'reportId': document.id,
      'type': 'lost',

      'petId': petId.isEmpty ? null : petId,
      'petName': petName,

      'title': 'Lost Pet',
      'name': petName,

      'location': lastSeenLocation,
      'lastSeenLocation': lastSeenLocation,

      'details': details,

      'foundLocation': null,
      'locationName': null,

      'foundDate': null,
      'message': null,
      'photoUrl': '',

      'reportedBy': user.uid,
      'reporterEmail': user.email,

      'status': 'active',

      'latitude': latitude,
      'longitude': longitude,

      'createdAt': now,
      'updatedAt': now,
    });

    return document.id;
  }

  // ============================================================
  // CREATE FOUND PET REPORT
  // ============================================================

  Future<String> createFoundPetReport({
    required String petId,
    required String petName,
    required String foundLocation,
    required String foundDate,
    required String message,
    double? latitude,
    double? longitude,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;

    final document = _reports.doc();

    final now = FieldValue.serverTimestamp();

    await document.set({
      'reportId': document.id,
      'type': 'found',

      'petId': petId.isEmpty ? null : petId,
      'petName': petName,

      'title': 'Found Pet',
      'name': petName,

      'location': foundLocation,
      'foundLocation': foundLocation,

      'lastSeenLocation': null,
      'locationName': null,

      'details': message,

      'foundDate': foundDate,
      'message': message,

      'photoUrl': photoUrl ?? '',

      'reportedBy': user?.uid,
      'reporterEmail': user?.email,

      'status': 'active',

      'latitude': latitude,
      'longitude': longitude,

      'createdAt': now,
      'updatedAt': now,
    });

    return document.id;
  }

  // ============================================================
  // CREATE PET SIGHTING REPORT
  // ============================================================

  Future<String> createSightingReport({
    required String petName,
    required String locationName,
    required String details,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to report a pet sighting.');
    }

    final document = _reports.doc();

    final now = FieldValue.serverTimestamp();

    await document.set({
      'reportId': document.id,
      'type': 'sighting',

      'petId': null,
      'petName': petName,

      'title': 'Pet Sighting',
      'name': petName,

      'location': locationName,
      'locationName': locationName,

      'lastSeenLocation': null,
      'foundLocation': null,

      'details': details,

      'foundDate': null,
      'message': null,
      'photoUrl': '',

      'reportedBy': user.uid,
      'reporterEmail': user.email,

      'status': 'active',

      'latitude': latitude,
      'longitude': longitude,

      'createdAt': now,
      'updatedAt': now,
    });

    return document.id;
  }

  // ============================================================
  // CREATE BARANGAY REPORT
  // ============================================================

  Future<String> createBarangayReport({
    required String title,
    required String location,
    required String details,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to submit a barangay report.');
    }

    final document = _reports.doc();

    final now = FieldValue.serverTimestamp();

    await document.set({
      'reportId': document.id,
      'type': 'barangay',

      'petId': null,
      'petName': null,

      'title': title,
      'name': title,

      'location': location,

      'lastSeenLocation': null,
      'foundLocation': null,
      'locationName': null,

      'details': details,

      'foundDate': null,
      'message': details,
      'photoUrl': '',

      'reportedBy': user.uid,
      'reporterEmail': user.email,

      'status': 'active',

      'latitude': latitude,
      'longitude': longitude,

      'createdAt': now,
      'updatedAt': now,
    });

    return document.id;
  }

  // ============================================================
  // MY REPORTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyReportsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _reports.where('reportedBy', isEqualTo: user.uid).snapshots();
  }

  // ============================================================
  // MY REPORT COUNT
  // ============================================================

  Stream<int> getMyReportsCountStream() {
    return getMyReportsStream().map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // COMMUNITY SIGHTINGS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getCommunitySightingsStream() {
    return _reports.where('type', isEqualTo: 'sighting').snapshots();
  }

  // ============================================================
  // COMMUNITY REPORTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getCommunityReportsStream() {
    return _reports.snapshots();
  }

  // ============================================================
  // FOUND REPORTS FOR USER'S PETS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getFoundReportsStream(
    List<String> petIds,
  ) {
    if (petIds.isEmpty) {
      return const Stream.empty();
    }

    final limitedPetIds = petIds.take(10).toList();

    return _reports
        .where('type', isEqualTo: 'found')
        .where('petId', whereIn: limitedPetIds)
        .snapshots();
  }

  // ============================================================
  // LOST REPORTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getLostReportsStream() {
    return _reports.where('type', isEqualTo: 'lost').snapshots();
  }

  // ============================================================
  // BARANGAY REPORTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getBarangayReportsStream() {
    return _reports.where('type', isEqualTo: 'barangay').snapshots();
  }

  // ============================================================
  // GET ONE REPORT
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getReport(
    String reportId,
  ) async {
    return _reports.doc(reportId).get();
  }

  // ============================================================
  // GET ONE REPORT STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getReportStream(
    String reportId,
  ) {
    return _reports.doc(reportId).snapshots();
  }

  // ============================================================
  // UPDATE REPORT
  // ============================================================

  Future<void> updateReport({
    required String reportId,
    required String location,
    required String details,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception('Report not found.');
    }

    final data = document.data() ?? {};

    final reportedBy = data['reportedBy']?.toString();

    if (reportedBy != user.uid) {
      throw Exception('You can only edit your own reports.');
    }

    final type = data['type']?.toString().toLowerCase();

    final updateData = <String, dynamic>{
      'location': location,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    switch (type) {
      case 'lost':
        updateData['lastSeenLocation'] = location;
        break;

      case 'found':
        updateData['foundLocation'] = location;
        updateData['message'] = details;
        break;

      case 'sighting':
        updateData['locationName'] = location;
        break;

      case 'barangay':
        updateData['message'] = details;
        break;
    }

    await _reports.doc(reportId).update(updateData);
  }

  // ============================================================
  // RESOLVE REPORT
  // ============================================================

  Future<void> resolveReport(String reportId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception('Report not found.');
    }

    final data = document.data() ?? {};

    final reportedBy = data['reportedBy']?.toString();

    if (reportedBy != user.uid) {
      throw Exception('You can only resolve your own reports.');
    }

    await _reports.doc(reportId).update({
      'status': 'resolved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REOPEN REPORT
  // ============================================================

  Future<void> reopenReport(String reportId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception('Report not found.');
    }

    final data = document.data() ?? {};

    final reportedBy = data['reportedBy']?.toString();

    if (reportedBy != user.uid) {
      throw Exception('You can only reopen your own reports.');
    }

    await _reports.doc(reportId).update({
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE REPORT
  // ============================================================

  Future<void> deleteReport(String reportId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception('Report not found.');
    }

    final data = document.data() ?? {};

    final reportedBy = data['reportedBy']?.toString();

    if (reportedBy != user.uid) {
      throw Exception('You can only delete your own reports.');
    }

    await _reports.doc(reportId).delete();
  }
}
