part of pawlink_admin;

class BarangaySupportPage extends StatefulWidget {
  const BarangaySupportPage({super.key});

  @override
  State<BarangaySupportPage> createState() => _BarangaySupportPageState();
}

class _BarangaySupportPageState extends State<BarangaySupportPage> {
  String selectedSection = 'Stray Animals';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnimalReport>>(
      stream: adminDataProvider.reportsStream,
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];

        List<AnimalReport> getVisibleReports() {
          if (selectedSection == 'Stray Animals') {
            return reports.where((r) => r.type == 'Stray' || r.type == 'stray').toList();
          }
          if (selectedSection == 'Animal Concern') {
            return reports.where((r) =>
                r.type == 'Animal Concern' ||
                r.type == 'Found' ||
                r.type == 'found' ||
                r.type == 'Missing' ||
                r.type == 'lost').toList();
          }
          return reports;
        }

        void select(String section) {
          setState(() => selectedSection = section);
        }

        final visibleReports = getVisibleReports();

        return AdminPage(
          title: 'Barangay Support',
          subtitle:
              'A central place for community pet concerns, stray reports and reported locations.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [mutedGreen, forestGreen, deepForestGreen],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.account_balance_outlined,
                          color: Colors.white, size: 30),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barangay Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Review community reports and help coordinate pet and animal concerns.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'What can you report?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  BarangaySupportAction(
                    icon: Icons.pets_outlined,
                    title: 'Stray Animals',
                    subtitle: 'View reports of stray or roaming animals',
                    active: selectedSection == 'Stray Animals',
                    onTap: () => select('Stray Animals'),
                  ),
                  BarangaySupportAction(
                    icon: Icons.warning_amber_rounded,
                    title: 'Animal Concern',
                    subtitle: 'Review animal welfare and community pet concerns',
                    active: selectedSection == 'Animal Concern',
                    onTap: () => select('Animal Concern'),
                  ),
                  BarangaySupportAction(
                    icon: Icons.location_on_outlined,
                    title: 'Pet Found',
                    subtitle: 'Browse found pet reports',
                    active: selectedSection == 'Pet Found',
                    onTap: () => select('Pet Found'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (visibleReports.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: softBeige,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${visibleReports.length} report${visibleReports.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: forestGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (visibleReports.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 55),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 42, color: textMuted),
                      SizedBox(height: 12),
                      Text(
                        'No reports in this category yet.',
                        style: TextStyle(color: textMuted),
                      ),
                    ],
                  ),
                )
              else
                for (final report in visibleReports)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SmallReportCard(
                      report: report,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: pageBackground,
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: softBeige,
                                  child:
                                      Icon(iconFor(report), color: forestGreen),
                                ),
                                const SizedBox(width: 11),
                                const Expanded(
                                  child: Text('Report Details'),
                                ),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            content: SizedBox(
                              width: 520,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.type == 'Stray'
                                        ? 'Stray Animal Report'
                                        : 'Animal Concern Report',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    report.description,
                                    style: const TextStyle(
                                        fontSize: 13, height: 1.5),
                                  ),
                                  const SizedBox(height: 18),
                                  DetailLine(
                                    icon: Icons.location_on_outlined,
                                    label: 'Location',
                                    value: report.location,
                                  ),
                                  DetailLine(
                                    icon: Icons.schedule_outlined,
                                    label: 'Reported',
                                    value: report.date,
                                  ),
                                  DetailLine(
                                    icon: Icons.person_outline,
                                    label: 'Reported by',
                                    value: report.reporter,
                                  ),
                                  DetailLine(
                                    icon: Icons.verified_outlined,
                                    label: 'Status',
                                    value: report.status,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                label: const Text('Close'),
                              ),
                              if (report.status != 'Solved')
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: forestGreen,
                                  ),
                                  onPressed: () async {
                                    await adminDataProvider.reportService
                                        .updateReportStatus(
                                            report.id, 'Solved');

                                    adminDataProvider.activityService.logActivity(
                                      'Resolved barangay support report',
                                      report.id,
                                      currentAdminName,
                                    );

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(Icons.task_alt),
                                  label: const Text('Mark Solved'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  IconData iconFor(AnimalReport r) {
    final type = r.type.toLowerCase();
    if (type == 'stray') return Icons.pets_outlined;
    if (type == 'found') return Icons.location_on_outlined;
    if (type == 'missing' || type == 'lost') return Icons.search_rounded;
    return Icons.warning_amber_rounded;
  }
}