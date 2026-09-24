import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('pets');

  // ============================================================
  // CURRENT USER PETS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyPetsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _pets.where('ownerIds', arrayContains: user.uid).snapshots();
  }

  Stream<int> getMyPetsCountStream() {
    return getMyPetsStream().map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getQrProfilesCountStream() {
    return getMyPetsStream().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        return data['qrEnabled'] == true;
      }).length;
    });
  }

  // ============================================================
  // GET SINGLE PET
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getPet(String petId) async {
    return _pets.doc(petId).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getPetStream(String petId) {
    return _pets.doc(petId).snapshots();
  }

  // ============================================================
  // UPLOAD PET PHOTO
  // ============================================================

  Future<String> uploadPetPhoto({
    required String petId,
    required dynamic imageFile,
  }) async {
    final reference = _storage.ref().child('pet_images').child('$petId.jpg');

    await reference.putFile(imageFile);

    return await reference.getDownloadURL();
  }

  // ============================================================
  // CREATE PET
  // ============================================================

  Future<String> createPet({
    required String petName,
    required String breed,
    required String color,
    required String age,
    required String ownerName,
    required String ownerContact,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to register a pet.');
    }

    final petRef = _pets.doc();

    await petRef.set({
      'petId': petRef.id,
      'petName': petName.trim(),
      'breed': breed.trim(),
      'color': color.trim(),
      'age': age.trim(),
      'photoUrl': photoUrl ?? '',
      'ownerIds': [user.uid],
      'primaryOwnerId': user.uid,
      'ownerName': ownerName.trim(),
      'ownerContact': ownerContact.trim(),
      'status': 'alive',
      'qrEnabled': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return petRef.id;
  }

  // ============================================================
  // UPDATE PET
  // ============================================================

  Future<void> updatePet({
    required String petId,
    required String petName,
    required String breed,
    required String color,
    required String age,
    required String ownerName,
    required String ownerContact,
    String? photoUrl,
  }) async {
    await _pets.doc(petId).update({
      'petName': petName.trim(),
      'breed': breed.trim(),
      'color': color.trim(),
      'age': age.trim(),
      'ownerName': ownerName.trim(),
      'ownerContact': ownerContact.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // PET STATUS
  // ============================================================

  Future<void> updatePetStatus({
    required String petId,
    required String status,
  }) async {
    if (status.toLowerCase() == 'dead') {
      await deletePet(petId);
      return;
    }

    await _pets.doc(petId).update({
      'status': status.toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // JOINT OWNERS
  // ============================================================

  Future<void> addCoOwner({
    required String petId,
    required String ownerId,
  }) async {
    await _pets.doc(petId).update({
      'ownerIds': FieldValue.arrayUnion([ownerId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeCoOwner({
    required String petId,
    required String ownerId,
  }) async {
    await _pets.doc(petId).update({
      'ownerIds': FieldValue.arrayRemove([ownerId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE PET
  // ============================================================

  Future<void> deletePet(String petId) async {
    await _pets.doc(petId).delete();

    try {
      await _storage.ref().child('pet_images').child('$petId.jpg').delete();
    } catch (_) {
      // Photo may not exist.
    }
  }
}
