import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String type;

  final String? petId;
  final String? petName;
  final String? breed;
  final String? color;
  final String? title;
  final String? name;

  final String location;
  final String details;
  final String? description;

  final String? lastSeenLocation;
  final String? foundLocation;
  final String? locationName;

  final String? foundDate;
  final DateTime? lostDate;
  final String? message;
  final String? photoUrl;

  final String? contactNumber;
  final String? reportedBy;
  final String? reporterId;
  final String? reporterEmail;

  final String status;

  final double? latitude;
  final double? longitude;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReportModel({
    required this.reportId,
    required this.type,
    required this.location,
    required this.details,
    required this.status,
    this.petId,
    this.petName,
    this.breed,
    this.color,
    this.title,
    this.name,
    this.description,
    this.lastSeenLocation,
    this.foundLocation,
    this.locationName,
    this.foundDate,
    this.lostDate,
    this.message,
    this.photoUrl,
    this.contactNumber,
    this.reportedBy,
    this.reporterId,
    this.reporterEmail,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // FIRESTORE -> MODEL
  // Supports both the ReportService and ReportLostPetPage formats.
  // ============================================================

  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    final rawType = data['type'] ?? data['reportType'];
    final rawReporter = data['reportedBy'] ?? data['reporterId'];
    final rawDetails =
        data['details'] ?? data['description'] ?? data['message'];

    final rawLocation = data['location'] ??
        data['lastSeenLocation'] ??
        data['foundLocation'] ??
        data['locationName'];

    return ReportModel(
      reportId: _stringValue(data['reportId'] ?? document.id),
      type: normalizeType(rawType),
      petId: _stringOrNull(data['petId']),
      petName: _stringOrNull(data['petName']),
      breed: _stringOrNull(data['breed']),
      color: _stringOrNull(data['color']),
      title: _stringOrNull(data['title']),
      name: _stringOrNull(data['name']),
      location: _stringValue(rawLocation),
      details: _stringValue(rawDetails),
      description: _stringOrNull(data['description']),
      lastSeenLocation: _stringOrNull(data['lastSeenLocation']),
      foundLocation: _stringOrNull(data['foundLocation']),
      locationName: _stringOrNull(data['locationName']),
      foundDate: _dateStringOrNull(data['foundDate']),
      lostDate: _dateTimeOrNull(data['lostDate']),
      message: _stringOrNull(data['message']),
      photoUrl: _stringOrNull(data['photoUrl']),
      contactNumber: _stringOrNull(data['contactNumber']),
      reportedBy: _stringOrNull(rawReporter),
      reporterId: _stringOrNull(data['reporterId']),
      reporterEmail: _stringOrNull(data['reporterEmail']),
      status: normalizeStatus(data['status']),
      latitude: _doubleOrNull(data['latitude']),
      longitude: _doubleOrNull(data['longitude']),
      createdAt: _dateTimeOrNull(data['createdAt']),
      updatedAt: _dateTimeOrNull(data['updatedAt']),
    );
  }

  // ============================================================
  // MODEL -> FIRESTORE
  // Writes compatible fields for both report formats.
  // ============================================================

  Map<String, dynamic> toMap() {
    final normalizedType = normalizeType(type);
    final normalizedReporter = reportedBy ?? reporterId;
    final normalizedDescription = description ?? details;

    return {
      'reportId': reportId,

      // Both formats are retained for compatibility.
      'type': normalizedType,
      'reportType': normalizedType,

      'petId': petId,
      'petName': petName,
      'breed': breed,
      'color': color,
      'title': title,
      'name': name,

      'location': location,
      'details': details,
      'description': normalizedDescription,

      'lastSeenLocation': lastSeenLocation,
      'foundLocation': foundLocation,
      'locationName': locationName,

      'foundDate': foundDate,
      'lostDate': lostDate == null ? null : Timestamp.fromDate(lostDate!),
      'message': message,
      'photoUrl': photoUrl ?? '',

      'contactNumber': contactNumber,

      'reportedBy': normalizedReporter,
      'reporterId': normalizedReporter,
      'reporterEmail': reporterEmail,

      'status': normalizeStatus(status),

      'latitude': latitude,
      'longitude': longitude,

      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  // ============================================================
  // TYPE NORMALIZATION
  // ============================================================

  static String normalizeType(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'lost':
      case 'lost_pet':
        return 'lost';

      case 'found':
      case 'found_pet':
        return 'found';

      case 'sighting':
      case 'sighted':
        return 'sighting';

      case 'barangay':
      case 'stray':
      case 'concern':
        return 'barangay';

      default:
        return 'unknown';
    }
  }

  // ============================================================
  // STATUS NORMALIZATION
  // ============================================================

  static String normalizeStatus(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'active':
        return 'active';

      case 'pending':
        return 'pending';

      case 'resolved':
        return 'resolved';

      case 'closed':
        return 'closed';

      case 'new':
        return 'active';

      default:
        return 'active';
    }
  }

  // ============================================================
  // TYPE HELPERS
  // ============================================================

  bool get isLost => type == 'lost';

  bool get isFound => type == 'found';

  bool get isSighting => type == 'sighting';

  bool get isBarangay => type == 'barangay';

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isActive => status == 'active';

  bool get isPending => status == 'pending';

  bool get isResolved => status == 'resolved';

  bool get isClosed => status == 'closed';

  // ============================================================
  // DISPLAY LABELS
  // ============================================================

  String get typeLabel {
    switch (type) {
      case 'lost':
        return 'Lost Pet';

      case 'found':
        return 'Found Pet';

      case 'sighting':
        return 'Pet Sighting';

      case 'barangay':
        return 'Barangay Report';

      default:
        return 'Report';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';

      case 'pending':
        return 'Pending';

      case 'resolved':
        return 'Resolved';

      case 'closed':
        return 'Closed';

      default:
        return 'Active';
    }
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _dateStringOrNull(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double? _doubleOrNull(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
