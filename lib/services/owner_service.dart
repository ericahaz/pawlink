import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // CREATE / UPDATE OWNER PROFILE
  // ============================================================

  Future<void> createOrUpdateOwner({
    required String name,
    required String email,
    String contact = '',
    String role = 'owner',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    await _firestore.collection('owners').doc(user.uid).set({
      'userId': user.uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'contact': contact.trim(),
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ============================================================
  // GET OWNER
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getOwner(
    String ownerId,
  ) async {
    return await _firestore.collection('owners').doc(ownerId).get();
  }

  // ============================================================
  // OWNER STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getOwnerStream(
    String ownerId,
  ) {
    return _firestore.collection('owners').doc(ownerId).snapshots();
  }

  // ============================================================
  // CREATE CO-OWNER INVITATION
  // ============================================================

  Future<void> createOwnerInvitation({
    required String petId,
    required String invitedEmail,
    required String invitedBy,
  }) async {
    final email = invitedEmail.trim().toLowerCase();

    if (email.isEmpty) {
      throw Exception('Email address is required.');
    }

    final existingOwnerQuery = await _firestore
        .collection('owners')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    final petSnapshot = await _firestore.collection('pets').doc(petId).get();

    if (!petSnapshot.exists) {
      throw Exception('Pet profile not found.');
    }

    final petData = petSnapshot.data() ?? {};

    final ownerIds = List<String>.from(petData['ownerIds'] ?? <String>[]);

    if (existingOwnerQuery.docs.isNotEmpty) {
      final existingOwnerId = existingOwnerQuery.docs.first.id;

      if (ownerIds.contains(existingOwnerId)) {
        throw Exception('This account is already connected to this pet.');
      }
    }

    final pendingInvitation = await _firestore
        .collection('owner_invitations')
        .where('petId', isEqualTo: petId)
        .where('invitedEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (pendingInvitation.docs.isNotEmpty) {
      throw Exception('An invitation has already been sent to this email.');
    }

    final invitationReference = _firestore
        .collection('owner_invitations')
        .doc();

    await invitationReference.set({
      'invitationId': invitationReference.id,
      'petId': petId,
      'invitedEmail': email,
      'invitedBy': invitedBy,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // GET PENDING INVITATIONS FOR EMAIL
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingInvitations(
    String email,
  ) {
    return _firestore
        .collection('owner_invitations')
        .where('invitedEmail', isEqualTo: email.trim().toLowerCase())
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // ============================================================
  // ACCEPT INVITATION
  // ============================================================

  Future<void> acceptInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final invitationReference = _firestore
        .collection('owner_invitations')
        .doc(invitationId);

    final invitationSnapshot = await invitationReference.get();

    if (!invitationSnapshot.exists) {
      throw Exception('Invitation not found.');
    }

    final invitationData = invitationSnapshot.data() ?? {};

    final invitedEmail = (invitationData['invitedEmail'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final currentEmail = (user.email ?? '').trim().toLowerCase();

    if (invitedEmail != currentEmail) {
      throw Exception('This invitation was sent to a different email address.');
    }

    final status = (invitationData['status'] ?? '').toString();

    if (status != 'pending') {
      throw Exception('This invitation is no longer available.');
    }

    final petId = (invitationData['petId'] ?? '').toString();

    if (petId.isEmpty) {
      throw Exception('Invalid pet ID.');
    }

    final petReference = _firestore.collection('pets').doc(petId);

    final ownerReference = _firestore.collection('owners').doc(user.uid);

    final batch = _firestore.batch();

    final petSnapshot = await petReference.get();

    if (!petSnapshot.exists) {
      throw Exception('Pet profile no longer exists.');
    }

    final petData = petSnapshot.data() ?? {};

    final existingOwnerIds = List<String>.from(
      petData['ownerIds'] ?? <String>[],
    );

    if (!existingOwnerIds.contains(user.uid)) {
      existingOwnerIds.add(user.uid);
    }

    batch.set(ownerReference, {
      'userId': user.uid,
      'name': user.displayName ?? '',
      'email': currentEmail,
      'contact': '',
      'role': 'co-owner',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.update(petReference, {
      'ownerIds': existingOwnerIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(invitationReference, {
      'status': 'accepted',
      'acceptedBy': user.uid,
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ============================================================
  // REJECT INVITATION
  // ============================================================

  Future<void> rejectInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    await _firestore.collection('owner_invitations').doc(invitationId).update({
      'status': 'rejected',
      'rejectedBy': user.uid,
      'rejectedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // GET INVITATION
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getInvitation(
    String invitationId,
  ) async {
    return await _firestore
        .collection('owner_invitations')
        .doc(invitationId)
        .get();
  }
}
