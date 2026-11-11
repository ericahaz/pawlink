part of pawlink_admin;

void logActivity(String action, String target) {
  activities.insert(
    0,
    AdminActivity(
      action: action,
      target: target,
      time: DateTime.now(),
    ),
  );
}

String formatTime(DateTime time) {
  final hour = time.hour == 0
      ? 12
      : time.hour > 12
          ? time.hour - 12
          : time.hour;

  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';

  return '$hour:$minute $period';
}

IconData petIcon(String type) {
  switch (type.toLowerCase()) {
    case 'bird':
      return Icons.flutter_dash;
    case 'rabbit':
      return Icons.cruelty_free_outlined;
    default:
      return Icons.pets;
  }
}

String generatePetId() {
  return 'PET-${(pets.length + 1).toString().padLeft(3, '0')}';
}

String generateQrId() {
  final number = 1600 + pets.length;
  return 'QR-PL-$number';
}

String petQrUrl(PetRecord pet) {
  // Replace this domain when your real PawLink web app is deployed.
  return 'https://pawlink.app/pet/${pet.qrId}';
}


const List<String> petAgeOptions = [
  'Less than 1 year',
  '1 year',
  '2 years',
  '3 years',
  '4 years',
  '5 years',
  '6 years',
  '7 years',
  '8 years',
  '9 years',
  '10 years',
  '11 years',
  '12 years',
  '13 years',
  '14 years',
  '15 years',
  '16 years',
  '17 years',
  '18 years',
  '19 years',
  '20+ years',
  'Unknown',
];

const Map<String, List<String>> petBreedOptions = {
  'Dog': [
    'Aspin',
    'Beagle',
    'Chihuahua',
    'Dachshund',
    'French Bulldog',
    'German Shepherd',
    'Golden Retriever',
    'Labrador Retriever',
    'Pomeranian',
    'Poodle',
    'Pug',
    'Shih Tzu',
    'Siberian Husky',
    'Mixed Breed',
    'Unknown',
    'Other / Specify breed',
  ],
  'Cat': [
    'Domestic Shorthair',
    'Domestic Longhair',
    'Persian',
    'Siamese',
    'British Shorthair',
    'Maine Coon',
    'Bengal',
    'Ragdoll',
    'Mixed Breed',
    'Unknown',
    'Other / Specify breed',
  ],
  'Bird': [
    'Budgerigar',
    'Cockatiel',
    'Lovebird',
    'Parakeet',
    'Canary',
    'Finch',
    'African Grey',
    'Macaw',
    'Mixed / Unknown',
    'Other / Specify breed',
  ],
  'Rabbit': [
    'Holland Lop',
    'Mini Rex',
    'Netherland Dwarf',
    'Lionhead',
    'Flemish Giant',
    'New Zealand',
    'Mixed Breed',
    'Unknown',
    'Other / Specify breed',
  ],
  'Other': [
    'Unknown',
    'Other / Specify breed',
  ],
};

List<String> breedsFor(String animalType) {
  return petBreedOptions[animalType] ?? petBreedOptions['Other']!;
}

