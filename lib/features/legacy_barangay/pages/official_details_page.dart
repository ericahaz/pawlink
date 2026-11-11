part of pawlink_admin;

class OfficialDetailsPage extends StatelessWidget {
  final PawUser official;

  const OfficialDetailsPage({
    super.key,
    required this.official,
  });

  @override
  Widget build(BuildContext context) {
    final officialReports = reports
        .where(
          (r) => r.reporter == official.name,
        )
        .toList();

    final officialPets =
        pets.where((p) => p.owner == official.name).toList();

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        title: Text(official.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: cream,
                    child: Icon(
                      Icons.account_balance_outlined,
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
                              official.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const StatusChip(
                              text:
                                  'VERIFIED BARANGAY OFFICIAL',
                              type:
                                  ChipType.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${official.email} • ${official.contact}',
                          style: const TextStyle(
                            color: textMuted,
                          ),
                        ),
                        Text(
                          'Area: ${official.address}',
                          style: const TextStyle(
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            'Registered Pets',
          ),
          const SizedBox(height: 10),
          if (officialPets.isEmpty)
            const EmptyCard(
              text:
                  'This official has no registered pets.',
            ),
          for (final pet in officialPets)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 10),
              child: SmallPetCard(pet: pet),
            ),
          const SizedBox(height: 24),
          const SectionTitle(
            'Reports Submitted',
          ),
          const SizedBox(height: 10),
          if (officialReports.isEmpty)
            const EmptyCard(
              text:
                  'This official has not submitted any reports.',
            ),
          for (final report in officialReports)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 10),
              child: SmallReportCard(
                report: report,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// PET REGISTRY
// ============================================================

