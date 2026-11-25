import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // COLLECTIONS
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _owners =>
      _firestore.collection('owners');

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('pets');

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _firestore.collection('owner_invitations');

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

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception('Email address is required.');
    }

    final ownerReference = _owners.doc(user.uid);
    final existingOwner = await ownerReference.get();

    final ownerData = <String, dynamic>{
      'userId': user.uid,
      'name': name.trim(),
      'email': normalizedEmail,
      'contact': contact.trim(),
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Keep the original createdAt when updating an existing profile.
    if (!existingOwner.exists) {
      ownerData['createdAt'] = FieldValue.serverTimestamp();
    }

    await ownerReference.set(
      ownerData,
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // GET OWNER
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getOwner(
    String ownerId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    if (ownerId != user.uid) {
      throw Exception('You can only access your own owner profile.');
    }

    return _owners.doc(ownerId).get();
  }

  // ============================================================
  // OWNER STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getOwnerStream(
    String ownerId,
  ) {
    final user = _auth.currentUser;

    if (user == null || ownerId != user.uid) {
      return const Stream.empty();
    }

    return _owners.doc(ownerId).snapshots();
  }

  // ============================================================
  // CREATE CO-OWNER INVITATION
  // ============================================================

  Future<void> createOwnerInvitation({
    required String petId,
    required String invitedEmail,
    required String invitedBy,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    // Do not trust the invitedBy value supplied by the caller.
    if (invitedBy != user.uid) {
      throw Exception('Invalid invitation sender.');
    }

    final email = invitedEmail.trim().toLowerCase();

    if (email.isEmpty) {
      throw Exception('Email address is required.');
    }

    final currentEmail = (user.email ?? '').trim().toLowerCase();

    if (email == currentEmail) {
      throw Exception('You cannot invite your own account.');
    }

    if (petId.trim().isEmpty || petId.contains('/')) {
      throw Exception('Invalid pet ID.');
    }

    // Verify that the pet exists and the current user is its
    // primary owner. Firestore Rules must enforce this as well.
    final petSnapshot = await _pets.doc(petId).get();

    if (!petSnapshot.exists) {
      throw Exception('Pet profile not found.');
    }

    final petData = petSnapshot.data() ?? {};

    final primaryOwnerId = (petData['primaryOwnerId'] ?? '').toString();

    final ownerIds = List<String>.from(
      petData['ownerIds'] ?? <String>[],
    );

    if (primaryOwnerId != user.uid) {
      throw Exception(
        'Only the primary owner can invite a co-owner.',
      );
    }

    if (!ownerIds.contains(user.uid)) {
      throw Exception('You are not connected to this pet.');
    }

    // Deterministic invitation ID:
    // one invitation document per pet and recipient email.
    final invitationReference = _invitations.doc(
      '${petId}__$email',
    );

    // Check the exact document rather than querying all owners
    // or all invitations. This also prevents overwriting an
    // existing invitation with a different status.
    final existingInvitation = await invitationReference.get();

    if (existingInvitation.exists) {
      final existingData = existingInvitation.data() ?? {};
      final status = (existingData['status'] ?? '').toString();

      if (status == 'pending') {
        throw Exception(
          'An invitation has already been sent to this email.',
        );
      }

      throw Exception(
        'An invitation record already exists for this email and pet. '
        'A new invitation cannot be created yet.',
      );
    }

    await invitationReference.set({
      'invitationId': invitationReference.id,
      'petId': petId,
      'invitedEmail': email,
      'invitedBy': user.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // GET PENDING INVITATIONS FOR CURRENT USER
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingInvitations(
    String email,
  ) {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      return const Stream.empty();
    }

    final currentEmail = user.email!.trim().toLowerCase();
    final requestedEmail = email.trim().toLowerCase();

    // Do not let callers request invitations for another email.
    if (requestedEmail != currentEmail) {
      return const Stream.empty();
    }

    return _invitations
        .where('invitedEmail', isEqualTo: currentEmail)
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

    final currentEmail = (user.email ?? '').trim().toLowerCase();

    if (currentEmail.isEmpty) {
      throw Exception(
        'Your account must have a verified email address.',
      );
    }

    final invitationReference = _invitations.doc(invitationId);

    await _firestore.runTransaction<void>((transaction) async {
      // All transaction reads must happen before writes.
      final invitationSnapshot = await transaction.get(invitationReference);

      if (!invitationSnapshot.exists) {
        throw Exception('Invitation not found.');
      }

      final invitationData = invitationSnapshot.data() ?? {};

      final invitedEmail = (invitationData['invitedEmail'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (invitedEmail != currentEmail) {
        throw Exception(
          'This invitation was sent to a different email address.',
        );
      }

      final status = (invitationData['status'] ?? '').toString();

      if (status != 'pending') {
        throw Exception(
          'This invitation is no longer available.',
        );
      }

      final petId = (invitationData['petId'] ?? '').toString();

      if (petId.isEmpty || petId.contains('/')) {
        throw Exception('Invalid pet ID.');
      }

      final petReference = _pets.doc(petId);
      final ownerReference = _owners.doc(user.uid);

      final petSnapshot = await transaction.get(petReference);
      final ownerSnapshot = await transaction.get(ownerReference);

      if (!petSnapshot.exists) {
        throw Exception('Pet profile no longer exists.');
      }

      final petData = petSnapshot.data() ?? {};

      final primaryOwnerId = (petData['primaryOwnerId'] ?? '').toString();

      if (primaryOwnerId.isEmpty) {
        throw Exception(
          'This pet profile has no valid primary owner.',
        );
      }

      final ownerIds = List<String>.from(
        petData['ownerIds'] ?? <String>[],
      );

      if (ownerIds.contains(user.uid)) {
        throw Exception(
          'Your account is already connected to this pet.',
        );
      }

      ownerIds.add(user.uid);

      final existingOwnerData = ownerSnapshot.data() ?? {};

      final ownerData = <String, dynamic>{
        'userId': user.uid,
        'name':
            user.displayName ?? (existingOwnerData['name'] ?? '').toString(),
        'email': currentEmail,
        'contact': (existingOwnerData['contact'] ?? '').toString(),
        'role': 'co-owner',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!ownerSnapshot.exists) {
        ownerData['createdAt'] = FieldValue.serverTimestamp();
      }

      transaction.set(
        ownerReference,
        ownerData,
        SetOptions(merge: true),
      );

      transaction.update(petReference, {
        'ownerIds': ownerIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(invitationReference, {
        'status': 'accepted',
        'acceptedBy': user.uid,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ============================================================
  // REJECT INVITATION
  // ============================================================

  Future<void> rejectInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final currentEmail = (user.email ?? '').trim().toLowerCase();

    if (currentEmail.isEmpty) {
      throw Exception('Your account has no email address.');
    }

    final invitationReference = _invitations.doc(invitationId);

    await _firestore.runTransaction<void>((transaction) async {
      final invitationSnapshot = await transaction.get(invitationReference);

      if (!invitationSnapshot.exists) {
        throw Exception('Invitation not found.');
      }

      final invitationData = invitationSnapshot.data() ?? {};

      final invitedEmail = (invitationData['invitedEmail'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (invitedEmail != currentEmail) {
        throw Exception(
          'You cannot reject an invitation sent to another email.',
        );
      }

      final status = (invitationData['status'] ?? '').toString();

      if (status != 'pending') {
        throw Exception(
          'This invitation is no longer available.',
        );
      }

      transaction.update(invitationReference, {
        'status': 'rejected',
        'rejectedBy': user.uid,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ============================================================
  // GET INVITATION
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getInvitation(
    String invitationId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    // Firestore Rules must still verify that the caller is
    // either the invitation recipient or its sender.
    return _invitations.doc(invitationId).get();
  }
}
