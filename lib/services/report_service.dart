import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  // ============================================================
  // CREATE LOST PET REPORT
  // ============================================================

  Future<String> createLostPetReport({
    required String petId,
    required String petName,
    required String lastSeenLocation,
    required String description,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to report a lost pet.');
    }

    final reportRef = _reports.doc();

    await reportRef.set({
      'reportId': reportRef.id,
      'type': 'lost',

      'petId': petId.trim(),
      'petName': petName.trim(),

      'reportedBy': user.uid,

      'lastSeenLocation': lastSeenLocation.trim(),
      'description': description.trim(),

      'photoUrl': photoUrl?.trim() ?? '',

      'status': 'active',

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reportRef.id;
  }

  // ============================================================
  // CREATE FOUND PET REPORT
  // ============================================================
  //
  // This can be submitted by:
  // - Logged-in users
  // - Guests/finder without an account
  //
  // If the finder is not logged in, reportedBy will be null.
  // ============================================================

  Future<String> createFoundPetReport({
    required String petId,
    required String petName,
    required String foundLocation,
    required String foundDate,
    String? message,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;

    final reportRef = _reports.doc();

    await reportRef.set({
      'reportId': reportRef.id,
      'type': 'found',

      'petId': petId.trim(),
      'petName': petName.trim(),

      'reportedBy': user?.uid,

      'foundLocation': foundLocation.trim(),
      'foundDate': foundDate.trim(),

      'message': message?.trim() ?? '',
      'photoUrl': photoUrl?.trim() ?? '',

      'status': 'active',

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reportRef.id;
  }

  // ============================================================
  // CREATE BARANGAY REPORT
  // ============================================================
  //
  // Used for reports such as:
  // - Lost stray
  // - Stray animal concern
  // - Aggressive animal
  // - Animal needing assistance
  // ============================================================

  Future<String> createBarangayReport({
    required String title,
    required String description,
    required String location,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to submit a barangay report.');
    }

    final reportRef = _reports.doc();

    await reportRef.set({
      'reportId': reportRef.id,
      'type': 'barangay',

      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),

      'reportedBy': user.uid,

      'photoUrl': photoUrl?.trim() ?? '',

      'status': 'active',

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reportRef.id;
  }

  // ============================================================
  // GET MY REPORTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyReportsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _reports.where('reportedBy', isEqualTo: user.uid).snapshots();
  }

  // ============================================================
  // GET MY REPORT COUNT
  // ============================================================

  Stream<int> getMyReportsCountStream() {
    return getMyReportsStream().map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // GET FOUND REPORTS FOR MY PETS
  // ============================================================
  //
  // petIds = IDs of pets owned by the current user.
  //
  // Firestore whereIn supports a maximum of 10 values in this
  // type of query, so we only use the first 10 here.
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
  // GET ALL LOST PET REPORTS
  // ============================================================
  //
  // This can be used on a community/lost pets page.
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getLostReportsStream() {
    return _reports
        .where('type', isEqualTo: 'lost')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  // ============================================================
  // GET ALL BARANGAY REPORTS
  // ============================================================
  //
  // This can later be restricted to barangay/admin users
  // using Firestore Security Rules.
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getBarangayReportsStream() {
    return _reports
        .where('type', isEqualTo: 'barangay')
        .where('status', isEqualTo: 'active')
        .snapshots();
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
  // GET ONE REPORT AS A STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getReportStream(
    String reportId,
  ) {
    return _reports.doc(reportId).snapshots();
  }

  // ============================================================
  // RESOLVE REPORT
  // ============================================================

  Future<void> resolveReport(String reportId) async {
    await _reports.doc(reportId).update({
      'status': 'resolved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE REPORT
  // ============================================================

  Future<void> deleteReport(String reportId) async {
    await _reports.doc(reportId).delete();
  }
}
