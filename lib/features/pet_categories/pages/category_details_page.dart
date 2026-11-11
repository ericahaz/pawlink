part of pawlink_admin;

class CategoryDetailsPage extends StatelessWidget {
  final String title;
  final String category;

  const CategoryDetailsPage({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final list = category == 'Other'
        ? pets.where((p) =>
            !['Dog', 'Cat', 'Bird', 'Rabbit'].contains(p.animalType)).toList()
        : pets.where((p) => p.animalType == category).toList();

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pageBackground,
        foregroundColor: textDark,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Close category',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 50),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: forestGreen,
                  child: Icon(
                    category == 'Bird'
                        ? Icons.flutter_dash_outlined
                        : category == 'Other'
                            ? Icons.interests_outlined
                            : Icons.pets,
                    color: lightCream,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '$title currently contains ${list.length} registered ${list.length == 1 ? 'pet' : 'pets'}. Select a pet below to review its PawLink record.',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 55),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
              ),
              child: const Column(
                children: [
                  Icon(Icons.pets_outlined, size: 42, color: textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No registered pets in this category yet.',
                    style: TextStyle(color: textMuted),
                  ),
                ],
              ),
            )
          else
            for (final pet in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SmallPetCard(pet: pet),
              ),
        ],
      ),
    );
  }
}

// ============================================================
// OWNERSHIP
// ============================================================

