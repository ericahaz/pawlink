import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/pet_service.dart';

class EditPetPage extends StatefulWidget {
  final String petId;

  const EditPetPage({super.key, required this.petId});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
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

  String _sex = 'unknown';

  Uint8List? _imageBytes;
  String _existingPhotoUrl = '';

  bool _isLoading = true;
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
  static const Color aggressiveRed = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

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
  // LOAD PET
  // ============================================================

  Future<void> _loadPet() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _petService.getPet(widget.petId);

      if (!snapshot.exists) {
        throw Exception('Pet profile no longer exists.');
      }

      final Map<String, dynamic> data = snapshot.data()!;

      if (!mounted) return;

      setState(() {
        _petNameController.text = _stringValue(data['petName']);
        _breedController.text = _stringValue(data['breed']);
        _colorController.text = _stringValue(data['color']);
        _ageController.text = _stringValue(data['age']);
        _identifyingMarksController.text =
            _stringValue(data['identifyingMarks']);

        final String savedSex =
            _stringValue(data['sex']).toLowerCase().trim();

        _sex = ['male', 'female', 'unknown'].contains(savedSex)
            ? savedSex
            : 'unknown';

        _ownerNameController.text = _stringValue(data['ownerName']);
        _ownerContactController.text = _stringValue(data['ownerContact']);
        _existingPhotoUrl = _stringValue(data['photoUrl']);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load pet information: $e')),
      );
    }
  }

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
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

      if (pickedImage == null) return;

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
  // SAVE CHANGES
  // ============================================================

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      String? photoUrl;

      // UPLOAD NEW PHOTO IF SELECTED

      if (_imageBytes != null) {
        photoUrl = await _petService.uploadPetPhotoBytes(
          petId: widget.petId,
          bytes: _imageBytes!,
        );
      }

      // UPDATE PET INFORMATION

      await _petService.updatePet(
        petId: widget.petId,
        petName: _petNameController.text,
        breed: _breedController.text,
        color: _colorController.text,
        age: _ageController.text,
        identifyingMarks: _identifyingMarksController.text,
        sex: _sex,
        ownerName: _ownerNameController.text,
        ownerContact: _ownerContactController.text,
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet information updated successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update pet information: $e')),
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
          'Edit Pet Information',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryTeal),
            )
          : LayoutBuilder(
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
                            _buildOwnerInformation(),
                            const SizedBox(height: 18),
                            _buildProtectedInformation(),
                            const SizedBox(height: 24),
                            _buildSaveButton(),
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
          'Update your pet profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Keep your pet information accurate so the community '
          'can identify and contact you when needed.',
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
            title: 'Pet Photo',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildImagePreview(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update the pet photo',
                      style: TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Use a clear and recent photo to help the '
                      'community identify your pet.',
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
                        _imageBytes == null
                            ? 'Change Photo'
                            : 'Choose Another Photo',
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
    if (_imageBytes != null) {
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

    if (_existingPhotoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          _existingPhotoUrl,
          width: 105,
          height: 105,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildEmptyImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryTeal,
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildEmptyImage();
  }

  Widget _buildEmptyImage() {
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
            isExpanded: true,
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
                value: 'male',
                child: Text('Male'),
              ),
              DropdownMenuItem(
                value: 'female',
                child: Text('Female'),
              ),
              DropdownMenuItem(
                value: 'unknown',
                child: Text('Unknown'),
              ),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _sex = value);
                    }
                  },
          ),
          const SizedBox(height: 14),

          // IDENTIFYING MARKS
          _buildTextField(
            controller: _identifyingMarksController,
            label: 'Identifying Marks',
            hint: 'Example: White spot on chest, scar on left ear',
            icon: Icons.fingerprint_rounded,
            validator: (value) => null,
          ),
        ],
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
  // PROTECTED INFORMATION
  // ============================================================

  Widget _buildProtectedInformation() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.lock_outline_rounded,
            title: 'Protected Information',
          ),
          const SizedBox(height: 8),
          const Text(
            'Some pet information is kept unchanged to protect '
            'the identity of the pet profile and its QR code.',
            style: TextStyle(
              color: grayText,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _buildProtectedRow(
            icon: Icons.tag_rounded,
            title: 'Pet ID',
            description: 'The unique identity of this pet cannot be changed.',
          ),
          const SizedBox(height: 10),
          _buildProtectedRow(
            icon: Icons.qr_code_2_rounded,
            title: 'QR Profile',
            description:
                'The existing QR identity remains connected to this pet.',
          ),
          const SizedBox(height: 10),
          _buildProtectedRow(
            icon: Icons.people_outline_rounded,
            title: 'Owners',
            description:
                'Owner accounts are managed separately through Joint Owners.',
          ),
          const SizedBox(height: 10),
          _buildProtectedRow(
            icon: Icons.favorite_outline_rounded,
            title: 'Pet Status',
            description: 'Alive or deceased status is managed separately.',
          ),
        ],
      ),
    );
  }

  Widget _buildProtectedRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: warmBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryTeal, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
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
          const Icon(
            Icons.lock_outline_rounded,
            color: grayText,
            size: 17,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveChanges,
        icon: _isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_isSaving ? 'Saving Changes...' : 'Save Changes'),
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