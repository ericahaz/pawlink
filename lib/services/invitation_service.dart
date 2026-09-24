import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _firestore.collection('jointInvitations');

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('pets');

  /// Creates a joint-owner invitation.
  ///
  /// Only the primary owner of the pet should be allowed to create
  /// invitations. Firestore Security Rules must enforce this as well.
  Future<String> createInvitation({
    required String petId,
    required String petName,
    required String invitedEmail,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final email = invitedEmail.trim().toLowerCase();

    if (email.isEmpty) {
      throw Exception('Please enter an email address.');
    }

    if (email == user.email?.trim().toLowerCase()) {
      throw Exception('You cannot invite your own account.');
    }

    final petSnapshot = await _pets.doc(petId).get();

    if (!petSnapshot.exists) {
      throw Exception('Pet profile not found.');
    }

    final petData = petSnapshot.data() ?? {};

    final primaryOwnerId = (petData['primaryOwnerId'] ?? '').toString();

    final ownerIds = List<String>.from(petData['ownerIds'] ?? <String>[]);

    if (primaryOwnerId != user.uid) {
      throw Exception('Only the primary owner can invite a co-owner.');
    }

    if (ownerIds.contains(user.uid) == false) {
      throw Exception('You are not connected to this pet.');
    }

    // Prevent duplicate pending invitations.
    final existing = await _invitations
        .where('petId', isEqualTo: petId)
        .where('invitedEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('There is already a pending invitation for this email.');
    }

    final invitationRef = _invitations.doc();

    final now = Timestamp.now();

    // Invitation expires after 7 days.
    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 7)),
    );

    await invitationRef.set({
      'invitationId': invitationRef.id,
      'petId': petId,
      'petName': petName.trim(),
      'invitedBy': user.uid,
      'invitedEmail': email,
      'status': 'pending',
      'createdAt': now,
      'expiresAt': expiresAt,
    });

    return invitationRef.id;
  }

  /// Returns a web invitation URL.
  ///
  /// This URL does not automatically give access to the pet.
  /// The recipient still needs to sign in and accept the invitation.
  String buildInvitationLink(String invitationId) {
    return 'https://pawlink-pet-2026.web.app/invite/$invitationId';
  }

  /// Gets one invitation.
  Future<DocumentSnapshot<Map<String, dynamic>>> getInvitation(
    String invitationId,
  ) {
    return _invitations.doc(invitationId).get();
  }

  /// Stream for invitations created for a particular pet.
  Stream<QuerySnapshot<Map<String, dynamic>>> getPetInvitationsStream(
    String petId,
  ) {
    return _invitations
        .where('petId', isEqualTo: petId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream of invitations received by the currently signed-in user.
  ///
  /// This uses the invited email rather than UID because the recipient
  /// may not have a PawLink account yet when the invitation is created.
  Stream<QuerySnapshot<Map<String, dynamic>>> getMyInvitationsStream() {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      return const Stream.empty();
    }

    return _invitations
        .where('invitedEmail', isEqualTo: user.email!.trim().toLowerCase())
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Accepts an invitation and adds the current user's UID
  /// to the pet's ownerIds.
  ///
  /// The transaction keeps the pet and invitation update together.
  Future<void> acceptInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in before accepting the invitation.');
    }

    final invitationRef = _invitations.doc(invitationId);

    await _firestore.runTransaction((transaction) async {
      final invitationSnapshot = await transaction.get(invitationRef);

      if (!invitationSnapshot.exists) {
        throw Exception('Invitation not found.');
      }

      final invitationData = invitationSnapshot.data() ?? {};

      final status = (invitationData['status'] ?? '').toString();

      if (status != 'pending') {
        throw Exception('This invitation is no longer available.');
      }

      final invitedEmail = (invitationData['invitedEmail'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      final currentEmail = (user.email ?? '').trim().toLowerCase();

      if (invitedEmail.isEmpty || invitedEmail != currentEmail) {
        throw Exception(
          'This invitation was sent to a different email address.',
        );
      }

      final expiresAt = invitationData['expiresAt'];

      if (expiresAt is Timestamp &&
          expiresAt.toDate().isBefore(DateTime.now())) {
        transaction.update(invitationRef, {
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        throw Exception('This invitation has expired.');
      }

      final petId = (invitationData['petId'] ?? '').toString();

      if (petId.isEmpty) {
        throw Exception('Invalid invitation.');
      }

      final petRef = _pets.doc(petId);

      final petSnapshot = await transaction.get(petRef);

      if (!petSnapshot.exists) {
        throw Exception('The pet profile no longer exists.');
      }

      final petData = petSnapshot.data() ?? {};

      final ownerIds = List<String>.from(petData['ownerIds'] ?? <String>[]);

      if (!ownerIds.contains(user.uid)) {
        ownerIds.add(user.uid);
      }

      transaction.update(petRef, {
        'ownerIds': ownerIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(invitationRef, {
        'status': 'accepted',
        'acceptedBy': user.uid,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Declines an invitation.
  Future<void> declineInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final invitationRef = _invitations.doc(invitationId);

    final snapshot = await invitationRef.get();

    if (!snapshot.exists) {
      throw Exception('Invitation not found.');
    }

    final data = snapshot.data() ?? {};

    final invitedEmail = (data['invitedEmail'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final currentEmail = (user.email ?? '').trim().toLowerCase();

    if (invitedEmail != currentEmail) {
      throw Exception('You cannot decline this invitation.');
    }

    await invitationRef.update({
      'status': 'declined',
      'declinedBy': user.uid,
      'declinedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancels a pending invitation.
  ///
  /// This should only be available to the primary owner.
  Future<void> cancelInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final invitationRef = _invitations.doc(invitationId);

    final snapshot = await invitationRef.get();

    if (!snapshot.exists) {
      throw Exception('Invitation not found.');
    }

    final data = snapshot.data() ?? {};

    final invitedBy = (data['invitedBy'] ?? '').toString();

    if (invitedBy != user.uid) {
      throw Exception('Only the person who sent the invitation can cancel it.');
    }

    await invitationRef.update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
