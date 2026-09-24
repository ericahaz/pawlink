import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_page.dart';
import '../pets/my_pets_page.dart';
import '../barangay/barangay_page.dart';

const primaryTeal = Color(0xFF0F766E);
const darkTeal = Color(0xFF115E59);
const lightTeal = Color(0xFFE7F5F2);
const alertRed = Color(0xFFDC2626);
const warmBackground = Color(0xFFFFFBF5);
const darkText = Color(0xFF243333);
const grayText = Color(0xFF667373);
const borderColor = Color(0xFFE3E5E3);

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _selectedIndex = 2;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _changePage(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyPetsPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BarangayPage()),
      );
    }
  }

  void _showReportForm(String type) {
    final title = type == 'lost'
        ? 'Report Lost Pet'
        : type == 'found'
        ? 'Report Found Pet'
        : 'Report Stray / Barangay Concern';

    final description = type == 'lost'
        ? 'Tell us about the pet that went missing.'
        : type == 'found'
        ? 'Tell us about the pet you found.'
        : 'Report a stray animal or community concern to the barangay.';

    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool submitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: warmBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(color: grayText, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: type == 'stray'
                              ? 'Animal / Report Name'
                              : 'Pet Name',
                          hintText: type == 'stray'
                              ? 'Example: Brown stray dog'
                              : 'Example: Max',
                          prefixIcon: const Icon(Icons.pets_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          hintText: 'Barangay / street / landmark',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: detailsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Details',
                          hintText: type == 'lost'
                              ? 'Describe when and where the pet was last seen.'
                              : type == 'found'
                              ? 'Describe where you found the pet and what it looks like.'
                              : 'Describe the animal or concern.',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 65),
                            child: Icon(Icons.notes_outlined),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: lightTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: primaryTeal,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Please provide a clear location so the owner or barangay can respond more easily.',
                                style: TextStyle(
                                  color: darkTeal,
                                  fontSize: 13,
                                  height: 1.4,
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
                  onPressed: submitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: grayText),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: type == 'lost' ? alertRed : primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: submitting
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty ||
                              locationController.text.trim().isEmpty ||
                              detailsController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete all required fields.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            submitting = true;
                          });

                          try {
                            final user = _auth.currentUser;

                            await _firestore.collection('reports').add({
                              'type': type,
                              'name': nameController.text.trim(),
                              'location': locationController.text.trim(),
                              'details': detailsController.text.trim(),
                              'status': 'pending',
                              'reportedBy': user?.uid,
                              'reporterEmail': user?.email,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primaryTeal,
                                content: Text(
                                  type == 'lost'
                                      ? 'Lost pet report submitted.'
                                      : type == 'found'
                                      ? 'Found pet report submitted.'
                                      : 'Barangay concern submitted.',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              submitting = false;
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: alertRed,
                                content: Text('Unable to submit report: $e'),
                              ),
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.pets, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PawLink',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            const SizedBox(height: 18),

            _sidebarItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              selected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.pets_outlined,
              label: 'My Pets',
              selected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyPetsPage()),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.report_outlined,
              label: 'Reports',
              selected: true,
              onTap: () {},
            ),

            _sidebarItem(
              icon: Icons.account_balance_outlined,
              label: 'Barangay',
              selected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BarangayPage()),
                );
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: primaryTeal, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Keep yourself safe. Do not approach aggressive animals.',
                        style: TextStyle(
                          color: darkTeal,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Material(
        color: selected ? lightTeal : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 21, color: selected ? primaryTeal : grayText),
                const SizedBox(width: 13),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? darkTeal : grayText,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: grayText,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Start report',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.arrow_forward, color: color, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 36 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isWide)
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Reports',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                  if (!isWide) const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isWide ? 28 : 22),
                    decoration: BoxDecoration(
                      color: darkTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Report & Help',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose what you need to report. PawLink helps connect pet owners, finders, and the barangay.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isWide) ...[
                          const SizedBox(width: 25),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.campaign_outlined,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'What would you like to report?',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildReportCard(
                            icon: Icons.search_off,
                            title: 'Lost Pet',
                            description: 'Report a pet that is missing so you can keep track of the report.',
                            color: alertRed,
                            onTap: () => _showReportForm('lost'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildReportCard(
                            icon: Icons.pets,
                            title: 'Found Pet',
                            description: 'Report a pet you found and provide the location to help identify the owner.',
                            color: primaryTeal,
                            onTap: () => _showReportForm('found'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildReportCard(
                            icon: Icons.location_city_outlined,
                            title: 'Stray / Concern',
                            description: 'Report a stray animal or community concern to the barangay.',
                            color: Colors.orange.shade700,
                            onTap: () => _showReportForm('stray'),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildReportCard(
                          icon: Icons.search_off,
                          title: 'Lost Pet',
                          description: 'Report a pet that is missing so you can keep track of the report.',
                          color: alertRed,
                          onTap: () => _showReportForm('lost'),
                        ),
                        const SizedBox(height: 12),
                        _buildReportCard(
                          icon: Icons.pets,
                          title: 'Found Pet',
                          description: 'Report a pet you found and provide the location to help identify the owner.',
                          color: primaryTeal,
                          onTap: () => _showReportForm('found'),
                        ),
                        const SizedBox(height: 12),
                        _buildReportCard(
                          icon: Icons.location_city_outlined,
                          title: 'Stray / Barangay Concern',
                          description: 'Report a stray animal or community concern to the barangay.',
                          color: Colors.orange.shade700,
                          onTap: () => _showReportForm('stray'),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: primaryTeal),
                            SizedBox(width: 10),
                            Text(
                              'How reporting works',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        _StepItem(
                          number: '1',
                          title: 'Choose a report',
                          description: 'Select lost pet, found pet, or stray/ barangay concern.',
                        ),
                        _StepItem(
                          number: '2',
                          title: 'Add the details',
                          description: 'Provide the location and information that can help.',
                        ),
                        _StepItem(
                          number: '3',
                          title: 'Submit',
                          description:
                              'Your report is saved to PawLink for follow-up.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: alertRed.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: alertRed),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safety first',
                                style: TextStyle(
                                  color: alertRed,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'If an animal looks aggressive, injured, or scared, keep your distance. Do not try to catch it. Report its location instead.',
                                style: TextStyle(
                                  color: darkText,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _changePage,
      backgroundColor: Colors.white,
      indicatorColor: lightTeal,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.pets_outlined),
          selectedIcon: Icon(Icons.pets),
          label: 'My Pets',
        ),
        NavigationDestination(
          icon: Icon(Icons.report_outlined),
          selectedIcon: Icon(Icons.report),
          label: 'Report',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_outlined),
          selectedIcon: Icon(Icons.account_balance),
          label: 'Barangay',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildMainContent()),
              ],
            );
          }

          return _buildMainContent();
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 900
          ? _buildMobileBottomNav()
          : null,
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: lightTeal,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: primaryTeal,
                fontWeight: FontWeight.w800,
              ),
            ),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: grayText,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
