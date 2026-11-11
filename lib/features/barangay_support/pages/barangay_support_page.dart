part of pawlink_admin;

class BarangaySupportPage extends StatefulWidget {
  const BarangaySupportPage({super.key});

  @override
  State<BarangaySupportPage> createState() => _BarangaySupportPageState();
}

class _BarangaySupportPageState extends State<BarangaySupportPage> {
  String selectedSection = 'Stray Animals';

  List<AnimalReport> get visibleReports {
    if (selectedSection == 'Stray Animals') {
      return reports.where((r) => r.type == 'Stray').toList();
    }
    if (selectedSection == 'Animal Concern') {
      return reports.where((r) =>
          r.type == 'Animal Concern' ||
          r.type == 'Found' ||
          r.type == 'Missing').toList();
    }
    return reports;
  }

  void select(String section) {
    setState(() => selectedSection = section);
  }

  @override
  Widget build(BuildContext context) {
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
                title: 'Location',
                subtitle: 'See the reported locations and landmarks',
                active: selectedSection == 'Location',
                onTap: () => select('Location'),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Icon(
                selectedSection == 'Location'
                    ? Icons.location_on_outlined
                    : selectedSection == 'Stray Animals'
                        ? Icons.pets_outlined
                        : Icons.warning_amber_rounded,
                color: forestGreen,
              ),
              const SizedBox(width: 8),
              Text(
                selectedSection,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (visibleReports.isEmpty)
            const AppCard(
              child: Padding(
                padding: EdgeInsets.all(26),
                child: Row(
                  children: [
                    Icon(Icons.inbox_outlined, color: textMuted),
                    SizedBox(width: 12),
                    Text(
                      'No reports are available in this section yet.',
                      style: TextStyle(color: textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final report in visibleReports)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: softBeige,
                          child: Icon(
                            selectedSection == 'Location'
                                ? Icons.location_on_outlined
                                : report.type == 'Stray'
                                    ? Icons.pets_outlined
                                    : Icons.warning_amber_rounded,
                            color: forestGreen,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${report.type} • ${report.petName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedSection == 'Location'
                                    ? report.location
                                    : '${report.location} • ${report.reporter}',
                                style: const TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              if (report.description.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  report.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                        StatusChip(
                          text: report.status,
                          type: report.status == 'Solved'
                              ? ChipType.success
                              : ChipType.warning,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'View report information',
                          icon: const Icon(Icons.visibility_outlined),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('${report.id} — ${report.type}'),
                                content: SizedBox(
                                  width: 520,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DetailLine(label: 'Animal', value: report.petName),
                                      DetailLine(label: 'Type', value: report.animalType),
                                      DetailLine(label: 'Breed', value: report.breed),
                                      DetailLine(label: 'Color', value: report.color),
                                      DetailLine(label: 'Reporter', value: report.reporter),
                                      DetailLine(label: 'Location', value: report.location),
                                      DetailLine(label: 'Date', value: report.date),
                                      DetailLine(label: 'Status', value: report.status),
                                      DetailLine(
                                        label: 'Description',
                                        value: report.description.isEmpty
                                            ? 'No description'
                                            : report.description,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  if (report.status != 'Solved')
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: forestGreen,
                                      ),
                                      onPressed: () {
                                        setState(() => report.status = 'Solved');
                                        logActivity(
                                          'Resolved barangay support report',
                                          report.id,
                                        );
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.task_alt),
                                      label: const Text('Mark Solved'),
                                    ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
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

