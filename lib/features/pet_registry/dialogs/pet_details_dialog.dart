part of pawlink_admin;

class AdminPetRegistration extends StatefulWidget {
  const AdminPetRegistration({super.key});

  @override
  _AdminPetRegistrationState createState() => _AdminPetRegistrationState();
}

class _AdminPetRegistrationState extends State<AdminPetRegistration> {
  final TextEditingController petNameController = TextEditingController();
  String petCategory = 'Dog'; // Only "Dog" or "Cat"
  String breed = '';
  String color = '';
  String age = '';
  String gender = 'Male';
  Set<String> petBehavior = {};

  // Defined here to avoid re-creation every build, optional for performance
  static const Map<String, Color> behaviorColorsConst = {
    'Friendly': Colors.green,
    'Caution': Colors.orangeAccent,
    'Aggressive': Colors.redAccent,
  };
  Map<String, Color> get behaviorColors => behaviorColorsConst;

  void toggleBehavior(String behavior) {
    setState(() {
      if (petBehavior.contains(behavior)) {
        petBehavior.remove(behavior);
      } else {
        petBehavior.add(behavior);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pet Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Row(
            children: ['Dog', 'Cat'].map((category) {
              final selected = petCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  selectedColor: Colors.green.shade200,
                  onSelected: (bool selected) {
                    if (selected) setState(() => petCategory = category);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Breed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade400, width: 1.5),
            ),
            child: TextField(
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter breed'),
              onChanged: (val) => setState(() => breed = val),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.brown.shade300, width: 1.5),
            ),
            child: TextField(
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter color'),
              onChanged: (val) => setState(() => color = val),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Age', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.shade300, width: 1.5),
            ),
            child: TextField(
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter age (e.g., 2 years)'),
              onChanged: (val) => setState(() => age = val),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Row(
            children: ['Male', 'Female'].map((g) {
              final selected = gender == g;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ChoiceChip(
                  label: Text(g),
                  selected: selected,
                  selectedColor: selected ? Colors.pink.shade200 : Colors.grey.shade300,
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (sel) {
                    if (sel) setState(() => gender = g);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Pet Behavior', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: behaviorColors.entries.map((entry) {
              final isSelected = petBehavior.contains(entry.key);
              return FilterChip(
                label: Text(entry.key),
                selected: isSelected,
                selectedColor: entry.value.withOpacity(0.3),
                backgroundColor: Colors.grey.shade200,
                checkmarkColor: entry.value,
                onSelected: (_) => toggleBehavior(entry.key),
                labelStyle: TextStyle(
                  color: isSelected ? entry.value : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
