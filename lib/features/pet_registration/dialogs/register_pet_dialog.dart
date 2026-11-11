part of pawlink_admin;

class RegisterPetDialog extends StatefulWidget {
  final VoidCallback onRegistered;

  const RegisterPetDialog({
    super.key,
    required this.onRegistered,
  });

  @override
  State<RegisterPetDialog> createState() =>
      _RegisterPetDialogState();
}

class _RegisterPetDialogState
    extends State<RegisterPetDialog> {
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final colorController = TextEditingController();
  final marksController = TextEditingController();
  final otherTypeController = TextEditingController();

  String animalType = 'Dog';
  String sex = 'Male';
  String selectedAge = '1 year';
  String selectedBreed = 'Aspin';
  String safetyLevel = 'Safe';
  String? owner;
  bool vaccinated = false;

  final animalTypes = [
    'Dog',
    'Cat',
    'Bird',
    'Rabbit',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final availableOwners = users.map((u) => u.name).toList();

    owner ??=
        availableOwners.isEmpty ? null : availableOwners.first;

    return AlertDialog(
      backgroundColor: pageBackground,
      title: const Text('Register New Pet'),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const FormLabel('Pet Type'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in animalTypes)
                    ChoiceChip(
                      selected: animalType == type,
                      selectedColor: softBeige,
                      label: Text(type),
                      onSelected: (_) {
                        setState(() {
                          animalType = type;
                          selectedBreed = breedsFor(type).first;
                          breedController.clear();
                        });
                      },
                    ),
                ],
              ),
              if (animalType == 'Other') ...[
                const SizedBox(height: 15),
                const FormLabel(
                  'Specify Animal Type',
                ),
                TextField(
                  controller: otherTypeController,
                  decoration: const InputDecoration(
                    hintText:
                        'Example: Turtle, Hamster, Fish',
                  ),
                ),
              ],
              const SizedBox(height: 17),
              const FormLabel('Pet Name'),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Pet name',
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const FormLabel('Breed'),
                        DropdownButtonFormField<String>(
                          value: breedsFor(animalType).contains(selectedBreed)
                              ? selectedBreed
                              : breedsFor(animalType).first,
                          isExpanded: true,
                          items: [
                            for (final breed in breedsFor(animalType))
                              DropdownMenuItem(
                                value: breed,
                                child: Text(breed),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedBreed = value;
                                if (value != 'Other / Specify breed') {
                                  breedController.clear();
                                }
                              });
                            }
                          },
                        ),
                        if (selectedBreed == 'Other / Specify breed') ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: breedController,
                            decoration: const InputDecoration(
                              hintText: 'Enter the specific breed',
                              prefixIcon: Icon(Icons.edit_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const FormLabel('Color'),
                        TextField(
                          controller: colorController,
                          decoration:
                              const InputDecoration(
                            hintText: 'Pet color',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const FormLabel('Sex'),
                        DropdownButtonFormField<String>(
                          initialValue: sex,
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Unknown',
                              child: Text('Unknown'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              sex = value;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const FormLabel('Age'),
                        DropdownButtonFormField<String>(
                          value: selectedAge,
                          isExpanded: true,
                          items: [
                            for (final age in petAgeOptions)
                              DropdownMenuItem(
                                value: age,
                                child: Text(age),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedAge = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const FormLabel('Pet Safety / Behavior'),
              const Text(
                'This warning will be visible on the pet QR profile so a finder knows whether it is safe to approach.',
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.verified_user_outlined, size: 18),
                    label: const Text('Safe'),
                    selected: safetyLevel == 'Safe',
                    selectedColor: successBg,
                    onSelected: (_) => setState(() => safetyLevel = 'Safe'),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: const Text('Caution'),
                    selected: safetyLevel == 'Caution',
                    selectedColor: warningBg,
                    onSelected: (_) => setState(() => safetyLevel = 'Caution'),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.dangerous_outlined, size: 18),
                    label: const Text('Aggressive / Do Not Approach'),
                    selected: safetyLevel == 'Aggressive / Do Not Approach',
                    selectedColor: dangerBg,
                    onSelected: (_) => setState(
                      () => safetyLevel = 'Aggressive / Do Not Approach',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const FormLabel('Primary Owner'),
              DropdownButtonFormField<String>(
                initialValue: owner,
                items: [
                  for (final user in users)
                    DropdownMenuItem(
                      value: user.name,
                      child: Text(
                        '${user.name} • ${user.userType}',
                      ),
                    ),
                ],
                onChanged: (value) {
                  owner = value;
                },
              ),
              const SizedBox(height: 15),
              const FormLabel(
                'Identifying Marks',
              ),
              TextField(
                controller: marksController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText:
                      'Describe any unique marks',
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: forestGreen,
                title: const Text(
                  'Vaccinated',
                ),
                subtitle: const Text(
                  'Mark if vaccination information is available.',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
                value: vaccinated,
                onChanged: (value) {
                  setState(() {
                    vaccinated = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: lightCream,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      color: forestGreen,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A unique PawLink QR code will automatically '
                        'be generated after the pet is registered.',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: forestGreen,
          ),
          onPressed: () {
            if (nameController.text.trim().isEmpty ||
                owner == null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter the pet name and owner.',
                  ),
                ),
              );
              return;
            }

            final realType = animalType == 'Other'
                ? (otherTypeController.text.trim().isEmpty
                    ? 'Other'
                    : otherTypeController.text.trim())
                : animalType;

            final pet = PetRecord(
              id: generatePetId(),
              name: nameController.text.trim(),
              category: ['Dog', 'Cat', 'Bird', 'Rabbit'].contains(animalType)
                  ? animalType
                  : 'Other',
              animalType: realType,
              breed: selectedBreed == 'Other / Specify breed'
                  ? (breedController.text.trim().isEmpty
                      ? 'Other'
                      : breedController.text.trim())
                  : selectedBreed,
              color:
                  colorController.text.trim().isEmpty
                      ? 'Unknown'
                      : colorController.text.trim(),
              sex: sex,
              age: selectedAge,
              owner: owner!,
              coOwners: [],
              vaccinated: vaccinated,
              vaccinationDate:
                  vaccinated ? 'Recorded' : 'N/A',
              nextVaccination:
                  vaccinated ? 'To be updated' : 'N/A',
              deceased: false,
              status: 'Active',
              marks:
                  marksController.text.trim().isEmpty
                      ? 'None recorded'
                      : marksController.text.trim(),
              qrId: generateQrId(),
              photoLabel:
                  '${nameController.text.trim().toUpperCase()} PHOTO',
              safetyLevel: safetyLevel,
            );

            pets.add(pet);

            logActivity(
              'Registered new pet',
              '${pet.id} • ${pet.name}',
            );

            widget.onRegistered();

            Navigator.pop(context);

            showDialog(
              context: context,
              builder: (_) =>
                  RegistrationSuccessDialog(
                pet: pet,
              ),
            );
          },
          icon: const Icon(Icons.pets),
          label: const Text(
            'Register & Generate QR',
          ),
        ),
      ],
    );
  }
}

