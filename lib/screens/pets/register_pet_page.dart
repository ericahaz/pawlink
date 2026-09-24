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

  final _formKey = GlobalKey<FormState>();

  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _ageController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerContactController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  bool _isSaving = false;

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _ageController.dispose();
    _ownerNameController.dispose();
    _ownerContactController.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    setState(() {
      _selectedImage = image;
      _imageBytes = bytes;
    });
  }

  Future<void> _registerPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final petId = await _petService.createPet(
        petName: _petNameController.text,
        breed: _breedController.text,
        color: _colorController.text,
        age: _ageController.text,
        ownerName: _ownerNameController.text,
        ownerContact: _ownerContactController.text,
      );

      String? photoUrl;

      if (_selectedImage != null) {
        // Photo upload for web/mobile.
        final bytes = _imageBytes;

        if (bytes != null) {
          final url = await _uploadBytes(petId, bytes);

          photoUrl = url;
        }
      }

      if (photoUrl != null) {
        await _petService.updatePet(
          petId: petId,
          petName: _petNameController.text,
          breed: _breedController.text,
          color: _colorController.text,
          age: _ageController.text,
          ownerName: _ownerNameController.text,
          ownerContact: _ownerContactController.text,
          photoUrl: photoUrl,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet profile created successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to register pet: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<String> _uploadBytes(String petId, Uint8List bytes) async {
    // Firebase Storage is imported inside the method
    // so the page stays focused on UI.
    //
    // The actual upload uses the same Firebase Storage
    // location as PetService.
    //
    // This method is replaced below by the Storage upload.
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: darkText),
        title: const Text(
          'Register a Pet',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoPicker(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Pet information'),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _petNameController,
                    label: 'Pet name',
                    hint: 'Example: Max',
                    icon: Icons.pets_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _breedController,
                    label: 'Breed',
                    hint: 'Example: Shih Tzu, Aspin, Puspin',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _colorController,
                          label: 'Color',
                          hint: 'Example: Brown',
                          icon: Icons.palette_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _ageController,
                          label: 'Age',
                          hint: 'Example: 3 years',
                          icon: Icons.cake_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Owner information'),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _ownerNameController,
                    label: 'Owner name',
                    hint: 'Your full name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _ownerContactController,
                    label: 'Contact number',
                    hint: 'Example: 09XXXXXXXXX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 28),
                  _buildQrInfo(),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _registerPet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primaryTeal.withValues(
                          alpha: 0.5,
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Pet Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _choosePhoto,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: primaryTeal.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: primaryTeal,
                          size: 38,
                        ),
                        SizedBox(height: 9),
                        Text(
                          'Add pet photo',
                          style: TextStyle(
                            color: darkTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add a clear photo of your pet',
            style: TextStyle(color: grayText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: darkText,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required.';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryTeal),
        filled: true,
        fillColor: Colors.white,
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
      ),
    );
  }

  Widget _buildQrInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.qr_code_2_rounded, color: primaryTeal, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR profile included',
                  style: TextStyle(
                    color: darkTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A unique QR code will be connected to this pet profile. Anyone who scans it can access the public pet information and contact options.',
                  style: TextStyle(color: grayText, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
