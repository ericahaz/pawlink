import 'dart:typed_data';

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
  // CURRENT USER'S PETS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyPetsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _pets.where('ownerIds', arrayContains: user.uid).snapshots();
  }

  // ============================================================
  // PET COUNT
  // ============================================================

  Stream<int> getMyPetsCountStream() {
    return getMyPetsStream().map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // QR PROFILES COUNT
  // ============================================================

  Stream<int> getQrProfilesCountStream() {
    return getMyPetsStream().map((snapshot) {
      return snapshot.docs.where((doc) {
        return doc.data()['qrEnabled'] == true;
      }).length;
    });
  }

  // ============================================================
  // GET PET
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getPet(String petId) async {
    return _pets.doc(petId).get();
  }

  // ============================================================
  // GET PET REAL-TIME STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getPetStream(String petId) {
    return _pets.doc(petId).snapshots();
  }

  // ============================================================
  // UPLOAD PET PHOTO
  // ============================================================
  //
  // Uses Uint8List because this is a Flutter Web project.
  //

  Future<String> uploadPetPhotoBytes({
    required String petId,
    required Uint8List bytes,
  }) async {
    final reference = _storage.ref().child('pet_images').child('$petId.jpg');

    await reference.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

    return reference.getDownloadURL();
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
    String safetyTag = 'safe',
    String identifyingMarks = '',
    String sex = 'unknown',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to register a pet.');
    }

    final petRef = _pets.doc();

    final normalizedSafetyTag = _normalizeSafetyTag(safetyTag);

    await petRef.set({
      'petId': petRef.id,
      'petName': petName.trim(),
      'breed': breed.trim(),
      'color': color.trim(),
      'age': age.trim(),
      'identifyingMarks': identifyingMarks.trim(),
      'sex': _normalizeSex(sex),
      'photoUrl': photoUrl ?? '',

      // ========================================================
      // OWNER
      // ========================================================
      'ownerIds': [user.uid],
      'primaryOwnerId': user.uid,
      'ownerName': ownerName.trim(),
      'ownerContact': ownerContact.trim(),

      // ========================================================
      // STATUS
      // ========================================================
      'status': 'alive',

      // ========================================================
      // SAFETY
      // ========================================================
      'safetyTag': normalizedSafetyTag,

      // ========================================================
      // QR
      // ========================================================
      //
      // Every newly registered pet receives one QR profile.
      // The QR belongs to the pet, not to the owner.
      //
      'qrEnabled': true,

      // ========================================================
      // TIMESTAMPS
      // ========================================================
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
    String? safetyTag,
    String? identifyingMarks,
    String? sex,
  }) async {
    final Map<String, dynamic> updates = {
      'petName': petName.trim(),
      'breed': breed.trim(),
      'color': color.trim(),
      'age': age.trim(),
      'ownerName': ownerName.trim(),
      'ownerContact': ownerContact.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (identifyingMarks != null) {
      updates['identifyingMarks'] = identifyingMarks.trim();
    }

    if (sex != null) {
      updates['sex'] = _normalizeSex(sex);
    }

    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
    }

    if (safetyTag != null) {
      updates['safetyTag'] = _normalizeSafetyTag(safetyTag);
    }

    await _pets.doc(petId).update(updates);
  }

  // ============================================================
  // UPDATE SAFETY TAG
  // ============================================================

  Future<void> updatePetSafetyTag({
    required String petId,
    required String safetyTag,
  }) async {
    await _pets.doc(petId).update({
      'safetyTag': _normalizeSafetyTag(safetyTag),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE PET STATUS
  // ============================================================
  //
  // alive = keep the pet
  // dead  = permanently delete pet + photo
  //

  Future<void> updatePetStatus({
    required String petId,
    required String status,
  }) async {
    final normalizedStatus = status.toLowerCase().trim();

    if (normalizedStatus == 'dead') {
      await deletePet(petId);
      return;
    }

    if (normalizedStatus != 'alive') {
      throw Exception('Invalid pet status.');
    }

    await _pets.doc(petId).update({
      'status': 'alive',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ADD CO-OWNER
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

  // ============================================================
  // REMOVE CO-OWNER
  // ============================================================

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
  //
  // Deletes:
  // 1. Firestore pet document
  // 2. Firebase Storage pet photo
  //
  // This is also used when a pet is marked as deceased.
  //

  Future<void> deletePet(String petId) async {
    await _pets.doc(petId).delete();

    try {
      await _storage.ref().child('pet_images').child('$petId.jpg').delete();
    } catch (_) {
      // The photo may not exist.
    }
  }

  // ============================================================
  // NORMALIZE SEX
  // ============================================================

  String _normalizeSex(String sex) {
    switch (sex.trim().toLowerCase()) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      case 'unknown':
      default:
        return 'unknown';
    }
  }

  // ============================================================
  // NORMALIZE SAFETY TAG
  // ============================================================

  String _normalizeSafetyTag(String safetyTag) {
    final tag = safetyTag.toLowerCase().trim();

    switch (tag) {
      case 'safe':
      case 'green':
        return 'safe';

      case 'caution':
      case 'yellow':
        return 'caution';

      case 'aggressive':
      case 'red':
        return 'aggressive';

      default:
        return 'safe';
    }
  }
}