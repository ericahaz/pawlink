part of pawlink_admin;

class AdminPetService {
  AdminPetService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _petsRef =>
      _firestore.collection('pets');

  Stream<List<PetRecord>> getPetsStream() {
    return _petsRef
        .orderBy('petName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _petRecordFromFirestore(doc)).toList();
    });
  }

  Stream<List<PetRecord>> getPetsByOwnerStream(String ownerId) {
    return _petsRef
        .where('ownerIds', arrayContains: ownerId)
        .orderBy('petName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _petRecordFromFirestore(doc)).toList();
    });
  }

  Future<PetRecord?> getPet(String petId) async {
    final doc = await _petsRef.doc(petId).get();
    if (!doc.exists) return null;
    return _petRecordFromFirestore(doc);
  }

  PetRecord _petRecordFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final ownerIds = List<String>.from(data['ownerIds'] ?? <String>[]);
    final primaryOwnerId = data['primaryOwnerId']?.toString() ?? '';
    final ownerName = data['ownerName']?.toString() ?? '';
    final ownerContact = data['ownerContact']?.toString() ?? '';

    final photoUrls = _readPhotoUrls(data);
    final photoUrl = photoUrls.isNotEmpty
        ? photoUrls.first
        : (data['photoUrl']?.toString() ?? '');

    return PetRecord(
      id: doc.id,
      name: data['petName']?.toString() ?? '',
      category: _getCategory(data['breed']?.toString() ?? ''),
      animalType: _getAnimalType(data['breed']?.toString() ?? ''),
      breed: data['breed']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      sex: data['sex']?.toString() ?? 'unknown',
      age: data['age']?.toString() ?? '',
      owner: ownerName,
      coOwners: ownerIds.where((id) => id != primaryOwnerId).toList(),
      vaccinated: false,
      vaccinationDate: '',
      nextVaccination: '',
      deceased: data['status'] == 'dead',
      status: data['status']?.toString() ?? 'alive',
      marks: data['identifyingMarks']?.toString() ?? '',
      qrId: doc.id,
      photoLabel: photoUrl,
      safetyLevel: _normalizeSafetyTag(data['safetyTag']),
      photos: photoUrls,
    );
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
        return urls.take(4).toList();
      }
    }

    final String oldPhotoUrl = (data['photoUrl'] ?? '').toString().trim();

    return oldPhotoUrl.isEmpty ? <String>[] : <String>[oldPhotoUrl];
  }

  String _normalizeSafetyTag(dynamic value) {
    final tag = value?.toString().toLowerCase().trim();

    switch (tag) {
      case 'safe':
      case 'green':
        return 'Safe';
      case 'caution':
      case 'yellow':
        return 'Caution';
      case 'aggressive':
      case 'red':
        return 'Aggressive';
      default:
        return 'Safe';
    }
  }

  String _getCategory(String breed) {
    final b = breed.toLowerCase();
    if (b.contains('dog') || b.contains('puppy') || b.contains('retriever') ||
        b.contains('shepherd') || b.contains('bulldog') || b.contains('poodle') ||
        b.contains('beagle') || b.contains('husky') || b.contains('labrador') ||
        b.contains('german') || b.contains('golden') || b.contains('rottweiler') ||
        b.contains('boxer') || b.contains('dachshund') || b.contains('pug') ||
        b.contains('shih tzu') || b.contains('chihuahua') || b.contains('pomeranian')) {
      return 'Dog';
    }
    if (b.contains('cat') || b.contains('kitten') || b.contains('persian') ||
        b.contains('siamese') || b.contains('maine coon') || b.contains('ragdoll') ||
        b.contains('bengal') || b.contains('sphynx') || b.contains('british') ||
        b.contains('scottish') || b.contains('russian blue')) {
      return 'Cat';
    }
    return 'Other';
  }

  String _getAnimalType(String breed) {
    final b = breed.toLowerCase();
    if (b.contains('dog') || b.contains('puppy') || b.contains('retriever') ||
        b.contains('shepherd') || b.contains('bulldog') || b.contains('poodle') ||
        b.contains('beagle') || b.contains('husky') || b.contains('labrador') ||
        b.contains('german') || b.contains('golden') || b.contains('rottweiler') ||
        b.contains('boxer') || b.contains('dachshund') || b.contains('pug') ||
        b.contains('shih tzu') || b.contains('chihuahua') || b.contains('pomeranian')) {
      return 'Dog';
    }
    if (b.contains('cat') || b.contains('kitten') || b.contains('persian') ||
        b.contains('siamese') || b.contains('maine coon') || b.contains('ragdoll') ||
        b.contains('bengal') || b.contains('sphynx') || b.contains('british') ||
        b.contains('scottish') || b.contains('russian blue')) {
      return 'Cat';
    }
    return 'Other';
  }

  Future<void> updatePet(PetRecord pet) async {
    final updates = <String, dynamic>{
      'petName': pet.name,
      'breed': pet.breed,
      'color': pet.color,
      'age': pet.age,
      'sex': pet.sex,
      'identifyingMarks': pet.marks,
      'status': pet.deceased ? 'dead' : 'alive',
      'safetyTag': _normalizeSafetyTagForFirestore(pet.safetyLevel),
      'photoUrl': pet.photos.isNotEmpty ? pet.photos.first : '',
      'photoUrls': pet.photos,
      'ownerName': pet.owner,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _petsRef.doc(pet.id).update(updates);
  }

  Future<void> deletePet(String petId) async {
    await _petsRef.doc(petId).delete();
  }

  Future<void> markDeceased(String petId, bool deceased) async {
    await _petsRef.doc(petId).update({
      'status': deceased ? 'dead' : 'alive',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _normalizeSafetyTagForFirestore(String safetyLevel) {
    switch (safetyLevel.toLowerCase()) {
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