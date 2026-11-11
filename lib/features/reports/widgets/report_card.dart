part of pawlink_admin;

class ReportCard extends StatelessWidget {
  final AnimalReport report;
  final VoidCallback onChanged;

  const ReportCard({
    super.key,
    required this.report,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            PhotoPlaceholder(
              label: report.photoLabel,
              icon: petIcon(
                report.animalType,
              ),
              width: 130,
              height: 125,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      StatusChip(
                        text:
                            report.type.toUpperCase(),
                        type: report.type ==
                                'Missing'
                            ? ChipType.warning
                            : report.type ==
                                    'Found'
                                ? ChipType.mutedGreen
                                : ChipType.gray,
                      ),
                      StatusChip(
                        text: report.status
                            .toUpperCase(),
                        type: report.status ==
                                'Solved'
                            ? ChipType.success
                            : ChipType.warning,
                      ),
                      if (report.qrScanned)
                        const StatusChip(
                          text: 'QR SCANNED',
                          type: ChipType.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.petName == 'Unknown'
                        ? '${report.color} ${report.animalType}'
                        : '${report.petName} • ${report.breed}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    report.description,
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 25,
                    runSpacing: 10,
                    children: [
                      InfoBox(
                        label: 'BREED',
                        value: report.breed,
                      ),
                      InfoBox(
                        label: 'COLOR',
                        value: report.color,
                      ),
                      InfoBox(
                        label: 'SEX',
                        value: report.sex,
                      ),
                      InfoBox(
                        label: 'LOCATION',
                        value: report.location,
                        width: 190,
                      ),
                    ],
                  ),
                  const Divider(height: 26),
                  Text(
                    '${report.id} • Reported by ${report.reporter} • ${report.date}',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          ReportDetailsDialog(
                        report: report,
                      ),
                    );
                  },
                  child: const Text(
                    'View Report',
                  ),
                ),
                if (report.type == 'Found') ...[
                  const SizedBox(height: 7),
                  FilledButton(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          forestGreen,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            CompareReportDialog(
                          found: report,
                          onChanged:
                              onChanged,
                        ),
                      );
                    },
                    child: const Text(
                      'Compare',
                    ),
                  ),
                ],
                if (report.status != 'Solved') ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      report.status = 'Solved';

                      logActivity(
                        'Marked report as solved',
                        report.id,
                      );

                      onChanged();
                    },
                    child: const Text(
                      'Mark Solved',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMPARE REPORT
// ============================================================

