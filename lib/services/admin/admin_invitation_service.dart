part of pawlink_admin;

class AdminInvitationService {
  AdminInvitationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _invitationsRef =>
      _firestore.collection('jointInvitations');

  CollectionReference<Map<String, dynamic>> get _petsRef =>
      _firestore.collection('pets');

  Stream<List<CoOwnerInvitation>> getInvitationsStream() {
    return _invitationsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) async {
      final invitations = <CoOwnerInvitation>[];
      for (final doc in snapshot.docs) {
        final invitation = await _coOwnerInvitationFromFirestore(doc);
        if (invitation != null) {
          invitations.add(invitation);
        }
      }
      return invitations;
    }).asyncMap((event) => event);
  }

  Future<CoOwnerInvitation?> _coOwnerInvitationFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data() ?? {};

    final petId = data['petId']?.toString() ?? '';
    String petName = data['petName']?.toString() ?? '';

    if (petName.isEmpty && petId.isNotEmpty) {
      final petDoc = await _petsRef.doc(petId).get();
      if (petDoc.exists) {
        petName = petDoc.data()?['petName']?.toString() ?? '';
      }
    }

    return CoOwnerInvitation(
      id: doc.id,
      petId: petId,
      petName: petName,
      owner: data['invitedBy']?.toString() ?? '',
      link: 'https://pawlink-ten.vercel.app/invite/${doc.id}',
      status: data['status']?.toString() ?? 'Pending',
    );
  }

  Future<void> updateInvitationStatus(String invitationId, String status) async {
    await _invitationsRef.doc(invitationId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteInvitation(String invitationId) async {
    await _invitationsRef.doc(invitationId).delete();
  }

  Future<void> addInvitation(CoOwnerInvitation invitation) async {
    await _invitationsRef.doc(invitation.id).set({
      'petId': invitation.petId,
      'petName': invitation.petName,
      'invitedBy': invitation.owner,
      'status': invitation.status,
      'link': invitation.link,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}