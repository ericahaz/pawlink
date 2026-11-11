part of pawlink_admin;

class AnimalReport {
  final String id;
  final String type;
  final String animalType;
  final String petName;
  final String breed;
  final String color;
  final String sex;
  final String reporter;
  final String location;
  final String date;
  final String description;
  final String photoLabel;
  final String? petId;
  String status;
  final bool qrScanned;

  AnimalReport({
    required this.id,
    required this.type,
    required this.animalType,
    required this.petName,
    required this.breed,
    required this.color,
    required this.sex,
    required this.reporter,
    required this.location,
    required this.date,
    required this.description,
    required this.photoLabel,
    required this.status,
    required this.qrScanned,
    this.petId,
  });
}

