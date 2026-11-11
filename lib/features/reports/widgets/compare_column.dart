part of pawlink_admin;

class CompareColumn extends StatelessWidget {
  final String title;
  final AnimalReport report;

  const CompareColumn({
    super.key,
    required this.title,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: forestGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 12),
            PhotoPlaceholder(
              label: report.photoLabel,
              icon:
                  petIcon(report.animalType),
              width: double.infinity,
              height: 170,
            ),
            const SizedBox(height: 15),
            DetailLine(
              label: 'Pet',
              value: report.petName,
            ),
            DetailLine(
              label: 'Type',
              value: report.animalType,
            ),
            DetailLine(
              label: 'Breed',
              value: report.breed,
            ),
            DetailLine(
              label: 'Color',
              value: report.color,
            ),
            DetailLine(
              label: 'Sex',
              value: report.sex,
            ),
            DetailLine(
              label: 'Location',
              value: report.location,
            ),
            DetailLine(
              label: 'QR',
              value: report.qrScanned
                  ? 'Scanned'
                  : 'Not scanned',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QR REGISTRY
// ============================================================

