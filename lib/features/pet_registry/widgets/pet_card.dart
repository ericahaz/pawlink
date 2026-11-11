part of pawlink_admin;

class PetCard extends StatelessWidget {
  final PetRecord pet;
  final VoidCallback onChanged;

  const PetCard({
    super.key,
    required this.pet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoPlaceholder(
              label: pet.photoLabel,
              icon: petIcon(pet.animalType),
              width: 95,
              height: 95,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      StatusChip(
                        text: pet.animalType.toUpperCase(),
                        type: ChipType.mutedGreen,
                      ),
                      StatusChip(
                        text: pet.deceased ? 'DECEASED' : pet.status.toUpperCase(),
                        type: pet.deceased
                            ? ChipType.gray
                            : pet.status == 'Missing'
                                ? ChipType.warning
                                : ChipType.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${pet.id} • ${pet.qrId}',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      InfoBox(
                        icon: petIcon(pet.animalType),
                        label: 'TYPE',
                        value: pet.animalType,
                      ),
                      InfoBox(
                        icon: Icons.pets_outlined,
                        label: 'BREED',
                        value: pet.breed,
                      ),
                      InfoBox(
                        icon: Icons.palette_outlined,
                        label: 'COLOR',
                        value: pet.color,
                      ),
                      InfoBox(
                        icon: pet.sex.toLowerCase() == 'female' ? Icons.female : Icons.male,
                        label: 'SEX',
                        value: pet.sex,
                      ),
                      InfoBox(
                        icon: Icons.cake_outlined,
                        label: 'AGE',
                        value: pet.age,
                      ),
                      InfoBox(
                        icon: Icons.person_outline,
                        label: 'OWNER',
                        value: pet.owner,
                        width: 190,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(context: context, builder: (_) => PetQrDialog(pet: pet));
              },
              icon: const Icon(Icons.qr_code_2),
              label: const Text('QR'),
            ),
            const SizedBox(width: 5),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  showDialog(context: context, builder: (_) => PetScanPreviewPage(pet: pet));
                } else if (value == 'invite') {
                  showDialog(context: context, builder: (_) => CreateInvitationDialog(pet: pet, onCreated: onChanged));
                } else if (value == 'deceased') {
                  showDialog(context: context, builder: (_) => MarkDeceasedDialog(pet: pet, onChanged: onChanged));
                } else if (value == 'delete') {
                  showDialog(context: context, builder: (_) => DeletePetDialog(pet: pet, onChanged: onChanged));
                }
              },
              tooltip: 'Pet actions',
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.visibility_outlined, color: forestGreen),
                    title: Text('View Full Information'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'invite',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.person_add_alt_1_outlined, color: forestGreen),
                    title: Text('Invite Co-owner'),
                  ),
                ),
                if (!pet.deceased)
                  const PopupMenuItem(
                    value: 'deceased',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.heart_broken_outlined, color: warningText),
                      title: Text('Mark as Deceased'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.delete_outline, color: dangerText),
                    title: Text('Delete Pet Record'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
