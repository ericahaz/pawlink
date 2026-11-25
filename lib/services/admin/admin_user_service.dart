part of pawlink_admin;

class AdminUserService {
  AdminUserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _ownersRef =>
      _firestore.collection('owners');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<bool> isCurrentUserAdmin({bool refreshToken = false}) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final tokenResult = await user.getIdTokenResult(refreshToken);

    return tokenResult.claims?['admin'] == true;
  }

  Stream<List<PawUser>> getUsersStream() {
    return _ownersRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PawUser(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          contact: data['contact']?.toString() ?? '',
          address: data['address']?.toString() ?? '',
          userType: data['role']?.toString() ?? 'Resident',
          verified: data['verified'] == true,
          consent: data['consent'] == true,
        );
      }).toList();
    });
  }

  Stream<List<PawUser>> getResidentsStream() {
    return _ownersRef
        .where('role', isEqualTo: 'owner')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PawUser(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          contact: data['contact']?.toString() ?? '',
          address: data['address']?.toString() ?? '',
          userType: 'Resident',
          verified: data['verified'] == true,
          consent: data['consent'] == true,
        );
      }).toList();
    });
  }

  Future<PawUser?> getUser(String userId) async {
    final doc = await _ownersRef.doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return PawUser(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      contact: data['contact']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      userType: data['role']?.toString() ?? 'Resident',
      verified: data['verified'] == true,
      consent: data['consent'] == true,
    );
  }

  Future<void> updateUser(PawUser user) async {
    await _ownersRef.doc(user.id).update({
      'name': user.name,
      'email': user.email,
      'contact': user.contact,
      'address': user.address,
      'role': user.userType,
      'verified': user.verified,
      'consent': user.consent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser(String userId) async {
    await _ownersRef.doc(userId).delete();
  }
}