import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportLostPetPage extends StatefulWidget {
  const ReportLostPetPage({super.key});

  @override
  State<ReportLostPetPage> createState() => _ReportLostPetPageState();
}

class _ReportLostPetPageState extends State<ReportLostPetPage> {
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  final _formKey = GlobalKey<FormState>();

  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  DateTime _lostDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _lostDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        _lostDate = selected;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reportType': 'lost',
        'petName': _petNameController.text.trim(),
        'breed': _breedController.text.trim(),
        'color': _colorController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'contactNumber': _contactController.text.trim(),
        'lostDate': Timestamp.fromDate(_lostDate),
        'reporterId': user?.uid,
        'reporterEmail': user?.email,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF15803D)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Report submitted',
                    style: TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Your lost pet report has been recorded. '
              'Keep your contact information available in case someone finds your pet.',
              style: TextStyle(color: grayText, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit the report. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Column(
            children: [
              _buildHeader(isDesktop),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 38 : 18,
                    24,
                    isDesktop ? 38 : 18,
                    40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: _buildPageContent(isDesktop),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 30 : 16,
          vertical: 13,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                  style: IconButton.styleFrom(backgroundColor: warmBackground),
                  icon: const Icon(Icons.arrow_back_rounded, color: darkText),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: alertRed,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Lost Pet',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Help bring a pet home',
                        style: TextStyle(color: grayText, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(bool isDesktop) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntro(isDesktop),
          const SizedBox(height: 20),
          _buildAlertCard(),
          const SizedBox(height: 20),
          _buildPetInformationCard(),
          const SizedBox(height: 16),
          _buildLocationCard(),
          const SizedBox(height: 16),
          _buildDescriptionCard(),
          const SizedBox(height: 16),
          _buildContactCard(),
          const SizedBox(height: 20),
          _buildSafetyReminder(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildIntro(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell the community your pet is missing.',
          style: TextStyle(
            color: darkText,
            fontSize: isDesktop ? 30 : 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Provide the details people need to recognize your pet '
          'and contact you if they find them.',
          style: TextStyle(color: grayText, fontSize: 14, height: 1.55),
        ),
      ],
    );
  }

  Widget _buildAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF2CACA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: alertRed, size: 23),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report as soon as possible',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'The sooner your pet is reported, the sooner '
                  'your community can watch for them.',
                  style: TextStyle(color: grayText, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInformationCard() {
    return _buildSectionCard(
      title: 'Pet information',
      subtitle: 'Start with the details people can use to identify your pet.',
      icon: Icons.pets_rounded,
      children: [
        _buildTextField(
          controller: _petNameController,
          label: 'Pet name',
          hint: 'e.g. Max',
          icon: Icons.pets_rounded,
          requiredField: true,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 550) {
              return Column(
                children: [
                  _buildTextField(
                    controller: _breedController,
                    label: 'Breed',
                    hint: 'e.g. Aspin, Shih Tzu',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _colorController,
                    label: 'Color / markings',
                    hint: 'e.g. Brown with white chest',
                    icon: Icons.palette_outlined,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _breedController,
                    label: 'Breed',
                    hint: 'e.g. Aspin, Shih Tzu',
                    icon: Icons.category_outlined,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    controller: _colorController,
                    label: 'Color / markings',
                    hint: 'e.g. Brown with white chest',
                    icon: Icons.palette_outlined,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return _buildSectionCard(
      title: 'Last seen',
      subtitle: 'Tell people where and when your pet was last seen.',
      icon: Icons.location_on_outlined,
      children: [
        _buildTextField(
          controller: _locationController,
          label: 'Last seen location',
          hint: 'e.g. Near the barangay hall',
          icon: Icons.location_on_outlined,
          requiredField: true,
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date last seen',
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: borderColor),
              ),
            ),
            child: Text(
              '${_lostDate.month}/${_lostDate.day}/${_lostDate.year}',
              style: const TextStyle(color: darkText, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return _buildSectionCard(
      title: 'Additional details',
      subtitle: 'Anything that can help someone recognize your pet.',
      icon: Icons.notes_rounded,
      children: [
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Describe your pet, collar, markings, behavior, or other useful details.',
          icon: Icons.notes_rounded,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return _buildSectionCard(
      title: 'How can people contact you?',
      subtitle: 'Use a number or contact detail where you can be reached.',
      icon: Icons.contact_phone_outlined,
      children: [
        _buildTextField(
          controller: _contactController,
          label: 'Contact number',
          hint: 'e.g. 09XX XXX XXXX',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          requiredField: true,
        ),
      ],
    );
  }

  Widget _buildSafetyReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4D7CC)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: alertRed, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay safe while searching',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Avoid entering unsafe areas or approaching unfamiliar animals. '
                  'Ask your barangay for assistance when needed.',
                  style: TextStyle(color: grayText, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitReport,
        icon: _isSubmitting
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(_isSubmitting ? 'Submitting...' : 'Submit Lost Pet Report'),
        style: ElevatedButton.styleFrom(
          backgroundColor: alertRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: alertRed.withValues(alpha: 0.55),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryTeal, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: grayText,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 55 : 0),
          child: Icon(icon, size: 20),
        ),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: alertRed),
        ),
        filled: true,
        fillColor: const Color(0xFFFCFCFB),
      ),
    );
  }
}
