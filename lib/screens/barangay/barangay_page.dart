import 'package:flutter/material.dart';

import '../../seasonal/seasonal_controller.dart';

import '../home/home_page.dart';
import '../pets/my_pets_page.dart';
import '../reports/report_page.dart';

Color get primaryTeal =>
    SeasonalController.instance.activeTheme?.primary ??
    const Color(0xFF0F766E);
Color get darkTeal =>
    SeasonalController.instance.activeTheme?.secondary ??
    const Color(0xFF115E59);
Color get lightTeal {
  final theme = SeasonalController.instance.activeTheme;
  if (theme == null) return const Color(0xFFE7F5F2);
  return Color.alphaBlend(
    theme.primary.withValues(alpha: 0.10),
    theme.surface,
  );
}
const alertRed = Color(0xFFDC2626);
Color get warmBackground =>
    SeasonalController.instance.activeTheme?.background ??
    const Color(0xFFFFFBF5);
Color get darkText =>
    SeasonalController.instance.activeTheme?.textPrimary ??
    const Color(0xFF243333);
Color get grayText =>
    SeasonalController.instance.activeTheme?.textSecondary ??
    const Color(0xFF667373);
Color get borderColor =>
    SeasonalController.instance.activeTheme?.border ??
    const Color(0xFFE3E5E3);
Color get surfaceColor =>
    SeasonalController.instance.activeTheme?.surface ?? Colors.white;
Color get onPrimaryColor =>
    SeasonalController.instance.activeTheme?.onPrimary ?? Colors.white;

class BarangayPage extends StatefulWidget {
  const BarangayPage({super.key});

  @override
  State<BarangayPage> createState() => _BarangayPageState();
}

class _BarangayPageState extends State<BarangayPage> {
  int _selectedIndex = 3;

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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReportPage()),
      );
    }
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: selected ? primaryTeal : grayText, size: 21),
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

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: surfaceColor,
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
                    child: Icon(Icons.pets, color: onPrimaryColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
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
              selected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportPage()),
                );
              },
            ),

            _sidebarItem(
              icon: Icons.account_balance_outlined,
              label: 'Barangay',
              selected: true,
              onTap: () {},
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: primaryTeal, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Use PawLink to report lost pets, found pets, and stray concerns.',
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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: grayText,
                    fontSize: 13,
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
                        Text(
                          'Barangay',
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
                    padding: EdgeInsets.all(isWide ? 30 : 22),
                    decoration: BoxDecoration(
                      color: primaryTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Barangay Support',
                                style: TextStyle(
                                  color: onPrimaryColor,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'A central place for community pet concerns, stray reports, and barangay assistance.',
                                style: TextStyle(
                                  color: onPrimaryColor.withValues(alpha: 0.90),
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
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: onPrimaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance,
                              color: onPrimaryColor,
                              size: 34,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'What can you report?',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (isWide)
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            icon: Icons.pets,
                            title: 'Stray Animals',
                            description: 'Report stray Aspin, Puspin, or other animals in your community.',
                            iconColor: primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.warning_amber_rounded,
                            title: 'Animal Concerns',
                            description: 'Report an injured, aggressive, or potentially dangerous animal.',
                            iconColor: alertRed,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            description: 'Provide the location so the responsible people can respond.',
                            iconColor: Colors.orange,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _infoCard(
                          icon: Icons.pets,
                          title: 'Stray Animals',
                          description: 'Report stray Aspin, Puspin, or other animals in your community.',
                          iconColor: primaryTeal,
                        ),
                        const SizedBox(height: 12),
                        _infoCard(
                          icon: Icons.warning_amber_rounded,
                          title: 'Animal Concerns',
                          description: 'Report an injured, aggressive, or potentially dangerous animal.',
                          iconColor: alertRed,
                        ),
                        const SizedBox(height: 12),
                        _infoCard(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          description: 'Provide the location so the responsible people can respond.',
                          iconColor: Colors.orange,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need to make a report?',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Use PawLink to send a lost pet, found pet, or stray/community report.',
                          style: TextStyle(
                            color: grayText,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReportPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.report_outlined),
                            label: const Text(
                              'Open Report Center',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryTeal,
                              foregroundColor: onPrimaryColor,
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

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.health_and_safety_outlined, color: alertRed),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safety reminder',
                                style: TextStyle(
                                  color: alertRed,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'If a stray animal is aggressive or frightened, do not approach or attempt to catch it. Report its location instead.',
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

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _changePage,
      backgroundColor: surfaceColor,
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
          ? _buildBottomNav()
          : null,
    );
  }
}
