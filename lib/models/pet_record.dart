part of pawlink_admin;

class PetRecord {
  final String id;
  String name;
  String category;
  String animalType;
  String breed;
  String color;
  String sex;
  String age;
  String owner;
  List<String> coOwners;
  bool vaccinated;
  String vaccinationDate;
  String nextVaccination;
  bool deceased;
  String status;
  String marks;
  String qrId;
  String photoLabel;
  String safetyLevel;
  List<String> photos;

  PetRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.animalType,
    required this.breed,
    required this.color,
    required this.sex,
    required this.age,
    required this.owner,
    required this.coOwners,
    required this.vaccinated,
    required this.vaccinationDate,
    required this.nextVaccination,
    required this.deceased,
    required this.status,
    required this.marks,
    required this.qrId,
    required this.photoLabel,
    this.safetyLevel = 'Safe',
    this.photos = const [],
  });
}

