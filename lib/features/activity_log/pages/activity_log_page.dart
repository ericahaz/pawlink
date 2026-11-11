part of pawlink_admin;

class ActivityLogPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const ActivityLogPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<ActivityLogPage> createState() =>
      _ActivityLogPageState();
}

class _ActivityLogPageState
    extends State<ActivityLogPage> {
  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Activity Log',
      subtitle:
          'Audit trail of administrator actions performed in PawLink.',
      child: Column(
        children: [
          const SearchField(
            hint:
                'Search administrator activity...',
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                for (int i = 0;
                    i < activities.length;
                    i++) ...[
                  ListTile(
                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading:
                        const CircleAvatar(
                      backgroundColor:
                          softBeige,
                      child: Icon(
                        Icons.history,
                        color: forestGreen,
                      ),
                    ),
                    title: Text(
                      activities[i].action,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      'Admin Sanchez\n${activities[i].target}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      formatTime(
                        activities[i].time,
                      ),
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (i <
                      activities.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN ACCOUNT
// ============================================================

