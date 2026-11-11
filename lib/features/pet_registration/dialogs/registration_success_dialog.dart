part of pawlink_admin;

class RegistrationSuccessDialog extends StatelessWidget {
  final PetRecord pet;

  const RegistrationSuccessDialog({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: pageBackground,
      title: const Row(
        children: [
          Icon(
            Icons.check_circle,
            color: successText,
          ),
          SizedBox(width: 10),
          Text('Registration Complete'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${pet.animalType} • ${pet.breed}',
              style: const TextStyle(
                color: textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: pageBackground,
                border:
                    Border.all(color: borderColor),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: petQrUrl(pet),
                size: 200,
                backgroundColor: pageBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pet.qrId,
              style: const TextStyle(
                color: forestGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'This QR can be placed on the pet tag. '
              'When scanned, it identifies the PawLink pet profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PetScanPreviewPage(pet: pet),
              ),
            );
          },
          icon: const Icon(
            Icons.qr_code_scanner,
          ),
          label: const Text('Scan Preview'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: forestGreen,
          ),
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

// ============================================================
// PET CARD
// ============================================================

