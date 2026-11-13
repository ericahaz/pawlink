import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/pet_service.dart';

class RegisterPetPage extends StatefulWidget {
  const RegisterPetPage({super.key});

  @override
  State<RegisterPetPage> createState() => _RegisterPetPageState();
}

class _RegisterPetPageState extends State<RegisterPetPage> {
  final PetService _petService = PetService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _otherBreedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _identifyingMarksController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerContactController = TextEditingController();

  // Maximum of four photos per pet.
  static const int _maxPhotos = 4;
  static const int _maxPhotoBytes = 5 * 1024 * 1024;

  final List<Uint8List> _photoBytes = [];

  String _sex = 'unknown';
  String? _selectedBreed;
  String _safetyTag = 'safe';

  bool _isSaving = false;

  // COLORS

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color borderColor = Color(0xFFE3E5E3);

  static const Color safeGreen = Color(0xFF16A34A);
  static const Color cautionYellow = Color(0xFFF59E0B);
  static const Color aggressiveRed = Color(0xFFDC2626);


  // Breed choices shown in the Breed dropdown.
  static const List<String> _catBreeds = [
    'Persian',
    'Siamese',
    'British Shorthair',
    'Maine Coon',
    'Ragdoll',
    'Bengal',
    'Scottish Fold',
    'American Shorthair',
    'Sphynx',
    'Russian Blue',
    'Exotic Shorthair',
    'Himalayan',
    'Abyssinian',
    'Domestic Shorthair (Puspin)',
    'Domestic Longhair',
  ];

  static const List<String> _dogBreeds = [
    'Shih Tzu',
    'Pomeranian',
    'Chihuahua',
    'Labrador Retriever',
    'Golden Retriever',
    'German Shepherd',
    'Beagle',
    'Poodle',
    'Dachshund',
    'Siberian Husky',
    'French Bulldog',
    'Rottweiler',
    'Yorkshire Terrier',
    'Aspin',
    'Corgi',
  ];

  static const List<String> _otherBreedChoices = [
    'Mixed Breed',
    'Unknown',
    'Other',
  ];

  static List<String> get _allBreedChoices => [
        ..._catBreeds,
        ..._dogBreeds,
        ..._otherBreedChoices,
      ];

  // Breed reference pictures are loaded from the app's local assets.
  // Add the matching JPG files under assets/images/breeds/.
  String _breedImageAsset(String breed) {
    final String fileName = breed
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return 'assets/images/breeds/$fileName.jpg';
  }

