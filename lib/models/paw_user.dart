part of pawlink_admin;

class PawUser {
  final String id;
  String name;
  final String email;
  final String contact;
  final String address;
  final String userType;
  final bool verified;
  final bool consent;

  PawUser({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    required this.userType,
    this.verified = false,
    this.consent = true,
  });
}

