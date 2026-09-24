import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportFoundPetPage extends StatefulWidget {
  final String petId;
  final String petName;

  const ReportFoundPetPage({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<ReportFoundPetPage> createState() => _ReportFoundPetPageState();
}

class _ReportFoundPetPageState extends State<ReportFoundPetPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('found_reports').add({
        'petId': widget.petId,
        'petName': widget.petName,
        'location': _locationController.text.trim(),
        'message': _messageController.text.trim(),
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'new',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thank you! Your report has been sent to the pet owner.',
          ),
          backgroundColor: Color(0xFF00897B),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send report: $e'),
          backgroundColor: Colors.red,
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
      backgroundColor: const Color(0xFFF8F6F1),

      appBar: AppBar(
        title: const Text('Report Found Pet'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =========================
                // ICON
                // =========================
                const Icon(Icons.pets, size: 60, color: Color(0xFF00897B)),

                const SizedBox(height: 16),

                // =========================
                // PET NAME
                // =========================
                Text(
                  'You found ${widget.petName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Please provide information about where you found the pet so the owner can locate them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 28),

                // =========================
                // LOCATION
                // =========================
                TextFormField(
                  controller: _locationController,

                  decoration: InputDecoration(
                    labelText: 'Where did you find the pet?',
                    hintText: 'Example: Barangay Hall, Cavite City',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00897B),
                        width: 2,
                      ),
                    ),
                  ),

                  maxLines: 2,

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the location.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =========================
                // MESSAGE
                // =========================
                TextFormField(
                  controller: _messageController,

                  decoration: InputDecoration(
                    labelText: 'Message',
                    hintText: 'Add any helpful information...',
                    prefixIcon: const Icon(Icons.message_outlined),
                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00897B),
                        width: 2,
                      ),
                    ),
                  ),

                  maxLines: 4,
                ),

                const SizedBox(height: 24),

                // =========================
                // SEND REPORT
                // =========================
                SizedBox(
                  height: 52,

                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // =========================
                // GUEST MESSAGE
                // =========================
                const Text(
                  'You do not need a PawLink account to submit a found-pet report.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
