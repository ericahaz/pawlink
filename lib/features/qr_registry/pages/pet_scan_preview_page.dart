part of pawlink_admin;

class PetScanPreviewPage extends StatelessWidget {
  final PetRecord pet;

  const PetScanPreviewPage({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets,
              color: forestGreen,
            ),
            SizedBox(width: 8),
            Text('PawLink Pet Check'),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 650,
            ),
            child: AppCard(
              child: Padding(
                padding:
                    const EdgeInsets.all(30),
                child: Column(
                  children: [
                    PhotoPlaceholder(
                      label: pet.photoLabel,
                      icon: petIcon(
                        pet.animalType,
                      ),
                      width: 135,
                      height: 135,
                    ),
                    const SizedBox(height: 15),
                    const StatusChip(
                      text:
                          'PAWLINK REGISTERED PET',
                      type: ChipType.success,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${pet.animalType} • ${pet.breed}',
                      style: const TextStyle(
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Divider(),
                    const SizedBox(height: 10),
                    DetailLine(
                      label: 'Color',
                      value: pet.color,
                    ),
                    DetailLine(
                      label: 'Sex',
                      value: pet.sex,
                    ),
                    DetailLine(
                      label: 'Age',
                      value: pet.age,
                    ),
                    DetailLine(
                      label:
                          'Identifying Marks',
                      value: pet.marks,
                    ),
                    DetailLine(
                      label: 'Pet Status',
                      value: pet.status,
                    ),
                    DetailLine(
                      label: 'QR ID',
                      value: pet.qrId,
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: pet.safetyLevel == 'Safe'
                            ? successBg
                            : pet.safetyLevel == 'Caution'
                                ? warningBg
                                : dangerBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            pet.safetyLevel == 'Safe'
                                ? Icons.verified_user_outlined
                                : pet.safetyLevel == 'Caution'
                                    ? Icons.warning_amber_rounded
                                    : Icons.dangerous_outlined,
                            color: pet.safetyLevel == 'Safe'
                                ? successText
                                : pet.safetyLevel == 'Caution'
                                    ? warningText
                                    : dangerText,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.safetyLevel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: pet.safetyLevel == 'Safe'
                                        ? successText
                                        : pet.safetyLevel == 'Caution'
                                            ? warningText
                                            : dangerText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  pet.safetyLevel == 'Safe'
                                      ? 'Owner marked this pet as generally safe to approach.'
                                      : pet.safetyLevel == 'Caution'
                                          ? 'Approach carefully. The pet may be frightened, nervous, or defensive.'
                                          : 'Do not approach or attempt to restrain this pet. Contact the owner or barangay support.',
                                  style: const TextStyle(fontSize: 11, height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: lightCream,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons
                                .privacy_tip_outlined,
                            color: forestGreen,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Private account details such as the owner\'s '
                              'full address and password are not displayed '
                              'through the pet QR profile.',
                              style: TextStyle(
                                color:
                                    textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style:
                            FilledButton.styleFrom(
                          backgroundColor:
                              forestGreen,
                        ),
                        onPressed: pet.deceased
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        QrFoundPetPage(
                                      pet: pet,
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(
                          Icons
                              .location_on_outlined,
                        ),
                        label: Text(
                          pet.deceased
                              ? 'QR Profile Inactive'
                              : 'I Found This Pet',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FOUND VIA QR
// ============================================================

