part of pawlink_admin;

class ReportDetailsDialog
    extends StatelessWidget {
  final AnimalReport report;

  const ReportDetailsDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: pageBackground,
      title: Text(
        '${report.type} Report',
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            children: [
              PhotoPlaceholder(
                label: report.photoLabel,
                icon: petIcon(
                  report.animalType,
                ),
                width: double.infinity,
                height: 200,
              ),
              const SizedBox(height: 18),
              DetailLine(
                label: 'Report ID',
                value: report.id,
              ),
              DetailLine(
                label: 'Type',
                value: report.type,
              ),
              DetailLine(
                label: 'Pet',
                value: report.petName,
              ),
              DetailLine(
                label: 'Animal',
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
                label: 'Reporter',
                value: report.reporter,
              ),
              DetailLine(
                label: 'Location',
                value: report.location,
              ),
              DetailLine(
                label: 'Date',
                value: report.date,
              ),
              DetailLine(
                label: 'Status',
                value: report.status,
              ),
              DetailLine(
                label: 'QR Scanned',
                value: report.qrScanned
                    ? 'Yes'
                    : 'No',
              ),
              const SizedBox(height: 10),
              Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  report.description,
                  style: const TextStyle(
                    color: textMuted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}



// ============================================================
// BARANGAY SUPPORT
// ============================================================

