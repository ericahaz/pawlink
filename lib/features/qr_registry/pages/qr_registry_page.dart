part of pawlink_admin;

class QRRegistryPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const QRRegistryPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<QRRegistryPage> createState() =>
      _QRRegistryPageState();
}

class _QRRegistryPageState
    extends State<QRRegistryPage> {
  final scanController = TextEditingController();

  void checkQr() {
    final input =
        scanController.text.trim();

    if (input.isEmpty) {
      return;
    }

    PetRecord? found;

    for (final pet in pets) {
      if (pet.qrId.toLowerCase() ==
              input.toLowerCase() ||
          petQrUrl(pet)
              .toLowerCase() ==
              input.toLowerCase()) {
        found = pet;
        break;
      }
    }

    if (found == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('QR Not Found'),
          content: Text(
            'No registered PawLink pet matches that QR code.',
          ),
        ),
      );
      return;
    }

    logActivity(
      'Checked pet QR',
      '${found.qrId} • ${found.name}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PetScanPreviewPage(
          pet: found!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'QR Registry',
      subtitle:
          'View generated QR codes and check PawLink pet QR information.',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: softBeige,
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: forestGreen,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller:
                          scanController,
                      onSubmitted: (_) =>
                          checkQr(),
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Enter or paste QR ID / scanned PawLink QR URL',
                        prefixIcon: Icon(
                          Icons.qr_code_2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          forestGreen,
                    ),
                    onPressed: checkQr,
                    icon: const Icon(
                      Icons.search,
                    ),
                    label: const Text(
                      'Check QR',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle(
            'Generated Pet QR Codes',
          ),
          const SizedBox(height: 12),
          for (final pet in pets)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Padding(
                  padding:
                      const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        padding:
                            const EdgeInsets.all(
                          7,
                        ),
                        decoration:
                            BoxDecoration(
                          color: pageBackground,
                          border: Border.all(
                            color:
                                borderColor,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child: QrImageView(
                          data:
                              petQrUrl(pet),
                        ),
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  pet.name,
                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                                const SizedBox(
                                    width: 8),
                                StatusChip(
                                  text: pet
                                          .deceased
                                      ? 'INACTIVE'
                                      : 'ACTIVE',
                                  type: pet
                                          .deceased
                                      ? ChipType
                                          .gray
                                      : ChipType
                                          .success,
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: 4),
                            Text(
                              '${pet.animalType} • ${pet.breed} • ${pet.color}',
                              style:
                                  const TextStyle(
                                color:
                                    textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(
                                height: 7),
                            Text(
                              pet.qrId,
                              style:
                                  const TextStyle(
                                color:
                                    forestGreen,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'Owner: ${pet.owner}',
                              style:
                                  const TextStyle(
                                color:
                                    textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                PetQrDialog(
                              pet: pet,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.qr_code_2,
                        ),
                        label: const Text(
                          'View QR',
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style:
                            FilledButton
                                .styleFrom(
                          backgroundColor:
                              forestGreen,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PetScanPreviewPage(
                                pet: pet,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons
                              .qr_code_scanner,
                        ),
                        label: const Text(
                          'Scan Preview',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// PET QR DIALOG
// ============================================================

