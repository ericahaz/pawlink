import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/barangay_model.dart';
import '../../services/barangay_service.dart';

class BarangayAdminPage extends StatefulWidget {
  const BarangayAdminPage({super.key});

  @override
  State<BarangayAdminPage> createState() => _BarangayAdminPageState();
}

class _BarangayAdminPageState extends State<BarangayAdminPage> {
  final BarangayService _service = BarangayService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _barangayNameController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _officeHoursController = TextEditingController();

  static const Color _primaryColor = Color(0xFF087F8C);
  static const Color _darkColor = Color(0xFF163A40);
  static const Color _backgroundColor = Color(0xFFF5F8F9);

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAdmin = false;
  bool _isActive = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBarangayDetails();
  }

  @override
  void dispose() {
    _barangayNameController.dispose();
    _municipalityController.dispose();
    _provinceController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _officeHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadBarangayDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final isAdmin = await _service.isCurrentUserAdmin(
        refreshToken: true,
      );

      if (!mounted) return;

      if (!isAdmin) {
        setState(() {
          _isAdmin = false;
          _isLoading = false;
        });
        return;
      }

      final BarangayModel? barangay = await _service.getBarangay();

      if (!mounted) return;

      if (barangay != null) {
        _barangayNameController.text = barangay.barangayName;
        _municipalityController.text = barangay.municipality;
        _provinceController.text = barangay.province;
        _addressController.text = barangay.address;
        _phoneController.text = barangay.phone;
        _emailController.text = barangay.email;
        _officeHoursController.text = barangay.officeHours;
        _isActive = barangay.isActive;
      }

      setState(() {
        _isAdmin = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return 'Permission denied. Please check your Firestore security rules and administrator access.';
    }

    if (message.contains('network')) {
      return 'A network error occurred. Please check your internet connection and try again.';
    }

    return 'Unable to load barangay details. Please try again.\n$message';
  }

  Future<void> _saveBarangayDetails() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final BarangayModel barangay = BarangayModel(
        barangayName: _barangayNameController.text.trim(),
        municipality: _municipalityController.text.trim(),
        province: _provinceController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        officeHours: _officeHoursController.text.trim(),
        isActive: _isActive,
      );

      await _service.saveBarangay(barangay);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barangay details saved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(e)),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _primaryColor),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE5E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE5E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    bool requiredField = false,
  }) {
    final bool isMultiline = maxLines > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextFormField(
        controller: controller,
        keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
        textInputAction:
            isMultiline ? TextInputAction.newline : TextInputAction.next,
        minLines: isMultiline ? 2 : 1,
        maxLines: maxLines,
        maxLength: maxLength,
        textCapitalization: TextCapitalization.sentences,
        validator: validator ??
            (requiredField
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required.';
                    }
                    return null;
                  }
                : null),
        decoration: _inputDecoration(
          label: label,
          icon: icon,
          hint: hint,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _darkColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Barangay Administration'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 58,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Administrator Access Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _darkColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You must sign in with the authorized PawLink administrator account to manage barangay information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadBarangayDetails,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Access Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Barangay Administration'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 18),
              const Text(
                'Unable to Load Barangay Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: _darkColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'An unexpected error occurred.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.5,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBarangayDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Barangay Administration'),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: _primaryColor,
          ),
        ),
      );
    }

    if (_errorMessage != null && !_isAdmin) {
      return _buildLoadError();
    }

    if (!_isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Barangay Administration',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF087F8C),
                          Color(0xFF075B65),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_city_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Barangay Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage the official contact information shown to people who scan PawLink pet QR codes.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionTitle(
                            'Office Details',
                            'Enter the official location of your barangay office.',
                          ),
                          _field(
                            label: 'Barangay Name',
                            icon: Icons.location_city,
                            controller: _barangayNameController,
                            hint: 'Enter barangay name',
                            requiredField: true,
                          ),
                          _field(
                            label: 'Municipality / City',
                            icon: Icons.map_outlined,
                            controller: _municipalityController,
                            hint: 'Enter municipality or city',
                            requiredField: true,
                          ),
                          _field(
                            label: 'Province',
                            icon: Icons.public,
                            controller: _provinceController,
                            hint: 'Enter province',
                            requiredField: true,
                          ),
                          _field(
                            label: 'Office Address',
                            icon: Icons.place_outlined,
                            controller: _addressController,
                            hint: 'Street, building, or office location',
                            maxLines: 3,
                            requiredField: true,
                          ),
                          const Divider(height: 30),
                          _sectionTitle(
                            'Contact Information',
                            'These details can help someone contact the barangay after scanning a pet QR code.',
                          ),
                          _field(
                            label: 'Official Phone Number',
                            icon: Icons.phone_outlined,
                            controller: _phoneController,
                            hint: 'Enter contact number',
                            keyboardType: TextInputType.phone,
                            maxLength: 30,
                            requiredField: true,
                          ),
                          _field(
                            label: 'Official Email Address',
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            hint: 'barangay@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Official email address is required.';
                              }

                              final email = value.trim();
                              final emailPattern =
                                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                              if (!emailPattern.hasMatch(email)) {
                                return 'Enter a valid email address.';
                              }

                              return null;
                            },
                            requiredField: true,
                          ),
                          _field(
                            label: 'Office Hours',
                            icon: Icons.access_time_outlined,
                            controller: _officeHoursController,
                            hint: 'Example: Monday–Friday, 8:00 AM–5:00 PM',
                            maxLines: 2,
                            requiredField: true,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _backgroundColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFDCE5E8),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _isActive
                                        ? Colors.green.withValues(
                                            alpha: 0.12,
                                          )
                                        : Colors.grey.withValues(
                                            alpha: 0.12,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isActive
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _isActive
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Public Contact Information',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _darkColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isActive
                                            ? 'Active and available for public display.'
                                            : 'Inactive; public display may be unavailable.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.4,
                                          color: Colors.blueGrey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isActive,
                                  activeThumbColor: _primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _isActive = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isSaving ? null : _saveBarangayDetails,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _isSaving
                                    ? 'Saving Details...'
                                    : 'Save Barangay Details',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    _primaryColor.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'PawLink • Barangay Administration',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
