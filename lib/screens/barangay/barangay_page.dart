
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
  final int _selectedIndex = 3;

  // ============================================================
  // DARK MODE COLORS
  // ============================================================

  bool get _isDarkMode =>
      Theme.of(context).brightness == Brightness.dark;

  Color get _pageBackground => _isDarkMode
      ? const Color(0xFF121A1B)
      : warmBackground;

  Color get _cardBackground => _isDarkMode
      ? const Color(0xFF1D292A)
      : Colors.white;

  Color get _primaryTextColor =>
      _isDarkMode ? Colors.white : darkText;

  Color get _secondaryTextColor =>
      _isDarkMode ? Colors.white70 : grayText;

  Color get _outlineColor => _isDarkMode
      ? const Color(0xFF344344)
      : borderColor;

  Color get _softTealBackground => _isDarkMode
      ? const Color(0xFF263738)
      : lightTeal;

  Color get _accentColor => _isDarkMode
      ? const Color(0xFF2DD4BF)
      : primaryTeal;

  Color get _sidebarBackground => _isDarkMode
      ? const Color(0xFF1D292A)
      : Colors.white;

  // ============================================================
  // NAVIGATION
  // ============================================================

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

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 3,
      ),
      child: Material(
        color: selected
            ? _softTealBackground
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? _accentColor
                      : _secondaryTextColor,
                  size: 21,
                ),
                const SizedBox(width: 13),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? _accentColor
                        : _secondaryTextColor,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
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
      color: _sidebarBackground,
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
                  Text(
                    'PawLink',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: _primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: _outlineColor,
            ),

            const SizedBox(height: 18),

            _sidebarItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              selected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
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
                  MaterialPageRoute(
                    builder: (_) => const MyPetsPage(),
                  ),
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
                  MaterialPageRoute(
                    builder: (_) => const ReportPage(),
                  ),
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
                  color: _softTealBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Use PawLink to report lost pets, found pets, and stray concerns.',
                        style: TextStyle(
                          color: _isDarkMode
                              ? Colors.white70
                              : darkTeal,
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

  // ============================================================
  // INFORMATION CARDS
  // ============================================================

  Widget _infoCard({
  required IconData icon,
  required String title,
  required String description,
  required Color iconColor,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _cardBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _outlineColor),
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
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _primaryTextColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  color: _secondaryTextColor,
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

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 36 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
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
                          icon: Icon(
                            Icons.arrow_back,
                            color: _primaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Barangay',
                          style: TextStyle(
                            color: _primaryTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                  if (!isWide) const SizedBox(height: 16),

                  // Barangay Support Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      isWide ? 30 : 22,
                    ),
                    decoration: BoxDecoration(
                      color: primaryTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                                  color: Colors.white.withValues(alpha: 0.90),
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
                              color: Colors.white.withValues(alpha: 0.12),
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
                      color: _primaryTextColor,
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
                            description:
                                'Report stray Aspin, Puspin, or other animals in your community.',
                            iconColor: primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.warning_amber_rounded,
                            title: 'Animal Concerns',
                            description:
                                'Report an injured, aggressive, or potentially dangerous animal.',
                            iconColor: alertRed,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            description:
                                'Provide the location so the responsible people can respond.',
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
                          description:
                              'Report stray Aspin, Puspin, or other animals in your community.',
                          iconColor: primaryTeal,
                        ),
                        const SizedBox(height: 12),
                        _infoCard(
                          icon: Icons.warning_amber_rounded,
                          title: 'Animal Concerns',
                          description:
                              'Report an injured, aggressive, or potentially dangerous animal.',
                          iconColor: alertRed,
                        ),
                        const SizedBox(height: 12),
                        _infoCard(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          description:
                              'Provide the location so the responsible people can respond.',
                          iconColor: Colors.orange,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Open Report Center Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _outlineColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need to make a report?',
                          style: TextStyle(
                            color: _primaryTextColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Use PawLink to send a lost pet, found pet, or stray/community report.',
                          style: TextStyle(
                            color: _secondaryTextColor,
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
                            icon: const Icon(
                              Icons.report_outlined,
                            ),
                            label: const Text(
                              'Open Report Center',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryTeal,
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

                  // Safety Reminder
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? const Color(0xFF382426)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: _isDarkMode
                          ? Border.all(
                              color: const Color(0xFF6B3434),
                            )
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.health_and_safety_outlined,
                          color: alertRed,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Safety reminder',
                                style: TextStyle(
                                  color: Color(0xFFFF7777),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'If a stray animal is aggressive or frightened, do not approach or attempt to catch it. Report its location instead.',
                                style: TextStyle(
                                  color: _isDarkMode
                                      ? Colors.white70
                                      : _primaryTextColor,
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

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _changePage,
      backgroundColor: _sidebarBackground,
      indicatorColor: _softTealBackground,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            );
          }

          return _buildMainContent();
        },
      ),
      bottomNavigationBar:
          MediaQuery.of(context).size.width < 900
              ? _buildBottomNav()
              : null,
    );
  }
}
