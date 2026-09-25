import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String type;

  final String? petId;
  final String? petName;
  final String? title;
  final String? name;

  final String location;
  final String details;

  final String? lastSeenLocation;
  final String? foundLocation;
  final String? locationName;

  final String? foundDate;
  final String? message;
  final String? photoUrl;

  final String? reportedBy;
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
    this.title,
    this.name,
    this.lastSeenLocation,
    this.foundLocation,
    this.locationName,
    this.foundDate,
    this.message,
    this.photoUrl,
    this.reportedBy,
    this.reporterEmail,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // FIRESTORE → MODEL
  // ============================================================

  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return ReportModel(
      reportId: (data['reportId'] ?? document.id).toString(),

      type: normalizeType(data['type']),

      petId: _stringOrNull(data['petId']),
      petName: _stringOrNull(data['petName']),
      title: _stringOrNull(data['title']),
      name: _stringOrNull(data['name']),

      location: _stringValue(
        data['location'] ??
            data['lastSeenLocation'] ??
            data['foundLocation'] ??
            data['locationName'],
      ),

      details: _stringValue(
        data['details'] ?? data['description'] ?? data['message'],
      ),

      lastSeenLocation: _stringOrNull(data['lastSeenLocation']),

      foundLocation: _stringOrNull(data['foundLocation']),

      locationName: _stringOrNull(data['locationName']),

      foundDate: _stringOrNull(data['foundDate']),

      message: _stringOrNull(data['message']),

      photoUrl: _stringOrNull(data['photoUrl']),

      reportedBy: _stringOrNull(data['reportedBy']),

      reporterEmail: _stringOrNull(data['reporterEmail']),

      status: normalizeStatus(data['status']),

      latitude: _doubleOrNull(data['latitude']),

      longitude: _doubleOrNull(data['longitude']),

      createdAt: _dateTimeOrNull(data['createdAt']),

      updatedAt: _dateTimeOrNull(data['updatedAt']),
    );
  }

  // ============================================================
  // MODEL → FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,

      'type': normalizeType(type),

      'petId': petId,
      'petName': petName,
      'title': title,
      'name': name,

      'location': location,
      'details': details,

      'lastSeenLocation': lastSeenLocation,
      'foundLocation': foundLocation,
      'locationName': locationName,

      'foundDate': foundDate,
      'message': message,
      'photoUrl': photoUrl ?? '',

      'reportedBy': reportedBy,
      'reporterEmail': reporterEmail,

      'status': normalizeStatus(status),

      'latitude': latitude,
      'longitude': longitude,

      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // ============================================================
  // TYPE NORMALIZATION
  // ============================================================

  static String normalizeType(dynamic value) {
    final type = value?.toString().trim().toLowerCase() ?? '';

    switch (type) {
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
    final status = value?.toString().trim().toLowerCase() ?? '';

    switch (status) {
      case 'active':
        return 'active';

      case 'pending':
        return 'pending';

      case 'resolved':
        return 'resolved';

      case 'closed':
        return 'closed';

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
  // HELPERS
  // ============================================================

  static String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static double? _doubleOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