  // Tap a breed thumbnail to view its reference photo in a larger preview.
  void _showBreedImagePreview(String breed) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: warmBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        breed,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                      color: grayText,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    _breedImageAsset(breed),
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 280,
                      height: 280,
                      color: lightTeal,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.pets_rounded,
                        color: primaryTeal,
                        size: 64,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Breed reference photo',
                  style: TextStyle(color: grayText, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _breedThumbnail(String breed) {
    return GestureDetector(
      onTap: () => _showBreedImagePreview(breed),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          _breedImageAsset(breed),
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 38,
            height: 38,
            color: lightTeal,
            alignment: Alignment.center,
            child: const Icon(Icons.pets_rounded, color: primaryTeal, size: 21),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildBreedItems(List<String> breeds) {
    return breeds.map((breed) {
      return DropdownMenuItem<String>(
        value: breed,
        child: Row(
          children: [
            _breedThumbnail(breed),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                breed,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBreedDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBreed,
      isExpanded: true,
      menuMaxHeight: 420,
      decoration: _dropdownDecoration('Breed', Icons.category_outlined),
      items: [
        const DropdownMenuItem<String>(
          enabled: false,
          child: Text(
            'CAT BREEDS',
            style: TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
        ..._buildBreedItems(_catBreeds),
        const DropdownMenuItem<String>(
          enabled: false,
          child: Text(
            'DOG BREEDS',
            style: TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
        ..._buildBreedItems(_dogBreeds),
        const DropdownMenuItem<String>(
          enabled: false,
          child: Text(
            'OTHER OPTIONS',
            style: TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
        ..._buildBreedItems(_otherBreedChoices),
      ],
      onChanged: _isSaving
          ? null
          : (value) {
              if (value == null) return;
              setState(() {
                _selectedBreed = value;
                if (value != 'Other') {
                  _otherBreedController.clear();
                }
              });
            },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please choose a breed.';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _otherBreedController.dispose();
    _colorController.dispose();
    _ageController.dispose();
    _identifyingMarksController.dispose();
    _ownerNameController.dispose();
    _ownerContactController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK MULTIPLE PHOTOS
  // ============================================================

  Future<void> _pickImages() async {
    if (_isSaving) return;

    if (_photoBytes.length >= _maxPhotos) {
      _showMessage('You can select up to $_maxPhotos photos only.');
      return;
    }

    try {
      final List<XFile> pickedImages =
          await _imagePicker.pickMultiImage(imageQuality: 85);

      if (pickedImages.isEmpty) return;

      final int remainingSlots = _maxPhotos - _photoBytes.length;
      final List<XFile> imagesToRead =
          pickedImages.take(remainingSlots).toList();

      final List<Uint8List> newPhotos = [];
      final List<String> oversizedPhotos = [];

      for (final image in imagesToRead) {
        final Uint8List bytes = await image.readAsBytes();

        if (bytes.lengthInBytes > _maxPhotoBytes) {
          oversizedPhotos.add(image.name);
          continue;
        }

        newPhotos.add(bytes);
      }

      if (!mounted) return;

      setState(() {
        _photoBytes.addAll(newPhotos);
      });

      if (oversizedPhotos.isNotEmpty) {
        _showMessage(
          '${oversizedPhotos.length} photo(s) were skipped because '
          'each photo must be 5 MB or smaller.',
        );
      }

      if (pickedImages.length > remainingSlots) {
        _showMessage(
          'Only $_maxPhotos photos can be selected. '
          'The extra selections were ignored.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to select photos: $e');
    }
  }

  void _removePhoto(int index) {
    if (_isSaving) return;

    setState(() {
      _photoBytes.removeAt(index);
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // REGISTER PET
  // ============================================================

  Future<void> _registerPet() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    // Validate photo sizes before creating any Firebase documents.
    for (int i = 0; i < _photoBytes.length; i++) {
      if (_photoBytes[i].lengthInBytes > _maxPhotoBytes) {
        _showMessage('Photo ${i + 1} exceeds the 5 MB limit.');
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final String breedToSave = _selectedBreed == 'Other'
        ? _otherBreedController.text.trim()
        : (_selectedBreed ?? '').trim();

    String? createdPetId;

    try {
      // 1. Create the pet document.
      createdPetId = await _petService.createPet(
        petName: _petNameController.text.trim(),
        breed: breedToSave,
        color: _colorController.text.trim(),
        age: _ageController.text.trim(),
        sex: _sex,
        identifyingMarks: _identifyingMarksController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        ownerContact: _ownerContactController.text.trim(),
        safetyTag: _safetyTag,
      );

      // 2. Upload the primary photo and any additional photos.
      if (_photoBytes.isNotEmpty) {
        final List<String> photoUrls = [];

        // The first photo is the primary photo.
        final String primaryPhotoUrl = await _petService.uploadPetPhotoBytes(
          petId: createdPetId,
          bytes: _photoBytes[0],
        );

        photoUrls.add(primaryPhotoUrl);

        // Additional photos use slots 1, 2, and 3.
        for (int i = 1; i < _photoBytes.length; i++) {
          final String additionalPhotoUrl =
              await _petService.uploadAdditionalPetPhotoBytes(
            petId: createdPetId,
            slot: i,
            bytes: _photoBytes[i],
          );

          photoUrls.add(additionalPhotoUrl);
        }

        // 3. Save the complete ordered gallery to both pet profiles.
        await _petService.updatePet(
          petId: createdPetId,
          petName: _petNameController.text.trim(),
          breed: breedToSave,
          color: _colorController.text.trim(),
          age: _ageController.text.trim(),
          sex: _sex,
          identifyingMarks: _identifyingMarksController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          ownerContact: _ownerContactController.text.trim(),
          photoUrl: photoUrls.first,
          photoUrls: photoUrls,
          safetyTag: _safetyTag,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet registered successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      // Clean up a partially created pet if registration fails.
      if (createdPetId != null) {
        try {
          await _petService.deletePet(createdPetId);
        } catch (_) {
          // Preserve the original registration error.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to register pet: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      appBar: AppBar(
        backgroundColor: warmBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: darkText),
        ),
        title: const Text(
          'Register a Pet',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 800;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 40 : 16,
              20,
              isDesktop ? 40 : 16,
              40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntro(),
                      const SizedBox(height: 20),
                      _buildPhotoSection(),
                      const SizedBox(height: 18),
                      _buildPetInformation(),
                      const SizedBox(height: 18),
                      _buildSafetySection(),
                      const SizedBox(height: 18),
                      _buildOwnerInformation(),
                      const SizedBox(height: 18),
                      _buildQrInformation(),
                      const SizedBox(height: 24),
                      _buildRegisterButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a pet profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: darkText,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Register your pet so its information can be connected '
          'to a unique QR profile.',
          style: TextStyle(
            color: grayText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PHOTO SECTION
  // ============================================================

  Widget _buildPhotoSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.photo_camera_outlined,
            title: 'Pet Photos',
          ),
          const SizedBox(height: 8),
          const Text(
            'Select up to 4 clear photos of your pet. '
            'The first photo will be the main profile picture. '
            'Each photo must be 5 MB or smaller.',
            style: TextStyle(
              color: grayText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (_photoBytes.isEmpty)
            _buildEmptyPhotoPlaceholder()
          else
            _buildPhotoGalleryPreview(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving || _photoBytes.length >= _maxPhotos
                  ? null
                  : _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
              label: Text(
                _photoBytes.isEmpty
                    ? 'Choose Photos'
                    : _photoBytes.length >= _maxPhotos
                        ? 'Maximum 4 Photos Selected'
                        : 'Add More Photos (${_photoBytes.length}/$_maxPhotos)',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryTeal,
                disabledForegroundColor: grayText,
                side: const BorderSide(color: primaryTeal),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            color: primaryTeal,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No photos selected',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add photos to help identify your pet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: grayText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGalleryPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photoBytes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 118,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          _photoBytes[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Primary photo label.
                    if (index == 0)
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: primaryTeal,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Main Photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                    // Remove photo button.
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _isSaving ? null : () => _removePhoto(index),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${_photoBytes.length} of $_maxPhotos photos selected',
          style: const TextStyle(
            color: grayText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PET INFORMATION
  // ============================================================

  Widget _buildPetInformation() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.pets_rounded,
            title: 'Pet Information',
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _petNameController,
            label: 'Pet Name',
            hint: 'Example: Max',
            icon: Icons.pets_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the pet name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildBreedDropdown(),
          if (_selectedBreed == 'Other') ...[
            const SizedBox(height: 14),
            _buildTextField(
              controller: _otherBreedController,
              label: 'Enter Other Breed',
              hint: 'Type your pet breed',
              icon: Icons.edit_outlined,
              validator: (value) {
                if (_selectedBreed == 'Other' &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Please enter your pet breed.';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 14),
          _buildTextField(
            controller: _colorController,
            label: 'Color',
            hint: 'Example: Brown and white',
            icon: Icons.palette_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the color.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            hint: 'Example: 3 years old',
            icon: Icons.cake_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the age.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _sex,
            decoration: _dropdownDecoration('Sex', Icons.pets_rounded),
            items: const [
              DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _sex = value);
                  },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _identifyingMarksController,
            label: 'Identifying Marks',
            hint: 'Example: White spot on left paw or a unique marking',
            icon: Icons.fingerprint_rounded,
            validator: (_) => null,
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryTeal, size: 21),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: grayText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
    );
  }

  // ============================================================
  // SAFETY SECTION
  // ============================================================

  Widget _buildSafetySection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.shield_outlined,
            title: 'Safety Level',
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a safety tag that can help people know how '
            'to respond if they encounter your pet.',
            style: TextStyle(
              color: grayText,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _buildSafetyOption(
            value: 'safe',
            icon: Icons.check_circle_rounded,
            title: 'Safe',
            description: 'Normal behavior. No special warning.',
            color: safeGreen,
          ),
          const SizedBox(height: 10),
          _buildSafetyOption(
            value: 'caution',
            icon: Icons.warning_amber_rounded,
            title: 'Caution',
            description: 'Pet may be frightened, nervous, or defensive.',
            color: cautionYellow,
          ),
          const SizedBox(height: 10),
          _buildSafetyOption(
            value: 'aggressive',
            icon: Icons.do_not_touch_rounded,
            title: 'Aggressive / Do Not Approach',
            description:
                'Do not approach. Notify the barangay if assistance is needed.',
            color: aggressiveRed,
          ),
          const SizedBox(height: 14),
          if (_safetyTag == 'aggressive')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: aggressiveRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: aggressiveRed,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'The red tag is a safety warning. It does not '
                      'disable the QR code. People should avoid approaching '
                      'the pet and use the report feature when necessary.',
                      style: TextStyle(
                        color: aggressiveRed,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSafetyOption({
    required String value,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final bool selected = _safetyTag == value;

    return InkWell(
      onTap: _isSaving ? null : () => setState(() => _safetyTag = value),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? color : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? color : darkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: grayText,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _safetyTag,
              onChanged: _isSaving
                  ? null
                  : (newValue) {
                      if (newValue == null) return;
                      setState(() => _safetyTag = newValue);
                    },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OWNER INFORMATION
  // ============================================================

  Widget _buildOwnerInformation() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'Owner Information',
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _ownerNameController,
            label: 'Owner Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the owner name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _ownerContactController,
            label: 'Contact Number',
            hint: 'Example: 09123456789',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a contact number.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QR INFORMATION
  // ============================================================

  Widget _buildQrInformation() {
    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: primaryTeal,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pet QR Profile',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'A unique QR code will automatically be created '
                  'for this pet. If the pet has multiple owners, '
                  'all owners will use the same QR code.',
                  style: TextStyle(
                    color: grayText,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REGISTER BUTTON
  // ============================================================

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _registerPet,
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_circle_outline_rounded),
        label: Text(
          _isSaving ? 'Registering Pet...' : 'Create Pet Profile',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryTeal.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryTeal, size: 21),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: grayText),
        hintStyle: const TextStyle(
          color: Color(0xFF9A9F9F),
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: primaryTeal,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: aggressiveRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: aggressiveRed,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryTeal, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
