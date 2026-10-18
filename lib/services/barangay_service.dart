import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/barangay_model.dart';

class BarangayService {
  BarangayService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// The primary document stores the official barangay contact details.
  static const String documentId = 'primary';

  CollectionReference<Map<String, dynamic>> get _barangaysRef =>
      _firestore.collection('barangays');

  DocumentReference<Map<String, dynamic>> get _barangayRef =>
      _barangaysRef.doc(documentId);

  /// Checks whether the signed-in Firebase user has the admin claim.
  Future<bool> isCurrentUserAdmin({
    bool refreshToken = false,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final tokenResult = await user.getIdTokenResult(refreshToken);

    return tokenResult.claims?['admin'] == true;
  }

  /// Retrieves the primary barangay document.
  ///
  /// Returns null when the document has not been created.
  Future<BarangayModel?> getBarangay() async {
    final snapshot = await _barangayRef.get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return BarangayModel.fromFirestore(data);
  }

  /// Listens for changes to the primary barangay document.
  Stream<BarangayModel?> watchBarangay() {
    return _barangayRef.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      return BarangayModel.fromFirestore(data);
    });
  }

  /// Saves the official barangay details.
  ///
  /// The Firebase ID token is refreshed before checking the admin claim.
  /// Firestore Security Rules must independently enforce admin permissions.
  Future<void> saveBarangay(BarangayModel barangay) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Please sign in before saving barangay details.',
      );
    }

    final tokenResult = await user.getIdTokenResult(true);

    if (tokenResult.claims?['admin'] != true) {
      throw Exception(
        'Administrator access required. '
        'Please sign in again using your administrator account.',
      );
    }

    final data = barangay.toMap();

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _barangayRef.set(
      data,
      SetOptions(merge: true),
    );
  }
}
