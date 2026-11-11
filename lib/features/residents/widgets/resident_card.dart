part of pawlink_admin;

class ResidentCard extends StatelessWidget {
  final PawUser user;
  final VoidCallback onChanged;

  const ResidentCard({
    super.key,
    required this.user,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ownedPets =
        pets.where((p) => p.owner == user.name).toList();

    final activePets =
        ownedPets.where((p) => !p.deceased).toList();

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 27,
              backgroundColor: softBeige,
              child: Icon(
                Icons.person_outline,
                color: forestGreen,
              ),
            ),
            const SizedBox(width: 17),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const StatusChip(
                        text: 'RESIDENT',
                        type: ChipType.mutedGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${user.email} • ${user.contact} • ${user.address}',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'REGISTERED PETS (${ownedPets.length})',
                    style: sectionLabelStyle,
                  ),
                  const SizedBox(height: 7),
                  if (ownedPets.isEmpty)
                    const Text(
                      'No registered pets.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  for (final pet in ownedPets)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            petIcon(pet.animalType),
                            size: 15,
                            color: forestGreen,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${pet.name} • ${pet.animalType} • ${pet.breed}',
                            style:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusChip(
                            text: pet.deceased
                                ? 'DECEASED'
                                : pet.status
                                    .toUpperCase(),
                            type: pet.deceased
                                ? ChipType.gray
                                : pet.status ==
                                        'Missing'
                                    ? ChipType
                                        .warning
                                    : ChipType
                                        .success,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Resident actions',
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'view') {
                  showDialog(
                    context: context,
                    builder: (_) => UserDetailsDialog(user: user),
                  );
                } else if (value == 'delete') {
                  if (activePets.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.block_outlined, color: warningText),
                            SizedBox(width: 10),
                            Text('Account Cannot Be Deleted'),
                          ],
                        ),
                        content: Text(
                          '${user.name} still has active registered pets: '
                          '${activePets.map((p) => p.name).join(', ')}. '
                          'Mark the appropriate pet records as deceased or transfer ownership before deleting this account.',
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => DeleteUserDialog(
                        user: user,
                        onDeleted: onChanged,
                      ),
                    );
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.visibility_outlined, color: forestGreen),
                    title: Text('View Full Information'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.person_remove_outlined, color: dangerText),
                    title: Text('Delete Account'),
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

// ============================================================
// BARANGAY OFFICIALS
// ============================================================

