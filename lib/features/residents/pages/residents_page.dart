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
    return MultiStreamBuilder(
      streams: [
        adminDataProvider.userService.getResidentsStream(),
        adminDataProvider.petService.getPetsStream(),
      ],
      builder: (context, snapshots) {
        final residents = snapshots[0] as List<PawUser>? ?? [];
        final allPets = snapshots[1] as List<PetRecord>? ?? [];

        final residentsWaiting = residents.isEmpty;
        final petsWaiting = allPets.isEmpty;

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
              if (residentsWaiting || petsWaiting)
                const Center(child: CircularProgressIndicator())
              else
                for (final user in residents)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),
                    child: ResidentCard(
                      user: user,
                      allPets: allPets,
                      onChanged: () {
                        setState(() {});
                        widget.onRefresh();
                      },
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}