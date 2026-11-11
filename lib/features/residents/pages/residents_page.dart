part of pawlink_admin;

class ResidentsPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const ResidentsPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<ResidentsPage> createState() =>
      _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  @override
  Widget build(BuildContext context) {
    final residents = users
        .where((u) => u.userType == 'Resident')
        .toList();

    return AdminPage(
      title: 'Residents',
      subtitle:
          'Manage resident accounts and their registered pets.',
      child: Column(
        children: [
          const SearchField(
            hint:
                'Search resident name, email or address...',
          ),
          const SizedBox(height: 20),
          for (final user in residents)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: ResidentCard(
                user: user,
                onChanged: () {
                  setState(() {});
                  widget.onRefresh();
                },
              ),
            ),
        ],
      ),
    );
  }
}

