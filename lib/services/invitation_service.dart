import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _firestore.collection('jointInvitations');

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('pets');

  String _normalizeEmail(String? email) => (email ?? '').trim().toLowerCase();

  // ============================================================
  // CREATE INVITATION
  // ============================================================

  Future<String> createInvitation({
    required String petId,
    required String petName,
    required String invitedEmail,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final email = _normalizeEmail(invitedEmail);

    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Please enter a valid email address.');
    }

    if (email == _normalizeEmail(user.email)) {
      throw Exception('You cannot invite your own account.');
    }

    final petRef = _pets.doc(petId);
    final petSnapshot = await petRef.get();

    if (!petSnapshot.exists) {
      throw Exception('Pet profile not found.');
    }

    final petData = petSnapshot.data() ?? <String, dynamic>{};

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

    final existing = await _invitations
        .where('petId', isEqualTo: petId)
        .where('invitedBy', isEqualTo: user.uid)
        .where('invitedEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception(
        'There is already a pending invitation for this email.',
      );
    }

    final invitationRef = _invitations.doc();

    final now = Timestamp.now();

    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 7)),
    );

    await invitationRef.set({
      'invitationId': invitationRef.id,
      'petId': petId,
      'petName': (petData['petName'] ?? petName).toString(),
      'invitedBy': user.uid,
      'invitedEmail': email,
      'status': 'pending',
      'createdAt': now,
      'expiresAt': expiresAt,
    });

    return invitationRef.id;
  }

  // ============================================================
  // BUILD INVITATION LINK
  // ============================================================

  String buildInvitationLink(String invitationId) {
    return 'https://pawlink-ten.vercel.app/invite/$invitationId';
  }

  // ============================================================
  // GET A SINGLE INVITATION
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getInvitation(
    String invitationId,
  ) {
    return _invitations.doc(invitationId).get();
  }

  // ============================================================
  // GET INVITATIONS SENT BY THE CURRENT USER FOR A PET
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getPetInvitationsStream(
    String petId,
  ) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _invitations
        .where('petId', isEqualTo: petId)
        .where('invitedBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============================================================
  // GET INVITATIONS SENT TO THE CURRENT USER
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyInvitationsStream() {
    final user = _auth.currentUser;
    final email = _normalizeEmail(user?.email);

    if (user == null || email.isEmpty) {
      return const Stream.empty();
    }

    return _invitations
        .where('invitedEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ============================================================
  // ACCEPT INVITATION
  // ============================================================

  Future<void> acceptInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Please sign in before accepting the invitation.',
      );
    }

    final email = _normalizeEmail(user.email);

    if (email.isEmpty) {
      throw Exception(
        'Your account must have an email address to accept this invitation.',
      );
    }

    final invitationRef = _invitations.doc(invitationId);

    final result = await _firestore.runTransaction<String>(
      (transaction) async {
        final invitationSnapshot = await transaction.get(invitationRef);

        if (!invitationSnapshot.exists) {
          throw Exception('Invitation not found.');
        }

        final invitationData = invitationSnapshot.data() ?? <String, dynamic>{};

        final status = (invitationData['status'] ?? '').toString();

        if (status != 'pending') {
          throw Exception(
            'This invitation is no longer available.',
          );
        }

        final invitedEmail = _normalizeEmail(
          invitationData['invitedEmail']?.toString(),
        );

        if (invitedEmail != email) {
          throw Exception(
            'This invitation was sent to a different email address.',
          );
        }

        final expiresAt = invitationData['expiresAt'];

        if (expiresAt is! Timestamp) {
          throw Exception(
            'This invitation has an invalid expiration date.',
          );
        }

        if (!expiresAt.toDate().isAfter(DateTime.now())) {
          transaction.update(invitationRef, {
            'status': 'expired',
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return 'expired';
        }

        final petId = (invitationData['petId'] ?? '').toString();
        final invitedBy = (invitationData['invitedBy'] ?? '').toString();

        if (petId.isEmpty || invitedBy.isEmpty) {
          throw Exception('Invalid invitation.');
        }

        final petRef = _pets.doc(petId);
        final petSnapshot = await transaction.get(petRef);

        if (!petSnapshot.exists) {
          throw Exception(
            'The pet profile no longer exists.',
          );
        }

        final petData = petSnapshot.data() ?? <String, dynamic>{};

        final primaryOwnerId = (petData['primaryOwnerId'] ?? '').toString();

        final ownerIds = List<String>.from(
          petData['ownerIds'] ?? <String>[],
        );

        if (primaryOwnerId != invitedBy) {
          throw Exception(
            'This invitation was not sent by the current primary owner.',
          );
        }

        if (!ownerIds.contains(invitedBy)) {
          throw Exception(
            'The inviting user is no longer connected to this pet.',
          );
        }

        if (ownerIds.contains(user.uid)) {
          throw Exception(
            'Your account is already connected to this pet.',
          );
        }

        ownerIds.add(user.uid);

        transaction.update(petRef, {
          'ownerIds': ownerIds,
          'acceptedInvitationId': invitationId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(invitationRef, {
          'status': 'accepted',
          'acceptedBy': user.uid,
          'acceptedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return 'accepted';
      },
    );

    if (result == 'expired') {
      throw Exception(
        'This invitation has expired. Ask the primary owner to send a new one.',
      );
    }
  }

  // ============================================================
  // DECLINE INVITATION
  // ============================================================

  Future<void> declineInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final invitationRef = _invitations.doc(invitationId);

    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(invitationRef);

      if (!snapshot.exists) {
        throw Exception('Invitation not found.');
      }

      final data = snapshot.data() ?? <String, dynamic>{};

      final invitedEmail = _normalizeEmail(
        data['invitedEmail']?.toString(),
      );

      if (invitedEmail != _normalizeEmail(user.email)) {
        throw Exception(
          'You cannot decline this invitation.',
        );
      }

      if ((data['status'] ?? '').toString() != 'pending') {
        throw Exception(
          'This invitation is no longer available.',
        );
      }

      final expiresAt = data['expiresAt'];

      if (expiresAt is Timestamp &&
          !expiresAt.toDate().isAfter(DateTime.now())) {
        transaction.update(invitationRef, {
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return;
      }

      transaction.update(invitationRef, {
        'status': 'declined',
        'declinedBy': user.uid,
        'declinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ============================================================
  // CANCEL INVITATION
  // ============================================================

  Future<void> cancelInvitation(String invitationId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final invitationRef = _invitations.doc(invitationId);

    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(invitationRef);

      if (!snapshot.exists) {
        throw Exception('Invitation not found.');
      }

      final data = snapshot.data() ?? <String, dynamic>{};

      final invitedBy = (data['invitedBy'] ?? '').toString();

      if (invitedBy != user.uid) {
        throw Exception(
          'Only the person who sent the invitation can cancel it.',
        );
      }

      if ((data['status'] ?? '').toString() != 'pending') {
        throw Exception(
          'Only pending invitations can be cancelled.',
        );
      }

      transaction.update(invitationRef, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
