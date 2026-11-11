part of pawlink_admin;

class PetRegistryPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const PetRegistryPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<PetRegistryPage> createState() =>
      _PetRegistryPageState();
}

class _PetRegistryPageState
    extends State<PetRegistryPage> {
  void refresh() {
    setState(() {});
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Pet Registry',
      subtitle:
          'Manage registered pets, QR profiles, vaccination and pet status.',
      action: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: forestGreen,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => RegisterPetDialog(
              onRegistered: refresh,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Register Pet'),
      ),
      child: Column(
        children: [
          const SearchField(
            hint:
                'Search pet, owner, QR ID, breed or animal type...',
          ),
          const SizedBox(height: 20),
          for (final pet in pets)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: PetCard(
                pet: pet,
                onChanged: refresh,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// REGISTER PET
// ============================================================

