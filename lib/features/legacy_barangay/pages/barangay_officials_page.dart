part of pawlink_admin;

class BarangayOfficialsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const BarangayOfficialsPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<BarangayOfficialsPage> createState() =>
      _BarangayOfficialsPageState();
}

class _BarangayOfficialsPageState
    extends State<BarangayOfficialsPage> {
  @override
  Widget build(BuildContext context) {
    final officials = users
        .where(
          (u) => u.userType == 'Barangay Official',
        )
        .toList();

    return AdminPage(
      title: 'Barangay Officials',
      subtitle:
          'Verified officials are normal PawLink users and do not have administrator access.',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: softBeige,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: forestGreen,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Barangay officials may register their own pets '
                    'and submit community reports like other users. '
                    'The verified label does not grant access to this Admin Portal.',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final official in officials)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(20),
                  leading: const CircleAvatar(
                    radius: 27,
                    backgroundColor: cream,
                    child: Icon(
                      Icons.account_balance_outlined,
                      color: forestGreen,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        official.name,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (official.verified)
                        const StatusChip(
                          text: 'VERIFIED',
                          type: ChipType.success,
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: 6),
                    child: Text(
                      '${official.email}\n'
                      '${official.contact} • ${official.address}',
                    ),
                  ),
                  isThreeLine: true,
                  trailing: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OfficialDetailsPage(
                            official: official,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Information',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

