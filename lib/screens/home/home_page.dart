import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/pet_service.dart';
import '../../services/report_service.dart';
import '../account/my_account_page.dart';
import '../account/settings_page.dart';
import '../barangay/barangay_page.dart';
import '../help/help_center_page.dart';
import '../landing/landing_page.dart';
import '../pets/my_pets_page.dart';
import '../pets/pet_profile_page.dart';
import '../pets/register_pet_page.dart';
import '../reports/report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PetService _petService = PetService();
  final ReportService _reportService = ReportService();

  final ScrollController _dashboardScrollController = ScrollController();
  final FocusNode _dashboardFocusNode = FocusNode();

  late final AnimationController _backgroundAnimationController;

  static const Color primaryTeal = Color(0xFF0A7E8C);
  static const Color darkTeal = Color(0xFF075C65);
  static const Color deepTeal = Color(0xFF064B52);

  static const Color lightTeal = Color(0xFFE5F4F5);
  static const Color softerTeal = Color(0xFFF0F8F8);

  static const Color alertRed = Color(0xFFEE5253);
  static const Color warmOrange = Color(0xFFFF9F43);
  static const Color foundGreen = Color(0xFF10AC84);
  static const Color qrBlue = Color(0xFF2E86DE);

  static const Color warmBackground = Color(0xFFF8F9FA);

  static const Color darkText = Color(0xFF263238);
  static const Color grayText = Color(0xFF667085);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
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
      if (_dashboardScrollController.hasClients) {
        _dashboardScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      if (_dashboardScrollController.hasClients) {
        _dashboardScrollController.animateTo(
          _dashboardScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData baseTheme = Theme.of(context);
    final TextTheme poppinsTextTheme = GoogleFonts.poppinsTextTheme(
      baseTheme.textTheme,
    );

    return Theme(
      data: baseTheme.copyWith(
        textTheme: poppinsTextTheme,
        primaryTextTheme: GoogleFonts.poppinsTextTheme(
          baseTheme.primaryTextTheme,
        ),
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: primaryTeal,
          secondary: warmOrange,
          error: alertRed,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: warmBackground,
        appBarTheme: baseTheme.appBarTheme.copyWith(
          backgroundColor: Colors.white,
          foregroundColor: darkText,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: warmOrange,
            foregroundColor: darkText,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: warmBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 900;

            if (isDesktop) {
              return Row(
                children: [
                  SizedBox(width: 258, child: _buildDesktopSidebar()),
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
                  Expanded(
                    child: _buildDashboardContent(isDesktop: false),
                  ),
                  _buildMobileBottomNavigation(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // BACKGROUND ANIMATION
  // ============================================================

  Widget _buildAnimatedBackground({required Widget child}) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, _) {
        return Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: warmBackground),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PawLinkBackgroundPainter(
                    progress: _backgroundAnimationController.value,
                    primaryTeal: primaryTeal,
                    darkTeal: darkTeal,
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
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
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.80),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.055),
          blurRadius: 20,
          offset: const Offset(5, 8),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.90),
          blurRadius: 12,
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
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _goToLanding,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 2,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: _clayDecoration(
                        color: lightTeal,
                        radius: 15,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: primaryTeal,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PawLink',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: darkTeal,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Community Pet Care',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
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
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
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
                  _buildSidebarItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help Center',
                    onTap: _openHelpCenter,
                  ),
                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.3,
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
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
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
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 7,
                    height: 7,
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3F3),
            Color(0xFFFFEEEE),
          ],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: alertRed.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: alertRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
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
            style: TextStyle(
              fontSize: 11,
              height: 1.45,
              color: grayText,
            ),
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
      padding: const EdgeInsets.fromLTRB(17, 12, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _goToLanding,
            child: Container(
              width: 43,
              height: 43,
              decoration: _clayDecoration(
                color: lightTeal,
                radius: 14,
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: primaryTeal,
                size: 23,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _goToLanding,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PawLink',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: darkTeal,
                      ),
                    ),
                    Text(
                      'Community Pet Care',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: grayText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotifications,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: darkText,
            ),
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
    return _buildAnimatedBackground(
      child: KeyboardListener(
        focusNode: _dashboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleDashboardKey,
        child: Scrollbar(
          controller: _dashboardScrollController,
          thumbVisibility: isDesktop,
          child: SingleChildScrollView(
            controller: _dashboardScrollController,
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 40 : 17,
              isDesktop ? 30 : 20,
              isDesktop ? 40 : 17,
              isDesktop ? 45 : 105,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(isDesktop: isDesktop),
                    const SizedBox(height: 20),
                    _buildHeroCard(isDesktop: isDesktop),
                    const SizedBox(height: 22),
                    _buildStatsSection(isDesktop: isDesktop),
                    const SizedBox(height: 27),
                    _buildQuickActions(isDesktop: isDesktop),
                    const SizedBox(height: 27),
                    _buildPetsAndCommunitySection(isDesktop: isDesktop),
                    const SizedBox(height: 27),
                    _buildSafetyReminder(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME HEADER
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 12,
                      color: primaryTeal,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'YOUR PET COMMUNITY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: primaryTeal,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kamusta, $name! 🐾',
                style: TextStyle(
                  fontSize: isDesktop ? 30 : 25,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                  height: 1.1,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Keep your pets connected, protected, and part of the community.',
                style: TextStyle(
                  color: grayText,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        if (isDesktop)
          Container(
            decoration: _clayDecoration(
              color: Colors.white,
              radius: 15,
            ),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: _showNotifications,
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: darkText,
              ),
            ),
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
      padding: EdgeInsets.all(isDesktop ? 30 : 21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryTeal, darkTeal, deepTeal],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(6, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: isDesktop ? 155 : 70,
            top: -15,
            child: _buildHeroBubble(size: 115, opacity: 0.06),
          ),
          Positioned(
            right: 18,
            bottom: -30,
            child: _buildHeroBubble(size: 145, opacity: 0.05),
          ),
          Positioned(
            right: isDesktop ? 270 : 125,
            bottom: 15,
            child: _buildDecorativePaw(size: 25, opacity: 0.07),
          ),
          Positioned(
            right: 28,
            top: 20,
            child: _buildDecorativePaw(size: 22, opacity: 0.08),
          ),
          Positioned(
            right: isDesktop ? 210 : 80,
            bottom: 30,
            child: _buildDecorativePaw(size: 15, opacity: 0.06),
          ),
          isDesktop
              ? Row(
                  children: [
                    Expanded(child: _buildHeroText()),
                    const SizedBox(width: 30),
                    _buildHeroPetIllustration(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroText(),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildHeroPetIllustration(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildHeroBubble({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: const Text(
            'COMMUNITY PET CARE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'One profile can help\nbring a pet home.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            height: 1.10,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
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
          label: const Text(
            'Register a Pet',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: warmOrange,
            foregroundColor: darkText,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPetIllustration() {
    return Container(
      width: 138,
      height: 138,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            right: 18,
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white.withValues(alpha: 0.30),
              size: 20,
            ),
          ),
          Positioned(
            top: 33,
            left: 17,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.18),
              size: 16,
            ),
          ),
          Positioned(
            bottom: 17,
            left: 18,
            child: Icon(
              Icons.pets_rounded,
              color: Colors.white.withValues(alpha: 0.14),
              size: 25,
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativePaw({
    required double size,
    required double opacity,
  }) {
    return Icon(
      Icons.pets_rounded,
      size: size,
      color: Colors.white.withValues(alpha: opacity),
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

        final int qrCount = petSnapshot.data?.docs.where((doc) {
              return doc.data()['qrEnabled'] == true;
            }).length ??
            0;

        return StreamBuilder<int>(
          stream: _reportService.getMyReportsCountStream(),
          builder: (context, reportSnapshot) {
            final int reportCount = reportSnapshot.data ?? 0;

            return _buildStatsLayout(
              isDesktop: isDesktop,
              petCount: petCount,
              qrCount: qrCount,
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
        'subtitle': 'Registered',
      },
      {
        'icon': Icons.qr_code_2_rounded,
        'label': 'QR Profiles',
        'value': loadingPets ? '...' : '$qrCount',
        'color': qrBlue,
        'subtitle': 'Connected',
      },
      {
        'icon': Icons.assignment_outlined,
        'label': 'My Reports',
        'value': loadingReports ? '...' : '$reportCount',
        'color': alertRed,
        'subtitle': 'Submitted',
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
                subtitle: stat['subtitle'] as String,
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
            subtitle: stat['subtitle'] as String,
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
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () {
          if (label == 'My Pets' || label == 'QR Profiles') {
            _openMyPets();
          } else if (label == 'My Reports') {
            _openReport();
          }
        },
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: _clayDecoration(color: Colors.white, radius: 21),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        color: darkText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: 0.45),
                size: 14,
              ),
            ],
          ),
        ),
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
        const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What would you like to do?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Quick access to your most important PawLink tools.',
                    style: TextStyle(fontSize: 12, color: grayText),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Register Pet',
                  description: 'Create a new pet profile',
                  color: warmOrange,
                  onTap: _openRegisterPet,
                  tag: 'START HERE',
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
                  tag: 'COMMUNITY',
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
                  tag: 'LOCAL HELP',
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
                description: 'Create a new pet profile',
                color: warmOrange,
                onTap: _openRegisterPet,
                tag: 'START HERE',
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.report_problem_outlined,
                title: 'Report',
                description: 'Report a lost or stray pet',
                color: alertRed,
                onTap: _openReport,
                tag: 'COMMUNITY',
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.location_city_rounded,
                title: 'Barangay',
                description: 'Community pet information',
                color: darkTeal,
                onTap: _openBarangay,
                tag: 'LOCAL HELP',
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
    required String tag,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: _clayDecoration(color: Colors.white, radius: 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: grayText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: warmBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: grayText,
                ),
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

  Widget _buildPetsAndCommunitySection({
    required bool isDesktop,
  }) {
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
              Expanded(
                flex: 2,
                child: _buildCommunityPanel(petIds),
              ),
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

  // ============================================================
  // YOUR PAW FAMILY
  // ============================================================

  Widget _buildPetsPanel({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    required bool loading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _clayDecoration(color: Colors.white, radius: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: primaryTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Paw Family',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your registered companions',
                      style: TextStyle(
                        color: grayText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _openMyPets,
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PetProfilePage(petId: doc.id),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: warmBackground,
            borderRadius: BorderRadius.circular(18),
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
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      breed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: grayText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatStatus(status),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: grayText,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage(String photoUrl) {
    if (photoUrl.isEmpty) {
      return Container(
        width: 63,
        height: 63,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightTeal, softerTeal],
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 7,
              right: 7,
              child: Icon(
                Icons.favorite_rounded,
                color: primaryTeal.withValues(alpha: 0.12),
                size: 14,
              ),
            ),
            const Icon(
              Icons.pets_rounded,
              color: primaryTeal,
              size: 30,
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: Image.network(
        photoUrl,
        width: 63,
        height: 63,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 63,
            height: 63,
            color: lightTeal,
            child: const Icon(
              Icons.pets_rounded,
              color: primaryTeal,
              size: 30,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPetsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [warmBackground, Color(0xFFFFF7ED)],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: lightTeal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryTeal.withValues(alpha: 0.08),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: primaryTeal,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your paw family starts here.',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: darkText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Create your first pet profile and give your pet a connected identity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: grayText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _openRegisterPet,
            icon: const Icon(Icons.add_rounded, size: 17),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryTeal,
              side: const BorderSide(color: primaryTeal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            label: const Text(
              'Register Pet',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lightTeal, softerTeal],
            ),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryTeal.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(4, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCommunityHeader(),
              const SizedBox(height: 15),
              const Text(
                'Found reports connected to your registered pets.',
                style: TextStyle(
                  fontSize: 12,
                  color: grayText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 17),
              _buildFoundReportCount(foundReports),
              const SizedBox(height: 14),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: primaryTeal,
                    size: 15,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Community reports can help owners locate pets faster.',
                      style: TextStyle(
                        fontSize: 10,
                        color: grayText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightTeal, softerTeal],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommunityHeader(),
          const SizedBox(height: 15),
          const Text(
            'Register a pet first to receive community found reports connected to its profile.',
            style: TextStyle(
              fontSize: 12,
              color: grayText,
              height: 1.45,
            ),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primaryTeal.withValues(alpha: 0.06),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.people_alt_outlined,
            color: primaryTeal,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community pulse',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Looking out for one another',
                style: TextStyle(
                  fontSize: 9,
                  color: grayText,
                ),
              ),
            ],
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
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: foundGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: foundGreen,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Found reports',
                  style: TextStyle(
                    fontSize: 10,
                    color: grayText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: foundGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NEW ACTIVITY',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: foundGreen,
                  letterSpacing: 0.5,
                ),
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
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3F3), Color(0xFFFFEEEE)],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: alertRed.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: alertRed.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: alertRed,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Safety reminder',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 7),
                    Text(
                      '•',
                      style: TextStyle(
                        color: alertRed,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 7),
                    Text(
                      'STAY SAFE',
                      style: TextStyle(
                        color: alertRed,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  'If you encounter a pet marked as aggressive or unsafe, do not approach it. Use PawLink to report the location to the barangay.',
                  style: TextStyle(
                    color: grayText,
                    fontSize: 11,
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
  // MOBILE NAVIGATION
  // ============================================================

  Widget _buildMobileBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected ? lightTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: selected ? primaryTeal : grayText,
                ),
              ),
              const SizedBox(height: 2),
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

  String _readString(
    Map<String, dynamic> data,
    String key,
    String fallback,
  ) {
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
    final String formatted =
        status.replaceAll('_', ' ').replaceAll('-', ' ').trim();

    if (formatted.isEmpty) {
      return 'Alive';
    }

    return formatted[0].toUpperCase() + formatted.substring(1).toLowerCase();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _goToLanding() {
    FocusScope.of(context).unfocus();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LandingPage(),
      ),
      (route) => false,
    );
  }

  void _openRegisterPet() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const RegisterPetPage(),
      ),
    );
  }

  void _openMyPets() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const MyPetsPage(),
      ),
    );
  }

  void _openReport() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const ReportPage(),
      ),
    );
  }

  void _openBarangay() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const BarangayPage(),
      ),
    );
  }

  void _openAccount() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const MyAccountPage(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SettingsPage(),
      ),
    );
  }

  void _openHelpCenter() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const HelpCenterPage(),
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: lightTeal,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(21),
                  decoration: BoxDecoration(
                    color: warmBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 40,
                        color: primaryTeal,
                      ),
                      SizedBox(height: 9),
                      Text(
                        'No new notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You are all caught up.',
                        style: TextStyle(
                          color: grayText,
                          fontSize: 12,
                        ),
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
  // UPDATED LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of PawLink?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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

    // Do nothing if the user cancels or this page is no longer active.
    if (shouldLogout != true || !mounted) {
      return;
    }

    try {
      // Sign out from Firebase first.
      await _auth.signOut();

      if (!mounted) {
        return;
      }

      // Remove HomePage and all previously pushed pages.
      // The public LandingPage becomes the only page in the stack.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LandingPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to log out. Please try again.',
          ),
        ),
      );
    }
  }
}

// ================================================================
// PAWLINK BACKGROUND PAINTER
// ================================================================

class _PawLinkBackgroundPainter extends CustomPainter {
  final double progress;
  final Color primaryTeal;
  final Color darkTeal;

  const _PawLinkBackgroundPainter({
    required this.progress,
    required this.primaryTeal,
    required this.darkTeal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pawPaint = Paint()
      ..color = primaryTeal.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;

    final Paint particlePaint = Paint()
      ..color = darkTeal.withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;

    final Paint glowPaint = Paint()..style = PaintingStyle.fill;

    final double glowX = size.width * (0.15 + 0.70 * _wave(progress));
    final double glowY = size.height * (0.15 + 0.65 * _wave(progress + 0.27));

    glowPaint.color = primaryTeal.withValues(alpha: 0.025);

    canvas.drawCircle(
      Offset(glowX, glowY),
      math.min(size.width, size.height) * 0.24,
      glowPaint,
    );

    final List<_FloatingPaw> paws = [
      _FloatingPaw(0.10, 0.17, 31, 0.00),
      _FloatingPaw(0.84, 0.14, 25, 0.18),
      _FloatingPaw(0.25, 0.46, 20, 0.34),
      _FloatingPaw(0.73, 0.52, 34, 0.51),
      _FloatingPaw(0.12, 0.76, 25, 0.66),
      _FloatingPaw(0.88, 0.79, 19, 0.82),
      _FloatingPaw(0.49, 0.90, 23, 0.42),
    ];

    for (final _FloatingPaw paw in paws) {
      final double wave = _wave(progress + paw.phase);

      final double x = size.width * paw.x +
          math.sin((progress + paw.phase) * math.pi * 2) * 12;

      final double y = size.height * paw.y +
          math.sin((progress + paw.phase) * math.pi * 2) * 16;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(
        math.sin((progress + paw.phase) * math.pi * 2) * 0.10,
      );

      pawPaint.color = primaryTeal.withValues(
        alpha: 0.018 + (wave * 0.025),
      );

      _drawPaw(canvas, pawPaint, paw.size);
      canvas.restore();
    }

    final List<_FloatingParticle> particles = [
      _FloatingParticle(0.18, 0.28, 3.0, 0.05),
      _FloatingParticle(0.42, 0.18, 2.5, 0.22),
      _FloatingParticle(0.67, 0.30, 2.2, 0.37),
      _FloatingParticle(0.91, 0.38, 2.7, 0.51),
      _FloatingParticle(0.33, 0.63, 2.4, 0.66),
      _FloatingParticle(0.61, 0.73, 2.8, 0.79),
      _FloatingParticle(0.81, 0.91, 2.0, 0.91),
      _FloatingParticle(0.07, 0.55, 2.5, 0.13),
    ];

    for (final _FloatingParticle particle in particles) {
      final double wave = _wave(progress + particle.phase);

      final double x = size.width * particle.x +
          math.sin((progress + particle.phase) * math.pi * 2) * 8;

      final double y = size.height * particle.y - (wave * 18);

      particlePaint.color = darkTeal.withValues(
        alpha: 0.018 + (wave * 0.035),
      );

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        particlePaint,
      );
    }
  }

  double _wave(double value) {
    return (math.sin(value * math.pi * 2) + 1) / 2;
  }

  void _drawPaw(Canvas canvas, Paint paint, double size) {
    final double toeRadius = size * 0.15;

    canvas.drawCircle(
      Offset(-size * 0.28, -size * 0.22),
      toeRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(-size * 0.06, -size * 0.39),
      toeRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(size * 0.19, -size * 0.39),
      toeRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(size * 0.39, -size * 0.19),
      toeRadius,
      paint,
    );

    final Path pad = Path();

    pad.moveTo(-size * 0.34, size * 0.04);

    pad.cubicTo(
      -size * 0.34,
      -size * 0.08,
      -size * 0.22,
      -size * 0.16,
      -size * 0.06,
      -size * 0.16,
    );

    pad.cubicTo(
      size * 0.10,
      -size * 0.16,
      size * 0.34,
      -size * 0.07,
      size * 0.34,
      size * 0.10,
    );

    pad.cubicTo(
      size * 0.34,
      size * 0.31,
      size * 0.17,
      size * 0.43,
      0,
      size * 0.43,
    );

    pad.cubicTo(
      -size * 0.18,
      size * 0.43,
      -size * 0.34,
      size * 0.30,
      -size * 0.34,
      size * 0.04,
    );

    pad.close();
    canvas.drawPath(pad, paint);
  }

  @override
  bool shouldRepaint(
    covariant _PawLinkBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}

class _FloatingPaw {
  final double x;
  final double y;
  final double size;
  final double phase;

  const _FloatingPaw(
    this.x,
    this.y,
    this.size,
    this.phase,
  );
}

class _FloatingParticle {
  final double x;
  final double y;
  final double size;
  final double phase;

  const _FloatingParticle(
    this.x,
    this.y,
    this.size,
    this.phase,
  );
}
