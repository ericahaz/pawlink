part of pawlink_admin;

class PetQrDialog extends StatelessWidget {
  final PetRecord pet;

  const PetQrDialog({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final url = petQrUrl(pet);

    return AlertDialog(
      backgroundColor: pageBackground,
      title: Text(
        '${pet.name} — QR Code',
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border:
                    Border.all(color: borderColor),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: url,
                size: 230,
              ),
            ),
            const SizedBox(height: 13),
            Text(
              pet.qrId,
              style: const TextStyle(
                color: forestGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            SelectableText(
              url,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textMuted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: url),
                );

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Pet QR link copied.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text(
                'Copy QR Link',
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
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
          child: const Text(
            'Scan Preview',
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: forestGreen,
          ),
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// ============================================================
// QR SCAN PREVIEW
// ============================================================

