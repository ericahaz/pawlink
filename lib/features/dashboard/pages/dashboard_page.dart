part of pawlink_admin;

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardPage({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final residents =
        users.where((u) => u.userType == 'Resident').length;

    final pending =
        reports.where((r) => r.status == 'Pending').length;

    return AdminPage(
      title: 'Dashboard',
      subtitle: 'An overview of PawLink records and community reports.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner with teal gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [forestGreen, mutedGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1821685D),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha(40),
                          ),
                        ),
                        child: const Text(
                          'PAWLINK ADMIN PORTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'A connected community.\nA safer place for pets.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Keep pet records organized, coordinate community reports, and help pets find their way home.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.of(context).size.width > 900)
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Statistics cards in a grid
          const Text(
            'Key metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              DashboardStatCard(
                icon: Icons.people_outline,
                title: 'Residents',
                value: '$residents',
              ),
              DashboardStatCard(
                icon: Icons.pets_outlined,
                title: 'Registered Pets',
                value: '${pets.length}',
              ),
              DashboardStatCard(
                icon: Icons.qr_code_2,
                title: 'QR Profiles',
                value: '${pets.length}',
              ),
              DashboardStatCard(
                icon: Icons.description_outlined,
                title: 'Pending Reports',
                value: '$pending',
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Quick action cards
          const Text(
            'What would you like to do?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Quick access to your most important PawLink admin tools.',
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.pets_outlined,
                  title: 'Pet Registry',
                  subtitle: 'Open pet records and registration tools.',
                  onTap: () => onNavigate(3),
                ),
              ),
              Expanded(
                child: _ActionCard(
                  icon: Icons.description_outlined,
                  title: 'Community Reports',
                  subtitle: 'Review missing, found and stray reports.',
                  onTap: () => onNavigate(6),
                ),
              ),
              Expanded(
                child: _ActionCard(
                  icon: Icons.people_outline,
                  title: 'Residents',
                  subtitle: 'Review resident accounts and their pets.',
                  onTap: () => onNavigate(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Recent reports section
          const Text(
            'Recent reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (reports.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: softBeige,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.inbox_outlined,
                    color: forestGreen,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No reports yet',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Community reports will appear here when submitted.',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            for (final report in reports.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SmallReportCard(report: report),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onNavigate(6),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View all reports'),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: softBeige,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: softBeige,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: forestGreen, size: 20),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: forestGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}