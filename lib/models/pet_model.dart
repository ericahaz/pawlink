import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String petId;
  final String petName;
  final String breed;
  final String color;
  final String age;
  final String photoUrl;

  // ============================================================
  // OWNERS
  // ============================================================

  final List<String> ownerIds;
  final String primaryOwnerId;

  final String ownerName;
  final String ownerContact;

  // ============================================================
  // SAFETY
  // ============================================================
  //
  // Stored values:
  // safe
  // caution
  // aggressive
  //
  // The UI can display these using green/yellow/red colors.
  //

  final String safetyTag;

  // ============================================================
  // PET STATUS
  // ============================================================
  //
  // Stored values:
  // alive
  // dead
  //
  // Note:
  // PetService permanently deletes the Firestore document when
  // the owner chooses to mark the pet as dead.
  //

  final String status;

  // ============================================================
  // QR
  // ============================================================

  final bool qrEnabled;

  // ============================================================
  // TIMESTAMPS
  // ============================================================

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PetModel({
    required this.petId,
    required this.petName,
    required this.breed,
    required this.color,
    required this.age,
    required this.photoUrl,
    required this.ownerIds,
    required this.primaryOwnerId,
    required this.ownerName,
    required this.ownerContact,
    required this.safetyTag,
    required this.status,
    required this.qrEnabled,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // FIRESTORE -> PET MODEL
  // ============================================================

  factory PetModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final rawOwnerIds = data['ownerIds'];

    final List<String> ownerIds = rawOwnerIds is List
        ? rawOwnerIds.map((id) => id.toString()).toList()
        : <String>[];

    return PetModel(
      petId: data['petId']?.toString() ?? document.id,
      petName: data['petName']?.toString() ?? '',
      breed: data['breed']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      age: data['age']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString() ?? '',
      ownerIds: ownerIds,
      primaryOwnerId: data['primaryOwnerId']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? '',
      ownerContact: data['ownerContact']?.toString() ?? '',
      safetyTag: _normalizeSafetyTag(data['safetyTag']),
      status: _normalizeStatus(data['status']),
      qrEnabled: data['qrEnabled'] == true,
      createdAt: _timestampToDateTime(data['createdAt']),
      updatedAt: _timestampToDateTime(data['updatedAt']),
    );
  }

  // ============================================================
  // PET MODEL -> FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'petName': petName,
      'breed': breed,
      'color': color,
      'age': age,
      'photoUrl': photoUrl,
      'ownerIds': ownerIds,
      'primaryOwnerId': primaryOwnerId,
      'ownerName': ownerName,
      'ownerContact': ownerContact,
      'safetyTag': _normalizeSafetyTag(safetyTag),
      'status': _normalizeStatus(status),
      'qrEnabled': qrEnabled,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  PetModel copyWith({
    String? petId,
    String? petName,
    String? breed,
    String? color,
    String? age,
    String? photoUrl,
    List<String>? ownerIds,
    String? primaryOwnerId,
    String? ownerName,
    String? ownerContact,
    String? safetyTag,
    String? status,
    bool? qrEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      ownerIds: ownerIds ?? this.ownerIds,
      primaryOwnerId: primaryOwnerId ?? this.primaryOwnerId,
      ownerName: ownerName ?? this.ownerName,
      ownerContact: ownerContact ?? this.ownerContact,
      safetyTag: safetyTag != null
          ? _normalizeSafetyTag(safetyTag)
          : this.safetyTag,
      status: status != null ? _normalizeStatus(status) : this.status,
      qrEnabled: qrEnabled ?? this.qrEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isAlive => status == 'alive';

  bool get isDead => status == 'dead';

  // ============================================================
  // SAFETY HELPERS
  // ============================================================

  bool get isSafe => safetyTag == 'safe';

  bool get isCaution => safetyTag == 'caution';

  bool get isAggressive => safetyTag == 'aggressive';

  String get safetyLabel {
    switch (safetyTag) {
      case 'caution':
        return 'CAUTION';

      case 'aggressive':
        return 'AGGRESSIVE • DO NOT APPROACH';

      case 'safe':
      default:
        return 'SAFE';
    }
  }

  // ============================================================
  // TIMESTAMP HELPER
  // ============================================================

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // ============================================================
  // SAFETY NORMALIZER
  // ============================================================

  static String _normalizeSafetyTag(dynamic value) {
    final tag = value?.toString().toLowerCase().trim();

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

  // ============================================================
  // STATUS NORMALIZER
  // ============================================================

  static String _normalizeStatus(dynamic value) {
    final status = value?.toString().toLowerCase().trim();

    switch (status) {
      case 'dead':
        return 'dead';

      case 'alive':
      default:
        return 'alive';
    }
  }
}