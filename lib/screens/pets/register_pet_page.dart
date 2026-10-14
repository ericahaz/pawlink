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
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _identifyingMarksController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerContactController = TextEditingController();

  Uint8List? _imageBytes;

  String _sex = 'unknown';
  String _safetyTag = 'safe';

  bool _isSaving = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color borderColor = Color(0xFFE3E5E3);

  static const Color safeGreen = Color(0xFF16A34A);
  static const Color cautionYellow = Color(0xFFF59E0B);
  static const Color aggressiveRed = Color(0xFFDC2626);

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _ageController.dispose();
    _identifyingMarksController.dispose();
    _ownerNameController.dispose();
    _ownerContactController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage == null) {
        return;
      }

      final Uint8List bytes = await pickedImage.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select image: $e')),
      );
    }
  }

  // ============================================================
  // REGISTER PET
  // ============================================================

  Future<void> _registerPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? createdPetId;

    try {
      // --------------------------------------------------------
      // 1. CREATE PET DOCUMENT
      // --------------------------------------------------------

      createdPetId = await _petService.createPet(
        petName: _petNameController.text,
        breed: _breedController.text,
        color: _colorController.text,
        age: _ageController.text,
        sex: _sex,
        identifyingMarks: _identifyingMarksController.text,
        ownerName: _ownerNameController.text,
        ownerContact: _ownerContactController.text,
        safetyTag: _safetyTag,
      );

      // --------------------------------------------------------
      // 2. UPLOAD PHOTO
      // --------------------------------------------------------

      if (_imageBytes != null) {
        final String photoUrl = await _petService.uploadPetPhotoBytes(
          petId: createdPetId,
          bytes: _imageBytes!,
        );

        // ------------------------------------------------------
        // 3. SAVE PHOTO URL
        // ------------------------------------------------------

        await _petService.updatePet(
          petId: createdPetId,
          petName: _petNameController.text,
          breed: _breedController.text,
          color: _colorController.text,
          age: _ageController.text,
          sex: _sex,
          identifyingMarks: _identifyingMarksController.text,
          ownerName: _ownerNameController.text,
          ownerContact: _ownerContactController.text,
          photoUrl: photoUrl,
          safetyTag: _safetyTag,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet registered successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      // --------------------------------------------------------
      // CLEAN UP PARTIALLY CREATED PET
      // --------------------------------------------------------

      if (createdPetId != null) {
        try {
          await _petService.deletePet(createdPetId);
        } catch (_) {
          // Ignore cleanup error.
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: darkText),
        ),
        title: const Text(
          'Register a Pet',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create a pet profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Register your pet so its information can be connected '
          'to a unique QR profile.',
          style: TextStyle(color: grayText, fontSize: 14, height: 1.5),
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
            title: 'Pet Photo',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildImagePreview(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add a clear photo',
                      style: TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'A clear photo helps the community identify '
                      'your pet if it becomes lost.',
                      style: TextStyle(
                        color: grayText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _pickImage,
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: Text(
                        _imageBytes == null ? 'Choose Photo' : 'Change Photo',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryTeal,
                        side: const BorderSide(color: primaryTeal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview() {
    if (_imageBytes == null) {
      return Container(
        width: 105,
        height: 105,
        decoration: BoxDecoration(
          color: lightTeal,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: const Icon(
          Icons.pets_rounded,
          color: primaryTeal,
          size: 40,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.memory(
        _imageBytes!,
        width: 105,
        height: 105,
        fit: BoxFit.cover,
      ),
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

          _buildTextField(
            controller: _breedController,
            label: 'Breed',
            hint: 'Example: Aspin, Puspin, Shih Tzu',
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the breed.';
              }
              return null;
            },
          ),

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

          // SEX
          DropdownButtonFormField<String>(
            value: _sex,
            decoration: InputDecoration(
              labelText: 'Sex',
              prefixIcon: const Icon(
                Icons.pets_rounded,
                color: primaryTeal,
                size: 21,
              ),
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
                borderSide: const BorderSide(
                  color: primaryTeal,
                  width: 1.5,
                ),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'unknown',
                child: Text('Unknown'),
              ),
              DropdownMenuItem(
                value: 'male',
                child: Text('Male'),
              ),
              DropdownMenuItem(
                value: 'female',
                child: Text('Female'),
              ),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _sex = value;
                    });
                  },
          ),

          const SizedBox(height: 14),

          // IDENTIFYING MARKS
          _buildTextField(
            controller: _identifyingMarksController,
            label: 'Identifying Marks',
            hint: 'Example: White spot on left paw or a unique marking',
            icon: Icons.fingerprint_rounded,
            validator: (value) => null,
          ),
        ],
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

  // ============================================================
  // SAFETY OPTION
  // ============================================================

  Widget _buildSafetyOption({
    required String value,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final bool selected = _safetyTag == value;

    return InkWell(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _safetyTag = value;
              });
            },
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

                      setState(() {
                        _safetyTag = newValue;
                      });
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
        prefixIcon: Icon(
          icon,
          color: primaryTeal,
          size: 21,
        ),
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
          child: Icon(
            icon,
            color: primaryTeal,
            size: 20,
          ),
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