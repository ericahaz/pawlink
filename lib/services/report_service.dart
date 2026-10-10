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
    String? locationName,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to report a lost pet.',
      );
    }

    final document = _reports.doc();
    final now = FieldValue.serverTimestamp();

    final cleanedLocationName = locationName?.trim();

    await document.set({
      'reportId': document.id,
      'type': 'lost',
      'petId': petId.isEmpty ? null : petId,
      'petName': petName.trim(),
      'title': 'Lost Pet',
      'name': petName.trim(),
      'location': lastSeenLocation.trim(),
      'lastSeenLocation': lastSeenLocation.trim(),
      'details': details.trim(),
      'foundLocation': null,
      'locationName': cleanedLocationName == null || cleanedLocationName.isEmpty
          ? null
          : cleanedLocationName,
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

  // Guests may submit found-pet reports.
  Future<String> createFoundPetReport({
    required String petId,
    required String petName,
    required String foundLocation,
    required String foundDate,
    required String message,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? locationName,
  }) async {
    final user = _auth.currentUser;

    final document = _reports.doc();
    final now = FieldValue.serverTimestamp();

    final cleanedLocationName = locationName?.trim();

    await document.set({
      'reportId': document.id,
      'type': 'found',
      'petId': petId.isEmpty ? null : petId,
      'petName': petName.trim(),
      'title': 'Found Pet',
      'name': petName.trim(),
      'location': foundLocation.trim(),
      'foundLocation': foundLocation.trim(),
      'lastSeenLocation': null,
      'locationName': cleanedLocationName == null || cleanedLocationName.isEmpty
          ? null
          : cleanedLocationName,
      'details': message.trim(),
      'foundDate': foundDate.trim(),
      'message': message.trim(),
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
      throw Exception(
        'You must be logged in to report a pet sighting.',
      );
    }

    final document = _reports.doc();
    final now = FieldValue.serverTimestamp();

    final cleanedLocation = locationName.trim();

    await document.set({
      'reportId': document.id,
      'type': 'sighting',
      'petId': null,
      'petName': petName.trim(),
      'title': 'Pet Sighting',
      'name': petName.trim(),
      'location': cleanedLocation,
      'locationName': cleanedLocation.isEmpty ? null : cleanedLocation,
      'lastSeenLocation': cleanedLocation,
      'foundLocation': null,
      'details': details.trim(),
      'foundDate': null,
      'message': details.trim(),
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
  // CREATE BARANGAY / STRAY REPORT
  // ============================================================

  Future<String> createBarangayReport({
    required String title,
    required String location,
    required String details,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final user = _auth.currentUser;

    final document = _reports.doc();
    final now = FieldValue.serverTimestamp();

    final cleanedLocationName = (locationName ?? location).trim();

    await document.set({
      'reportId': document.id,
      'type': 'stray',
      'petId': null,
      'petName': null,
      'title': title.trim(),
      'name': title.trim(),
      'location': location.trim(),
      'locationName': cleanedLocationName.isEmpty ? null : cleanedLocationName,
      'lastSeenLocation': location.trim(),
      'foundLocation': null,
      'details': details.trim(),
      'foundDate': null,
      'message': details.trim(),
      'photoUrl': '',
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
  // GET MY REPORTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyReportsStream() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _reports
        .where(
          'reportedBy',
          isEqualTo: uid,
        )
        .snapshots();
  }

  // ============================================================
  // GET MY REPORT COUNT
  // ============================================================

  Stream<int> getMyReportsCountStream() {
    return getMyReportsStream().map(
      (snapshot) => snapshot.docs.length,
    );
  }

  // ============================================================
  // GET FOUND REPORTS FOR PETS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getFoundReportsStream(
    List<String> petIds,
  ) {
    if (petIds.isEmpty) {
      return const Stream.empty();
    }

    return _reports
        .where(
          'type',
          isEqualTo: 'found',
        )
        .where(
          'petId',
          whereIn: petIds.length > 10 ? petIds.sublist(0, 10) : petIds,
        )
        .snapshots();
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
    String? locationName,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to update a report.',
      );
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception(
        'The report could not be found.',
      );
    }

    final data = document.data();

    if (data == null) {
      throw Exception(
        'The report could not be found.',
      );
    }

    final reportedBy = data['reportedBy']?.toString();

    if (reportedBy != user.uid) {
      throw Exception(
        'You are not authorized to update this report.',
      );
    }

    final cleanedLocationName = locationName?.trim();

    await _reports.doc(reportId).update({
      'location': location.trim(),
      'locationName': cleanedLocationName == null || cleanedLocationName.isEmpty
          ? location.trim()
          : cleanedLocationName,
      'details': details.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // RESOLVE REPORT
  // ============================================================

  Future<void> resolveReport(
    String reportId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in.',
      );
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception(
        'The report could not be found.',
      );
    }

    final data = document.data();

    if (data == null || data['reportedBy'] != user.uid) {
      throw Exception(
        'You are not authorized to resolve this report.',
      );
    }

    await _reports.doc(reportId).update({
      'status': 'resolved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REOPEN REPORT
  // ============================================================

  Future<void> reopenReport(
    String reportId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in.',
      );
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception(
        'The report could not be found.',
      );
    }

    final data = document.data();

    if (data == null || data['reportedBy'] != user.uid) {
      throw Exception(
        'You are not authorized to reopen this report.',
      );
    }

    await _reports.doc(reportId).update({
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE REPORT
  // ============================================================

  Future<void> deleteReport(
    String reportId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in.',
      );
    }

    final document = await _reports.doc(reportId).get();

    if (!document.exists) {
      throw Exception(
        'The report could not be found.',
      );
    }

    final data = document.data();

    if (data == null || data['reportedBy'] != user.uid) {
      throw Exception(
        'You are not authorized to delete this report.',
      );
    }

    await _reports.doc(reportId).delete();
  }
}
