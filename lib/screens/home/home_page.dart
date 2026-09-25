import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/pet_service.dart';
import '../../services/report_service.dart';
import '../account/my_account_page.dart';
import '../account/settings_page.dart';
import '../barangay/barangay_page.dart';
import '../pets/my_pets_page.dart';
import '../pets/pet_profile_page.dart';
import '../pets/register_pet_page.dart';
import '../reports/report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PetService _petService = PetService();
  final ReportService _reportService = ReportService();

  final ScrollController _dashboardScrollController = ScrollController();

  final FocusNode _dashboardFocusNode = FocusNode();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);

  static const Color alertRed = Color(0xFFDC2626);

  static const Color warmBackground = Color(0xFFFFFBF5);

  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  // ============================================================
  // INIT / DISPOSE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _dashboardScrollController.dispose();
    _dashboardFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // KEYBOARD SCROLLING
  // ============================================================

  void _scrollDashboardBy(double offset) {
    if (!_dashboardScrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _dashboardScrollController.position;

    final double target = (position.pixels + offset)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();

    _dashboardScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleDashboardKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _scrollDashboardBy(120);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _scrollDashboardBy(-120);
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _scrollDashboardBy(MediaQuery.of(context).size.height * 0.75);
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _scrollDashboardBy(-MediaQuery.of(context).size.height * 0.75);
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      _dashboardScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      if (!_dashboardScrollController.hasClients) {
        return;
      }

      _dashboardScrollController.animateTo(
        _dashboardScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: [
                SizedBox(width: 250, child: _buildDesktopSidebar()),
                Expanded(
                  child: SafeArea(
                    child: _buildDashboardContent(isDesktop: true),
                  ),
                ),
              ],
            );
          }

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildMobileHeader(),
                Expanded(child: _buildDashboardContent(isDesktop: false)),
                _buildMobileBottomNavigation(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CLAY DECORATION
  // ============================================================

  BoxDecoration _clayDecoration({
    Color color = Colors.white,
    double radius = 22,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.055),
          blurRadius: 18,
          offset: const Offset(5, 7),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.85),
          blurRadius: 10,
          offset: const Offset(-4, -4),
        ),
      ],
    );
  }

  // ============================================================
  // DESKTOP SIDEBAR
  // ============================================================

  Widget _buildDesktopSidebar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // LOGO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: _clayDecoration(color: lightTeal, radius: 14),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: primaryTeal,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'PawLink',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: darkTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SCROLLABLE SIDEBAR CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSidebarSectionLabel('MAIN'),

                  _buildSidebarItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: true,
                    onTap: () {},
                  ),

                  _buildSidebarItem(
                    icon: Icons.pets_rounded,
                    label: 'My Pets',
                    onTap: _openMyPets,
                  ),

                  _buildSidebarItem(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Register Pet',
                    onTap: _openRegisterPet,
                  ),

                  const SizedBox(height: 10),

                  _buildSidebarSectionLabel('COMMUNITY'),

                  _buildSidebarItem(
                    icon: Icons.report_problem_outlined,
                    label: 'Report',
                    onTap: _openReport,
                  ),

                  _buildSidebarItem(
                    icon: Icons.location_city_rounded,
                    label: 'Barangay',
                    onTap: _openBarangay,
                  ),

                  const SizedBox(height: 10),

                  _buildSidebarSectionLabel('ACCOUNT'),

                  _buildSidebarItem(
                    icon: Icons.person_outline_rounded,
                    label: 'My Account',
                    onTap: _openAccount,
                  ),

                  _buildSidebarItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: _openSettings,
                  ),

                  const SizedBox(height: 18),

                  _buildSidebarSafetyCard(),

                  const SizedBox(height: 18),

                  _buildSidebarItem(
                    icon: Icons.logout_rounded,
                    label: 'Log out',
                    danger: true,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: grayText,
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    bool danger = false,
  }) {
    final Color itemColor = danger
        ? alertRed
        : selected
        ? primaryTeal
        : darkText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? lightTeal : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 21, color: itemColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: primaryTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarSafetyCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _clayDecoration(color: const Color(0xFFFFF7F5), radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: alertRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: alertRed,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Pet Safety',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'If a pet is marked red, do not approach. Report it to the barangay instead.',
            style: TextStyle(fontSize: 11, height: 1.45, color: grayText),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE HEADER
  // ============================================================

  Widget _buildMobileHeader() {
    final User? user = _auth.currentUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: _clayDecoration(color: lightTeal, radius: 13),
            child: const Icon(Icons.pets_rounded, color: primaryTeal),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'PawLink',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: darkTeal,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotifications,
            icon: const Icon(Icons.notifications_none_rounded, color: darkText),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: lightTeal,
            child: Text(
              _getInitial(user?.email),
              style: const TextStyle(
                color: primaryTeal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitial(String? email) {
    if (email == null || email.isEmpty) {
      return 'P';
    }

    return email.substring(0, 1).toUpperCase();
  }

  // ============================================================
  // DASHBOARD CONTENT
  // ============================================================

  Widget _buildDashboardContent({required bool isDesktop}) {
    return KeyboardListener(
      focusNode: _dashboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleDashboardKey,
      child: Scrollbar(
        controller: _dashboardScrollController,
        thumbVisibility: isDesktop,
        child: SingleChildScrollView(
          controller: _dashboardScrollController,
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 38 : 18,
            isDesktop ? 32 : 22,
            isDesktop ? 38 : 18,
            isDesktop ? 40 : 100,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(isDesktop: isDesktop),

                  const SizedBox(height: 22),

                  _buildHeroCard(isDesktop: isDesktop),

                  const SizedBox(height: 22),

                  _buildStatsSection(isDesktop: isDesktop),

                  const SizedBox(height: 24),

                  _buildQuickActions(isDesktop: isDesktop),

                  const SizedBox(height: 24),

                  _buildPetsAndCommunitySection(isDesktop: isDesktop),

                  const SizedBox(height: 24),

                  _buildSafetyReminder(),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcomeHeader({required bool isDesktop}) {
    final User? user = _auth.currentUser;

    String name = 'Pet Parent';

    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      name = user.displayName!.trim();
    } else if (user?.email != null) {
      final String emailName = user!.email!.split('@').first;

      if (emailName.isNotEmpty) {
        name = emailName;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kamusta, $name! 👋',
                style: TextStyle(
                  fontSize: isDesktop ? 29 : 24,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Keep your pets connected, protected, and part of the community.',
                style: TextStyle(color: grayText, fontSize: 14, height: 1.45),
              ),
            ],
          ),
        ),
        if (isDesktop)
          IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotifications,
            icon: const Icon(Icons.notifications_none_rounded, color: darkText),
          ),
      ],
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard({required bool isDesktop}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 28 : 22),
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(5, 10),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _buildHeroText()),
                const SizedBox(width: 25),
                _buildHeroIcon(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroText(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildHeroIcon(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'COMMUNITY PET CARE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'One profile can help\nbring a pet home.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Register your pet and create a QR profile that can help the community identify and contact you.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.86),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: _openRegisterPet,
          icon: const Icon(Icons.add_rounded, size: 19),
          label: const Text('Register a Pet'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryTeal,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroIcon() {
    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Icon(Icons.pets_rounded, color: Colors.white, size: 58),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsSection({required bool isDesktop}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _petService.getMyPetsStream(),
      builder: (context, petSnapshot) {
        final int petCount = petSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<int>(
          stream: _reportService.getMyReportsCountStream(),
          builder: (context, reportSnapshot) {
            final int reportCount = reportSnapshot.data ?? 0;

            return _buildStatsLayout(
              isDesktop: isDesktop,
              petCount: petCount,
              qrCount: petCount,
              reportCount: reportCount,
              loadingPets:
                  petSnapshot.connectionState == ConnectionState.waiting,
              loadingReports:
                  reportSnapshot.connectionState == ConnectionState.waiting,
            );
          },
        );
      },
    );
  }

  Widget _buildStatsLayout({
    required bool isDesktop,
    required int petCount,
    required int qrCount,
    required int reportCount,
    required bool loadingPets,
    required bool loadingReports,
  }) {
    final List<Map<String, dynamic>> stats = [
      {
        'icon': Icons.pets_rounded,
        'label': 'My Pets',
        'value': loadingPets ? '...' : '$petCount',
        'color': primaryTeal,
      },
      {
        'icon': Icons.qr_code_2_rounded,
        'label': 'QR Profiles',
        'value': loadingPets ? '...' : '$qrCount',
        'color': darkTeal,
      },
      {
        'icon': Icons.assignment_outlined,
        'label': 'My Reports',
        'value': loadingReports ? '...' : '$reportCount',
        'color': alertRed,
      },
    ];

    if (isDesktop) {
      return Row(
        children: stats.map((stat) {
          final bool isLast = stat == stats.last;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 14),
              child: _buildStatCard(
                icon: stat['icon'] as IconData,
                label: stat['label'] as String,
                value: stat['value'] as String,
                color: stat['color'] as Color,
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: stats.map((stat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStatCard(
            icon: stat['icon'] as IconData,
            label: stat['label'] as String,
            value: stat['value'] as String,
            color: stat['color'] as Color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _clayDecoration(color: Colors.white, radius: 20),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: grayText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    color: darkText,
                    fontWeight: FontWeight.w800,
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
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Register Pet',
                  description: 'Create a pet profile',
                  color: primaryTeal,
                  onTap: _openRegisterPet,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.report_problem_outlined,
                  title: 'Report',
                  description: 'Report a lost or stray pet',
                  color: alertRed,
                  onTap: _openReport,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.location_city_rounded,
                  title: 'Barangay',
                  description: 'Community pet information',
                  color: darkTeal,
                  onTap: _openBarangay,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildActionTile(
                icon: Icons.add_circle_outline_rounded,
                title: 'Register Pet',
                description: 'Create a pet profile',
                color: primaryTeal,
                onTap: _openRegisterPet,
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.report_problem_outlined,
                title: 'Report',
                description: 'Report a lost or stray pet',
                color: alertRed,
                onTap: _openReport,
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.location_city_rounded,
                title: 'Barangay',
                description: 'Community pet information',
                color: darkTeal,
                onTap: _openBarangay,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: _clayDecoration(color: Colors.white, radius: 19),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 11, color: grayText),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: grayText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PETS + COMMUNITY
  // ============================================================

  Widget _buildPetsAndCommunitySection({required bool isDesktop}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _petService.getMyPetsStream(),
      builder: (context, snapshot) {
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data?.docs ?? [];

        final List<String> petIds = docs.map((doc) => doc.id).toList();

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildPetsPanel(
                  docs: docs,
                  loading: snapshot.connectionState == ConnectionState.waiting,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(flex: 2, child: _buildCommunityPanel(petIds)),
            ],
          );
        }

        return Column(
          children: [
            _buildPetsPanel(
              docs: docs,
              loading: snapshot.connectionState == ConnectionState.waiting,
            ),
            const SizedBox(height: 18),
            _buildCommunityPanel(petIds),
          ],
        );
      },
    );
  }

  Widget _buildPetsPanel({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    required bool loading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _clayDecoration(color: Colors.white, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My pets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openMyPets,
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Your registered pets and their profiles.',
            style: TextStyle(color: grayText, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: primaryTeal),
              ),
            )
          else if (docs.isEmpty)
            _buildEmptyPetsState()
          else
            Column(
              children: docs.take(3).map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPetRow(doc),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPetRow(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();

    final String petName = _readString(data, 'petName', 'Unnamed Pet');

    final String breed = _readString(data, 'breed', 'Breed not specified');

    final String status = _readString(data, 'status', 'alive');

    final String photoUrl = _readString(data, 'photoUrl', '');

    final String normalizedStatus = status.toLowerCase();

    final bool isDead = normalizedStatus == 'dead';

    final bool isLost = normalizedStatus == 'lost';

    Color statusColor = primaryTeal;

    if (isDead) {
      statusColor = grayText;
    } else if (isLost) {
      statusColor = alertRed;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PetProfilePage(petId: doc.id)),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: warmBackground,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _buildPetImage(photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      breed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: grayText),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatStatus(status),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: grayText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage(String photoUrl) {
    if (photoUrl.isEmpty) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: lightTeal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.pets_rounded, color: primaryTeal, size: 27),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        photoUrl,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 58,
            height: 58,
            color: lightTeal,
            child: const Icon(Icons.pets_rounded, color: primaryTeal),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPetsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: warmBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.pets_outlined, color: primaryTeal, size: 35),
          const SizedBox(height: 8),
          const Text(
            'No pets registered yet.',
            style: TextStyle(fontWeight: FontWeight.w700, color: darkText),
          ),
          const SizedBox(height: 5),
          const Text(
            'Start by creating your first pet profile.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: grayText),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _openRegisterPet,
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryTeal,
              side: const BorderSide(color: primaryTeal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Text('Register Pet'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMUNITY PANEL
  // ============================================================

  Widget _buildCommunityPanel(List<String> petIds) {
    if (petIds.isEmpty) {
      return _buildCommunityEmptyPanel();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _reportService.getFoundReportsStream(petIds),
      builder: (context, snapshot) {
        final int foundReports = snapshot.data?.docs.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _clayDecoration(color: lightTeal, radius: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCommunityHeader(),
              const SizedBox(height: 15),
              const Text(
                'Found reports connected to your registered pets.',
                style: TextStyle(fontSize: 12, color: grayText, height: 1.45),
              ),
              const SizedBox(height: 18),
              _buildFoundReportCount(foundReports),
              const SizedBox(height: 15),
              const Text(
                'A community report can help an owner locate a pet faster.',
                style: TextStyle(fontSize: 11, color: grayText, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityEmptyPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _clayDecoration(color: lightTeal, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommunityHeader(),
          const SizedBox(height: 15),
          const Text(
            'Register a pet first to receive community found reports connected to its profile.',
            style: TextStyle(fontSize: 12, color: grayText, height: 1.45),
          ),
          const SizedBox(height: 18),
          _buildFoundReportCount(0),
        ],
      ),
    );
  }

  Widget _buildCommunityHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.people_alt_outlined,
            color: primaryTeal,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Text(
            'Community pulse',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoundReportCount(int count) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: primaryTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Found reports',
                  style: TextStyle(fontSize: 11, color: grayText),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: darkText,
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
  // SAFETY
  // ============================================================

  Widget _buildSafetyReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: alertRed.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alertRed.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: alertRed),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety reminder',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'If you encounter a pet marked as aggressive or unsafe, do not approach it. Use PawLink to report the location to the barangay.',
                  style: TextStyle(color: grayText, fontSize: 11, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE NAVIGATION
  // ============================================================

  Widget _buildMobileBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.only(top: 7, bottom: 7),
      child: Row(
        children: [
          _buildBottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: true,
            onTap: () {},
          ),
          _buildBottomNavItem(
            icon: Icons.pets_rounded,
            label: 'My Pets',
            onTap: _openMyPets,
          ),
          _buildBottomNavItem(
            icon: Icons.report_problem_outlined,
            label: 'Report',
            onTap: _openReport,
          ),
          _buildBottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Account',
            onTap: _openAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: selected ? primaryTeal : grayText),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? primaryTeal : grayText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FIRESTORE HELPERS
  // ============================================================

  String _readString(Map<String, dynamic> data, String key, String fallback) {
    final dynamic value = data[key];

    if (value == null) {
      return fallback;
    }

    final String text = value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  String _formatStatus(String status) {
    final String formatted = status
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();

    if (formatted.isEmpty) {
      return 'Alive';
    }

    return formatted[0].toUpperCase() + formatted.substring(1).toLowerCase();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openRegisterPet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPetPage()),
    );
  }

  void _openMyPets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyPetsPage()),
    );
  }

  void _openReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportPage()),
    );
  }

  void _openBarangay() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarangayPage()),
    );
  }

  void _openAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyAccountPage()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: warmBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 38,
                        color: primaryTeal,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No new notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You are all caught up.',
                        style: TextStyle(color: grayText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out of PawLink?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: alertRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await _auth.signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out. Please try again.')),
      );
    }
  }
}
