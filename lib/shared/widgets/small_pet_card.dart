part of pawlink_admin;

class SmallPetCard extends StatelessWidget {
  final PetRecord pet;

  const SmallPetCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(17),
        leading: CircleAvatar(
          backgroundColor: softBeige,
          child: Icon(
            petIcon(pet.animalType),
            color: forestGreen,
          ),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${pet.animalType} • ${pet.breed}\n'
          'Owner: ${pet.owner}',
        ),
        isThreeLine: true,
        trailing: StatusChip(
          text: pet.deceased
              ? 'DECEASED'
              : pet.status.toUpperCase(),
          type: pet.deceased
              ? ChipType.gray
              : pet.status == 'Missing'
                  ? ChipType.warning
                  : ChipType.success,
        ),
      ),
    );
  }
}

