part of pawlink_admin;

class PetCategoriesPage extends StatefulWidget {
  final VoidCallback onRefresh;

  const PetCategoriesPage({
    super.key,
    required this.onRefresh,
  });

  @override
  State<PetCategoriesPage> createState() => _PetCategoriesPageState();
}

class _PetCategoriesPageState extends State<PetCategoriesPage> {
  int countFor(String type) {
    if (type == 'Other') {
      return pets.where((p) =>
          !['Dog', 'Cat', 'Bird', 'Rabbit'].contains(p.animalType)).length;
    }
    return pets.where((p) => p.animalType == type).length;
  }

  @override
  Widget build(BuildContext context) {
    final total = pets.length;
    final active = pets.where((p) => !p.deceased).length;

    return AdminPage(
      title: 'Pet Categories',
      subtitle:
          'Explore registered pets by animal type. Select a category to view its complete records.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 30),
            decoration: BoxDecoration(
              color: forestGreen,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 15,
                  offset: Offset(6, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: lightCream,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    color: forestGreen,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registered Pet Collection',
                        style: TextStyle(
                          color: lightCream,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Organized categories make it easier to browse pet records without crowding the registry.',
                        style: TextStyle(
                          color: Color(0xFFF1E5D1),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                _CategorySummary(value: '$total', label: 'TOTAL PETS'),
                const SizedBox(width: 28),
                _CategorySummary(value: '$active', label: 'ACTIVE'),
              ],
            ),
          ),
          const SizedBox(height: 34),
          const Row(
            children: [
              Icon(Icons.grid_view_rounded, color: forestGreen),
              SizedBox(width: 9),
              Text(
                'Browse by category',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a category below to open its registered pets.',
            style: TextStyle(color: textMuted, fontSize: 11),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cardWidth = width >= 1050
                  ? (width - 48) / 3
                  : width >= 700
                      ? (width - 24) / 2
                      : width;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  CategoryCard(
                    width: cardWidth,
                    title: 'Dogs',
                    category: 'Dog',
                    count: countFor('Dog'),
                    icon: Icons.pets,
                    description:
                        'View dog profiles, breeds, owners, QR records and safety information.',
                  ),
                  CategoryCard(
                    width: cardWidth,
                    title: 'Cats',
                    category: 'Cat',
                    count: countFor('Cat'),
                    icon: Icons.cruelty_free_outlined,
                    description:
                        'Browse registered cats and their identification and ownership details.',
                  ),
                  CategoryCard(
                    width: cardWidth,
                    title: 'Birds',
                    category: 'Bird',
                    count: countFor('Bird'),
                    icon: Icons.flutter_dash_outlined,
                    description:
                        'See registered birds together with breed and pet profile information.',
                  ),
                  CategoryCard(
                    width: cardWidth,
                    title: 'Rabbits',
                    category: 'Rabbit',
                    count: countFor('Rabbit'),
                    icon: Icons.cruelty_free,
                    description:
                        'Open rabbit records and review their complete PawLink information.',
                  ),
                  CategoryCard(
                    width: cardWidth,
                    title: 'Other Pets',
                    category: 'Other',
                    count: countFor('Other'),
                    icon: Icons.interests_outlined,
                    description:
                        'For turtles, hamsters, fish and other registered animal types.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 38),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: forestGreen,
                  child: Icon(Icons.info_outline, color: lightCream),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Pet categories are based on the animal type saved in each pet profile. Newly registered pets are automatically placed in the correct category.',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

