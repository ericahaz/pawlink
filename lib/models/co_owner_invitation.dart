part of pawlink_admin;

class CoOwnerInvitation {
  final String id;
  final String petId;
  final String petName;
  final String owner;
  final String link;
  String status;

  CoOwnerInvitation({
    required this.id,
    required this.petId,
    required this.petName,
    required this.owner,
    required this.link,
    this.status = 'Pending',
  });
}

