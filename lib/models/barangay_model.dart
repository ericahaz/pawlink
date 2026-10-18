import 'package:cloud_firestore/cloud_firestore.dart';

class BarangayModel {
  final String barangayName;
  final String municipality;
  final String province;
  final String phone;
  final String email;
  final String address;
  final String officeHours;
  final bool isActive;
  final DateTime? updatedAt;

  const BarangayModel({
    this.barangayName = '',
    this.municipality = '',
    this.province = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.officeHours = '',
    this.isActive = false,
    this.updatedAt,
  });

  /// Creates a BarangayModel from a Firestore document.
  factory BarangayModel.fromFirestore(
    Map<String, dynamic> data,
  ) {
    final timestamp = data['updatedAt'];

    return BarangayModel(
      barangayName: data['barangayName'] as String? ?? '',
      municipality: data['municipality'] as String? ?? '',
      province: data['province'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      address: data['address'] as String? ?? '',
      officeHours: data['officeHours'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  /// Converts the model to a Firestore-compatible map.
  ///
  /// updatedAt is added by BarangayService when saving.
  Map<String, dynamic> toMap() {
    return {
      'barangayName': barangayName.trim(),
      'municipality': municipality.trim(),
      'province': province.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'officeHours': officeHours.trim(),
      'isActive': isActive,
    };
  }

  /// Creates an empty model for an unconfigured barangay.
  factory BarangayModel.empty() {
    return const BarangayModel();
  }
}
