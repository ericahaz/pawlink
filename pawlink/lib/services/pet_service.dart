import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const int maxPetPhotos = 4;
  static const int maxPhotoBytes = 5 * 1024 * 1024;

  static const Duration _uploadTimeout = Duration(seconds: 60);
  static const Duration _firestoreTimeout = Duration(seconds: 30);

  // Cloudinary configuration remains unchanged.
  static const String _cloudinaryCloudName = 'oxltrdez';
  static const String _cloudinaryUploadPreset = 'pawlink_pet_photos';

  CollectionReference<Map<String, dynamic>> get _pets =>
      _firestore.collection('pets');

  CollectionReference<Map<String, dynamic>> get _publicPets =>
      _firestore.collection('public_pets');

  // ============================================================
  // PHOTO VALIDATION
  // ============================================================

  void _validatePhoto(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw Exception('The selected photo is empty.');
    }

    if (bytes.lengthInBytes > maxPhotoBytes) {
      throw Exception(
        'Each pet photo must be 5 MB or smaller. '
        'Please select a smaller image.',
      );
    }
  }

  List<String> _normalizePhotoUrls(List<String> urls) {
    if (urls.length > maxPetPhotos) {
      throw Exception('A pet can have a maximum of 4 photos.');
    }

    return urls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
  }

  List<String> _readPhotoUrls(Map<String, dynamic> data) {
    final dynamic savedUrls = data['photoUrls'];

    if (savedUrls is List) {
      final urls = savedUrls
          .whereType<String>()
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (urls.isNotEmpty) {
        return urls.take(maxPetPhotos).toList();
      }
    }

    final String oldPhotoUrl = (data['photoUrl'] ?? '').toString().trim();

    return oldPhotoUrl.isEmpty ? <String>[] : <String>[oldPhotoUrl];
  }

  // ============================================================
  // CLOUDINARY PHOTO UPLOAD
  // ============================================================

  Future<String> _uploadPhotoToCloudinary({
    required String filename,
    required Uint8List bytes,
  }) async {
    _validatePhoto(bytes);

    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$_cloudinaryCloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _cloudinaryUploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

    String stage = 'sending the photo';

    try {
      final streamedResponse = await request.send().timeout(_uploadTimeout);

      stage = 'reading Cloudinary response data';

      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_uploadTimeout);

      dynamic result;

      try {
        result = jsonDecode(response.body);
      } on FormatException {
        throw Exception(
          'Cloudinary returned an invalid response '
          '(HTTP ${response.statusCode}).',
        );
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          result is Map) {
        final dynamic secureUrl = result['secure_url'];

        if (secureUrl is String && secureUrl.isNotEmpty) {
          return secureUrl;
        }

        throw Exception(
          'Cloudinary returned success without a valid photo URL.',
        );
      }

      String message = 'HTTP ${response.statusCode}';

      if (result is Map) {
        final dynamic error = result['error'];

        if (error is Map && error['message'] is String) {
          message = error['message'] as String;
        }
      }

      throw Exception('Cloudinary rejected the upload: $message');
    } on TimeoutException {
      throw Exception(
        'Upload timed out while $stage. '
        'Check the device internet connection and try again.',
      );
    } on http.ClientException catch (e) {
      throw Exception('Could not connect to Cloudinary: ${e.message}');
    } on FormatException {
      throw Exception('Cloudinary returned an invalid response.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Unexpected photo upload error: $e');
    }
  }

  // ============================================================
  // UPLOAD PRIMARY PET PHOTO
  // ============================================================

  Future<String> uploadPetPhotoBytes({
    required String petId,
    required Uint8List bytes,
  }) async {
    try {
      return await _uploadPhotoToCloudinary(
        filename: 'pet_${petId}_primary.jpg',
        bytes: bytes,
      );
    } catch (e) {
      throw Exception('Unable to upload the primary pet photo: $e');
    }
  }

  // ============================================================
  // UPLOAD ADDITIONAL PET PHOTO
  // ============================================================

  Future<String> uploadAdditionalPetPhotoBytes({
    required String petId,
    required int slot,
    required Uint8List bytes,
  }) async {
    if (slot < 1 || slot >= maxPetPhotos) {
      throw Exception('Additional photo slot must be 1, 2, or 3.');
    }

    try {
      return await _uploadPhotoToCloudinary(
        filename: 'pet_${petId}_angle_$slot.jpg',
        bytes: bytes,
      );
    } catch (e) {
      throw Exception('Unable to upload additional pet photo: $e');
    }
  }

  // ============================================================
  // PUBLIC PET INFORMATION
  // Never expose owner names, contact numbers, or owner IDs.
  // ============================================================

  Map<String, dynamic> _publicPetData({
    required String petId,
    required String petName,
    required String breed,
    required String color,
    required String age,
    required String sex,
    required String identifyingMarks,
    required String photoUrl,
    required List<String> photoUrls,
    required String status,
    required bool qrEnabled,
  }) {
    return {
      'petId': petId,
      'petName': petName,
      'breed': breed,
      'color': color,
      'age': age,
      'sex': sex,
      'identifyingMarks': identifyingMarks,
      'photoUrl': photoUrl,
      'photoUrls': photoUrls,
      'status': status,
      'qrEnabled': qrEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // CURRENT USER'S PETS — DIAGNOSTIC VERSION
  //
  // The original private query is preserved.
  // No security rules are bypassed or changed.
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyPetsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      debugPrint(
        '[PAWLINK_DIAG] My Pets: no authenticated Firebase user.',
      );
      return const Stream.empty();
    }

    debugPrint('========== PAWLINK MY PETS QUERY ==========');
    debugPrint('[PAWLINK_DIAG] Firebase project: '
        '${_firestore.app.options.projectId}');
    debugPrint('[PAWLINK_DIAG] Authenticated: ${_auth.currentUser != null}');
    debugPrint('[PAWLINK_DIAG] User UID: ${user.uid}');
    debugPrint('[PAWLINK_DIAG] Collection: /pets');
    debugPrint('[PAWLINK_DIAG] Operation: realtime snapshots query');
    debugPrint('[PAWLINK_DIAG] Filter: ownerIds arrayContains current UID');
    debugPrint('[PAWLINK_DIAG] Starting request...');
    debugPrint('============================================');

    return _pets
        .where('ownerIds', arrayContains: user.uid)
        .snapshots()
        .transform(
          StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
              QuerySnapshot<Map<String, dynamic>>>.fromHandlers(
            handleData: (snapshot, sink) {
              debugPrint(
                '[PAWLINK_DIAG] /pets query SUCCESS',
              );
              debugPrint(
                '[PAWLINK_DIAG] Matching document count: '
                '${snapshot.docs.length}',
              );

              // Log document IDs only, not private document contents.
              for (final doc in snapshot.docs) {
                debugPrint(
                  '[PAWLINK_DIAG] Matching document ID: ${doc.id}',
                );
              }

              sink.add(snapshot);
            },
            handleError: (error, stackTrace, sink) {
              debugPrint(
                '[PAWLINK_DIAG] /pets query FAILED',
              );
              debugPrint(
                '[PAWLINK_DIAG] Error type: ${error.runtimeType}',
              );
              debugPrint('[PAWLINK_DIAG] Error: $error');
              debugPrint('[PAWLINK_DIAG] Stack trace: $stackTrace');

              // Forward the error so the existing UI still displays it.
              sink.addError(error, stackTrace);
            },
          ),
        );
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
  // GET PRIVATE PET
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getPet(
    String petId,
  ) async {
    try {
      return await _pets.doc(petId).get().timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to load pet information: $e');
    }
  }
  // ============================================================
  // TEMPORARY FIRESTORE PERMISSION DIAGNOSTIC
  // Remove after testing.
  // ============================================================

  Future<void> diagnosePetReadPermissions() async {
    const testPetId = 'fnDzRDDD6FzwX44Qh59G';

    final user = _auth.currentUser;

    debugPrint('========== PAWLINK PERMISSION TEST ==========');
    debugPrint('Project: ${_firestore.app.options.projectId}');
    debugPrint('Database: (default)');
    debugPrint('Authenticated: ${user != null}');
    debugPrint('UID: ${user?.uid ?? "Not signed in"}');
    debugPrint('Test pet ID: $testPetId');

    if (user == null) {
      debugPrint('RESULT: No authenticated Firebase user.');
      return;
    }

    // Test 1: Read one private pet document.
    try {
      final petSnapshot =
          await _pets.doc(testPetId).get().timeout(_firestoreTimeout);

      debugPrint(
        'DIRECT READ: SUCCESS; exists=${petSnapshot.exists}',
      );
    } catch (e, stackTrace) {
      debugPrint('DIRECT READ: FAILED; $e');
      debugPrint('$stackTrace');
    }

    // Test 2: Query private pets owned by the signed-in user.
    try {
      final querySnapshot = await _pets
          .where('ownerIds', arrayContains: user.uid)
          .get()
          .timeout(_firestoreTimeout);

      debugPrint(
        'OWNER QUERY: SUCCESS; count=${querySnapshot.docs.length}',
      );

      for (final doc in querySnapshot.docs) {
        debugPrint('OWNER QUERY PET ID: ${doc.id}');
      }
    } catch (e, stackTrace) {
      debugPrint('OWNER QUERY: FAILED; $e');
      debugPrint('$stackTrace');
    }

    debugPrint('========== END PERMISSION TEST ==========');
  }

  // ============================================================
  // GET PRIVATE PET STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getPetStream(
    String petId,
  ) {
    return _pets.doc(petId).snapshots();
  }

  // ============================================================
  // GET PUBLIC PET
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> getPublicPet(
    String petId,
  ) async {
    try {
      return await _publicPets.doc(petId).get().timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to load public pet information: $e');
    }
  }

  // ============================================================
  // CREATE PET + PUBLIC QR PROFILE
  // ============================================================

  Future<String> createPet({
    required String petName,
    required String breed,
    required String color,
    required String age,
    required String ownerName,
    required String ownerContact,
    String? photoUrl,
    List<String>? photoUrls,
    String safetyTag = 'safe',
    String identifyingMarks = '',
    String sex = 'unknown',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to register a pet.');
    }

    final petRef = _pets.doc();
    final publicPetRef = _publicPets.doc(petRef.id);

    final normalizedSex = _normalizeSex(sex);
    final normalizedSafetyTag = _normalizeSafetyTag(safetyTag);
    final normalizedMarks = identifyingMarks.trim();

    final List<String> normalizedPhotoUrls;

    if (photoUrls != null) {
      normalizedPhotoUrls = _normalizePhotoUrls(photoUrls);
    } else {
      final primaryUrl = (photoUrl ?? '').trim();

      normalizedPhotoUrls =
          primaryUrl.isEmpty ? <String>[] : <String>[primaryUrl];
    }

    final normalizedPhotoUrl = normalizedPhotoUrls.isNotEmpty
        ? normalizedPhotoUrls.first
        : (photoUrl ?? '').trim();

    final petData = <String, dynamic>{
      'petId': petRef.id,
      'petName': petName.trim(),
      'breed': breed.trim(),
      'color': color.trim(),
      'age': age.trim(),
      'identifyingMarks': normalizedMarks,
      'sex': normalizedSex,
      'photoUrl': normalizedPhotoUrl,
      'photoUrls': normalizedPhotoUrls,
      'ownerIds': [user.uid],
      'primaryOwnerId': user.uid,
      'ownerName': ownerName.trim(),
      'ownerContact': ownerContact.trim(),
      'status': 'alive',
      'safetyTag': normalizedSafetyTag,
      'qrEnabled': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final publicData = _publicPetData(
      petId: petRef.id,
      petName: petName.trim(),
      breed: breed.trim(),
      color: color.trim(),
      age: age.trim(),
      sex: normalizedSex,
      identifyingMarks: normalizedMarks,
      photoUrl: normalizedPhotoUrl,
      photoUrls: normalizedPhotoUrls,
      status: 'alive',
      qrEnabled: true,
    );

    final batch = _firestore.batch();

    batch.set(petRef, petData);
    batch.set(publicPetRef, publicData);

    try {
      await batch.commit().timeout(_firestoreTimeout);
      return petRef.id;
    } catch (e) {
      throw Exception('Unable to register pet: $e');
    }
  }

  // ============================================================
  // UPDATE PET + PUBLIC QR PROFILE
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
    List<String>? photoUrls,
    String? safetyTag,
    String? identifyingMarks,
    String? sex,
  }) async {
    final petRef = _pets.doc(petId);
    final publicPetRef = _publicPets.doc(petId);

    try {
      await _firestore.runTransaction((transaction) async {
        final petSnapshot = await transaction.get(petRef);

        if (!petSnapshot.exists) {
          throw Exception('Pet profile not found.');
        }

        final pet = petSnapshot.data()!;

        final currentPhotoUrl = (pet['photoUrl'] ?? '').toString();
        final currentStatus = (pet['status'] ?? 'alive').toString();
        final currentQrEnabled = pet['qrEnabled'] == true;
        final currentSex = (pet['sex'] ?? 'unknown').toString();
        final currentMarks = (pet['identifyingMarks'] ?? '').toString();

        final currentPhotoUrls = _readPhotoUrls(pet);

        final normalizedSex =
            sex != null ? _normalizeSex(sex) : _normalizeSex(currentSex);

        final normalizedMarks =
            identifyingMarks != null ? identifyingMarks.trim() : currentMarks;

        late final List<String> normalizedPhotoUrls;

        if (photoUrls != null) {
          normalizedPhotoUrls = _normalizePhotoUrls(photoUrls);
        } else if (photoUrl != null) {
          final newPrimaryUrl = photoUrl.trim();

          normalizedPhotoUrls = newPrimaryUrl.isEmpty
              ? currentPhotoUrls.where((url) => url != currentPhotoUrl).toList()
              : [
                  newPrimaryUrl,
                  ...currentPhotoUrls.where(
                    (url) => url != newPrimaryUrl && url != currentPhotoUrl,
                  ),
                ];

          if (normalizedPhotoUrls.length > maxPetPhotos) {
            normalizedPhotoUrls.removeRange(
              maxPetPhotos,
              normalizedPhotoUrls.length,
            );
          }
        } else {
          normalizedPhotoUrls = currentPhotoUrls;
        }

        final normalizedPhotoUrl = normalizedPhotoUrls.isNotEmpty
            ? normalizedPhotoUrls.first
            : (photoUrls != null ? '' : currentPhotoUrl);

        final Map<String, dynamic> updates = {
          'petName': petName.trim(),
          'breed': breed.trim(),
          'color': color.trim(),
          'age': age.trim(),
          'ownerName': ownerName.trim(),
          'ownerContact': ownerContact.trim(),
          'identifyingMarks': normalizedMarks,
          'sex': normalizedSex,
          'photoUrl': normalizedPhotoUrl,
          'photoUrls': normalizedPhotoUrls,
          'status': currentStatus,
          'qrEnabled': currentQrEnabled,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (safetyTag != null) {
          updates['safetyTag'] = _normalizeSafetyTag(safetyTag);
        }

        final syncedPublicData = _publicPetData(
          petId: petId,
          petName: petName.trim(),
          breed: breed.trim(),
          color: color.trim(),
          age: age.trim(),
          sex: normalizedSex,
          identifyingMarks: normalizedMarks,
          photoUrl: normalizedPhotoUrl,
          photoUrls: normalizedPhotoUrls,
          status: currentStatus,
          qrEnabled: currentQrEnabled,
        );

        transaction.update(petRef, updates);

        transaction.set(
          publicPetRef,
          syncedPublicData,
          SetOptions(merge: true),
        );
      }).timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to update pet information: $e');
    }
  }

  // ============================================================
  // UPDATE SAFETY TAG
  // ============================================================

  Future<void> updatePetSafetyTag({
    required String petId,
    required String safetyTag,
  }) async {
    try {
      await _pets.doc(petId).update({
        'safetyTag': _normalizeSafetyTag(safetyTag),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to update pet safety tag: $e');
    }
  }

  // ============================================================
  // UPDATE PET STATUS
  // ============================================================

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

    final petRef = _pets.doc(petId);
    final publicPetRef = _publicPets.doc(petId);

    final batch = _firestore.batch();

    batch.update(petRef, {
      'status': 'alive',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      publicPetRef,
      {
        'status': 'alive',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    try {
      await batch.commit().timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to update pet status: $e');
    }
  }

  // ============================================================
  // ADD CO-OWNER
  // ============================================================

  Future<void> addCoOwner({
    required String petId,
    required String ownerId,
  }) async {
    try {
      await _pets.doc(petId).update({
        'ownerIds': FieldValue.arrayUnion([ownerId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to add co-owner: $e');
    }
  }

  // ============================================================
  // REMOVE CO-OWNER
  // ============================================================

  Future<void> removeCoOwner({
    required String petId,
    required String ownerId,
  }) async {
    try {
      await _pets.doc(petId).update({
        'ownerIds': FieldValue.arrayRemove([ownerId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to remove co-owner: $e');
    }
  }

  // ============================================================
  // DELETE PET + PUBLIC QR PROFILE + LEGACY FIREBASE PHOTOS
  // ============================================================

  Future<void> deletePet(String petId) async {
    final batch = _firestore.batch();

    batch.delete(_pets.doc(petId));
    batch.delete(_publicPets.doc(petId));

    try {
      await batch.commit().timeout(_firestoreTimeout);
    } catch (e) {
      throw Exception('Unable to delete pet profile: $e');
    }

    // Legacy Firebase Storage cleanup; Cloudinary is unchanged.
    try {
      await _storage
          .ref()
          .child('pet_images')
          .child('$petId.jpg')
          .delete()
          .timeout(_uploadTimeout);
    } catch (_) {
      // The legacy photo may not exist.
    }

    try {
      final folder = _storage.ref().child('pet_images').child(petId);
      final result = await folder.listAll().timeout(_uploadTimeout);

      for (final item in result.items) {
        try {
          await item.delete().timeout(_uploadTimeout);
        } catch (_) {
          // Continue cleaning up other legacy photos.
        }
      }
    } catch (_) {
      // Legacy additional photos may not exist.
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
