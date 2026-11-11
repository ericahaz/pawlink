import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pawlink/screens/auth/login_page.dart';
import 'package:pawlink/screens/auth/register_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color deepTeal = Color(0xFF103B38);

  static const Color lightTeal = Color(0xFFE5F3EF);
  static const Color warmOrange = Color(0xFFFF9F43);

  static const Color alertRed = Color(0xFFDC2626);
  static const Color lightRed = Color(0xFFFDECEC);
  static const Color darkRed = Color(0xFF7F1D1D);

  static const Color warmBackground = Color(0xFFF7F1E8);
  static const Color cream = Color(0xFFFFFBF5);
  static const Color white = Color(0xFFFFFEFC);

  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color softGray = Color(0xFF929C9A);

  // ============================================================
  // SCROLL
  // ============================================================

  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();

  // ============================================================
  // LIVE BACKGROUND ANIMATION
  // ============================================================

  late final AnimationController _backgroundAnimationController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // KEYBOARD SCROLL
  // ============================================================

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (!_scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    const double amount = 120;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _scrollBy(amount);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _scrollBy(-amount);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _scrollBy(MediaQuery.of(context).size.height * 0.8);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _scrollBy(-MediaQuery.of(context).size.height * 0.8);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.home) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.end) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _scrollBy(double amount) {
    final target = (_scrollController.offset + amount)
        .clamp(0.0, _scrollController.position.maxScrollExtent)
        .toDouble();

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: SafeArea(
        child: Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Stack(
            children: [
              _buildLiveBackground(),
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildNavigation(context),

                      // HERO
                      _buildHeroSection(context),

                      // Soft transition into cream section.
                      const _WaveDivider(
                        topColor: warmBackground,
                        bottomColor: cream,
                        height: 58,
                        curveHeight: 22,
                      ),

                      _buildAboutSection(),

                      // Soft transition into warm section.
                      const _WaveDivider(
                        topColor: cream,
                        bottomColor: warmBackground,
                        height: 58,
                        curveHeight: 22,
                      ),

                      _buildHowItWorks(),

                      // Soft transition into cream section.
                      const _WaveDivider(
                        topColor: warmBackground,
                        bottomColor: cream,
                        height: 58,
                        curveHeight: 22,
                      ),

                      _buildFeatures(),

                      // Soft transition into safety section.
                      const _WaveDivider(
                        topColor: cream,
                        bottomColor: lightRed,
                        height: 58,
                        curveHeight: 20,
                      ),

                      _buildSafetySection(),

                      // Return from red to warm neutral.
                      const _WaveDivider(
                        topColor: lightRed,
                        bottomColor: warmBackground,
                        height: 58,
                        curveHeight: 20,
                      ),

                      _buildCommunitySection(),

                      // Deep teal CTA transition.
                      const _WaveDivider(
                        topColor: warmBackground,
                        bottomColor: deepTeal,
                        height: 58,
                        curveHeight: 18,
                      ),

                      _buildGetStarted(context),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LIVE PAWLINK BACKGROUND
  // ============================================================

  Widget _buildLiveBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _backgroundAnimationController,
          builder: (context, child) {
            return CustomPaint(
              painter: _PawLinkCommunityPainter(
                progress: _backgroundAnimationController.value,
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT WIDTH
  // ============================================================

  Widget _content({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24),
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  // ============================================================
  // CLAY CARD
  // ============================================================

  Widget _clayCard({
    required Widget child,
    Color color = white,
    double radius = 24,
    EdgeInsetsGeometry padding = const EdgeInsets.all(22),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.white, blurRadius: 0, offset: Offset(-4, -4)),
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(7, 9),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // PAWLINK BRAND LOGO — MATCHES THE HOME PAGE
  // ============================================================

  BoxDecoration _logoClayDecoration({double radius = 15}) {
    return BoxDecoration(
      color: lightTeal,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.80)),
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

  Widget _buildPawLinkLogo({bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: _logoClayDecoration(radius: compact ? 12 : 15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shield_rounded,
                color: warmOrange.withValues(alpha: 0.35),
                size: compact ? 26 : 32,
              ),
              const Positioned(
                bottom: 6,
                child: Icon(
                  Icons.pets_rounded,
                  color: primaryTeal,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Paw',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: primaryTeal,
                    letterSpacing: -0.4,
                  ),
                ),
                const Text(
                  'Link',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: warmOrange,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            const Text(
              'Community Pet Care',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: grayText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Widget _buildNavigation(BuildContext context) {
    return _content(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 760;

          return Row(
            children: [
<<<<<<< HEAD
              _buildPawLinkLogo(),
=======
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 10,
                      offset: Offset(3, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PawLink',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'PET & STRAY MANAGEMENT',
                    style: TextStyle(
                      color: softGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
>>>>>>> 5f587cf358ff8c32ababc4e61564081a4a544eb6
              const Spacer(),
              if (!isMobile) ...[
                _navButton('About', () => _scrollToSection(_aboutKey)),
                _navButton(
                  'How It Works',
                  () => _scrollToSection(_howItWorksKey),
                ),
                _navButton('Features', () => _scrollToSection(_featuresKey)),
                const SizedBox(width: 8),
              ],
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryTeal,
                  side: const BorderSide(color: primaryTeal, width: 1.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 9),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 19,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _navButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: darkText,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroSection(BuildContext context) {
    return _content(
      padding: const EdgeInsets.fromLTRB(24, 45, 24, 45),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 850;

          if (isMobile) {
            return Column(
              children: [
                _heroText(context),
                const SizedBox(height: 40),
                _heroVisual(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 55, child: _heroText(context)),
              const SizedBox(width: 45),
              Expanded(flex: 45, child: _heroVisual()),
            ],
          );
        },
      ),
    );
  }

  Widget _heroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 7,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waving_hand_rounded, color: primaryTeal, size: 16),
              SizedBox(width: 7),
              Text(
                'Kumusta, ka-PawLink!',
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 23),
        const Text(
          'A safer way to',
          style: TextStyle(
            color: darkText,
            fontSize: 46,
            height: 1.08,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const Text(
          'look out for every paw.',
          style: TextStyle(
            color: primaryTeal,
            fontSize: 46,
            height: 1.08,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'PawLink brings pet owners, residents, and barangays '
          'together in one place to register pets, share reports, '
          'and help lost animals find their way home.',
          style: TextStyle(color: grayText, fontSize: 18, height: 1.65),
        ),
        const SizedBox(height: 27),
        Wrap(
          spacing: 11,
          runSpacing: 11,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
              label: const Text(
                'Get Started',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                _showLearnMore(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: darkTeal,
                side: const BorderSide(color: Color(0xFF9BCBC5)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Learn More',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Row(
          children: [
            Icon(Icons.verified_rounded, color: primaryTeal, size: 18),
            SizedBox(width: 7),
            Text(
              'Built around local community support',
              style: TextStyle(
                color: grayText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // HERO VISUAL
  // ============================================================

  Widget _heroVisual() {
    return SizedBox(
      height: 455,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 22,
            right: 5,
            top: 25,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(55),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(65),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                    offset: Offset(-5, -5),
                  ),
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 25,
                    offset: Offset(8, 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 35,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryTeal.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 35,
            child: _circle(85, Colors.white.withValues(alpha: 0.55)),
          ),
          Positioned(
            bottom: 12,
            left: 2,
            child: _circle(60, Colors.white.withValues(alpha: 0.5)),
          ),
          Positioned(
            left: 40,
            top: 80,
            child: Transform.rotate(angle: -0.045, child: _petCard()),
          ),
          Positioned(
            right: 16,
            top: 155,
            child: Transform.rotate(angle: 0.06, child: _qrCard()),
          ),
          Positioned(left: 20, bottom: 35, child: _reportBadge()),
          Positioned(
            right: 8,
            bottom: 40,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryTeal,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 15,
                    offset: Offset(4, 7),
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _petCard() {
    return _clayCard(
      color: cream,
      radius: 25,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        width: 225,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: primaryTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 11),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PET PROFILE',
                      style: TextStyle(
                        color: softGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Max',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 17),
            Container(height: 1, color: const Color(0xFFE4E7E3)),
            const SizedBox(height: 13),
            const Row(
              children: [
                Icon(Icons.pets, color: primaryTeal, size: 14),
                SizedBox(width: 6),
                Text(
                  'Shih Tzu',
                  style: TextStyle(
                    color: grayText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.circle, color: primaryTeal, size: 8),
                SizedBox(width: 5),
                Text(
                  'Registered',
                  style: TextStyle(
                    color: primaryTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrCard() {
    return _clayCard(
      color: white,
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            width: 105,
            height: 105,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE2E7E4)),
            ),
            child: CustomPaint(
              painter: _FakeQrPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'SCAN TO IDENTIFY',
            style: TextStyle(
              color: grayText,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportBadge() {
    return _clayCard(
      color: white,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, color: alertRed, size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FOUND REPORT',
                style: TextStyle(
                  color: alertRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Location shared',
                style: TextStyle(
                  color: darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAboutSection() {
    return Container(
      key: _aboutKey,
      width: double.infinity,
      color: cream,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: _content(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _aboutIntro(),
                  const SizedBox(height: 35),
                  _aboutPanel(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 43, child: _aboutIntro()),
                const SizedBox(width: 60),
                Expanded(flex: 57, child: _aboutPanel()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _aboutIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHY PAWLINK'),
        const SizedBox(height: 13),
        const Text(
          'One place for\npet information\nand community help.',
          style: TextStyle(
            color: darkText,
            fontSize: 36,
            height: 1.12,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'PawLink gives the community a shared digital '
          'space for pet profiles, lost-and-found reports, '
          'and local assistance.',
          style: TextStyle(color: grayText, fontSize: 17, height: 1.65),
        ),
      ],
    );
  }

  Widget _aboutPanel() {
    return _clayCard(
      color: warmBackground,
      radius: 30,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          _aboutItem(
            Icons.badge_outlined,
            'Register',
            'Keep important pet details in one profile.',
          ),
          const SizedBox(height: 18),
          _aboutItem(
            Icons.qr_code_2_rounded,
            'Identify',
            'Give each registered pet a unique QR identity.',
          ),
          const SizedBox(height: 18),
          _aboutItem(
            Icons.share_location_rounded,
            'Reconnect',
            'Share reports and locations when help is needed.',
          ),
        ],
      ),
    );
  }

  Widget _aboutItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 49,
          height: 49,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 0,
                offset: Offset(-2, -2),
              ),
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 8,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: Center(child: Icon(icon, color: primaryTeal, size: 23)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: grayText,
                  fontSize: 17,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HOW IT WORKS
  // ============================================================

  Widget _buildHowItWorks() {
    return Container(
      key: _howItWorksKey,
      width: double.infinity,
      color: warmBackground,
      padding: const EdgeInsets.symmetric(vertical: 82),
      child: _content(
        child: Column(
          children: [
            _sectionLabel('HOW IT WORKS'),
            const SizedBox(height: 12),
            const Text(
              'From registration to reunion.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 37,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A simple flow designed around real community situations.',
              textAlign: TextAlign.center,
              style: TextStyle(color: grayText, fontSize: 16),
            ),
            const SizedBox(height: 42),
            LayoutBuilder(
              builder: (context, constraints) {
                final mobile = constraints.maxWidth < 720;

                final steps = [
                  _processStep(
                    '01',
                    Icons.person_add_alt_1_rounded,
                    'Join',
                    'Create your PawLink account.',
                  ),
                  _processStep(
                    '02',
                    Icons.pets_rounded,
                    'Register',
                    'Add your pet and important details.',
                  ),
                  _processStep(
                    '03',
                    Icons.qr_code_2_rounded,
                    'Identify',
                    'Use the pet QR profile when needed.',
                  ),
                  _processStep(
                    '04',
                    Icons.location_on_rounded,
                    'Reconnect',
                    'Send a report when a pet is found.',
                  ),
                ];

                if (mobile) {
                  return Column(
                    children: [
                      for (final step in steps) ...[
                        step,
                        const SizedBox(height: 14),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < steps.length; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == steps.length - 1 ? 0 : 12,
                          ),
                          child: steps[i],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _processStep(
    String number,
    IconData icon,
    String title,
    String description,
  ) {
    return _clayCard(
      color: cream,
      radius: 23,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, color: primaryTeal, size: 23),
            ],
          ),
          const SizedBox(height: 21),
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: grayText, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURES
  // ============================================================

  Widget _buildFeatures() {
    return Container(
      key: _featuresKey,
      width: double.infinity,
      color: cream,
      padding: const EdgeInsets.symmetric(vertical: 82),
      child: _content(
        child: Column(
          children: [
            _sectionLabel('WHAT YOU CAN DO'),
            const SizedBox(height: 12),
            const Text(
              'Useful tools, without the clutter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 37,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 42),
            LayoutBuilder(
              builder: (context, constraints) {
                final mobile = constraints.maxWidth < 750;

                if (mobile) {
                  return Column(
                    children: [
                      _largeFeature(
                        Icons.qr_code_2_rounded,
                        'Every pet gets an identity.',
                        'Registered pets can have a QR profile that helps a finder access useful information.',
                        lightTeal,
                      ),
                      const SizedBox(height: 14),
                      _largeFeature(
                        Icons.groups_rounded,
                        'More than one owner?',
                        'Joint ownership keeps multiple people connected to the same pet profile.',
                        const Color(0xFFF3EEDF),
                      ),
                      const SizedBox(height: 14),
                      _largeFeature(
                        Icons.notifications_active_outlined,
                        'Stay informed.',
                        'Owners can receive reports when a community member submits information about their pet.',
                        const Color(0xFFF1F4F1),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _largeFeature(
                            Icons.qr_code_2_rounded,
                            'Every pet gets an identity.',
                            'Registered pets can have a QR profile that helps a finder access useful information.',
                            lightTeal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 4,
                          child: _smallFeature(
                            Icons.groups_rounded,
                            'Joint ownership',
                            'Keep multiple owners connected to one pet profile.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _smallFeature(
                            Icons.location_on_rounded,
                            'Location reports',
                            'Share where a lost or found pet was seen.',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 6,
                          child: _largeFeature(
                            Icons.notifications_active_outlined,
                            'Stay informed.',
                            'Owners can receive reports when a community member submits information about their pet.',
                            const Color(0xFFF1F4F1),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _largeFeature(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return _clayCard(
      color: color,
      radius: 27,
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _featureIcon(icon),
          const SizedBox(height: 23),
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: grayText, fontSize: 17, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _smallFeature(IconData icon, String title, String description) {
    return _clayCard(
      color: warmBackground,
      radius: 27,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _featureIcon(icon),
          const SizedBox(height: 25),
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(color: grayText, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _featureIcon(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(color: Colors.white, blurRadius: 0, offset: Offset(-2, -2)),
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 9,
            offset: Offset(3, 4),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: primaryTeal, size: 25)),
    );
  }

  // ============================================================
  // SAFETY
  // ============================================================

  Widget _buildSafetySection() {
    return Container(
      width: double.infinity,
      color: lightRed,
      padding: const EdgeInsets.symmetric(vertical: 75),
      child: _content(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 800;

            if (mobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _safetyText(),
                  const SizedBox(height: 28),
                  _safetyCard(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 56, child: _safetyText()),
                const SizedBox(width: 55),
                Expanded(flex: 44, child: _safetyCard()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _safetyText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: alertRed,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x25000000),
                    blurRadius: 9,
                    offset: Offset(3, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'SAFETY FIRST',
              style: TextStyle(
                color: alertRed,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        const Text(
          'Not every pet\nshould be approached.',
          style: TextStyle(
            color: darkRed,
            fontSize: 34,
            height: 1.12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'If a lost or stray animal appears aggressive or '
          'unsafe, do not attempt to scan, catch, or approach '
          'the animal. Submit a report instead and share the '
          'location with the appropriate people.',
          style: TextStyle(color: darkRed, fontSize: 16, height: 1.65),
        ),
      ],
    );
  }

  Widget _safetyCard() {
    return _clayCard(
      color: white,
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: lightRed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.report_problem_outlined, color: alertRed),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'See a pet that needs help?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _safetyItem(
            '01',
            'Keep a safe distance',
            'Do not approach an aggressive animal.',
          ),
          _safetyItem(
            '02',
            'Report the situation',
            'Share the location and useful details.',
          ),
          _safetyItem(
            '03',
            'Contact the right people',
            'Use available owner or barangay contact information.',
          ),
        ],
      ),
    );
  }

  Widget _safetyItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: lightRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: alertRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: grayText,
                    fontSize: 16,
                    height: 1.4,
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
  // COMMUNITY
  // ============================================================

  Widget _buildCommunitySection() {
    return Container(
      width: double.infinity,
      color: warmBackground,
      padding: const EdgeInsets.symmetric(vertical: 82),
      child: _content(
        child: Column(
          children: [
            _sectionLabel('ONE COMMUNITY'),
            const SizedBox(height: 12),
            const Text(
              'Everyone has a role.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 37,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 13),
            const SizedBox(
              width: 650,
              child: Text(
                'PawLink is built around the people who care for, '
                'find, report, and help protect animals in the community.',
                textAlign: TextAlign.center,
                style: TextStyle(color: grayText, fontSize: 16, height: 1.55),
              ),
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                final mobile = constraints.maxWidth < 720;

                final cards = [
                  _roleCard(
                    Icons.person_outline_rounded,
                    'Pet Owners',
                    'MANAGE',
                    'Register pets, maintain their information, connect joint owners, and receive reports.',
                    lightTeal,
                  ),
                  _roleCard(
                    Icons.people_outline_rounded,
                    'Residents',
                    'HELP',
                    'Report lost, found, or stray pets and share useful location information.',
                    cream,
                  ),
                  _roleCard(
                    Icons.account_balance_outlined,
                    'Barangays',
                    'RESPOND',
                    'Provide local contact information and receive appropriate community reports.',
                    const Color(0xFFF1ECE2),
                  ),
                ];

                if (mobile) {
                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 14),
                      cards[1],
                      const SizedBox(height: 14),
                      cards[2],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 14),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 14),
                    Expanded(child: cards[2]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(
    IconData icon,
    String title,
    String label,
    String description,
    Color color,
  ) {
    return _clayCard(
      color: color,
      radius: 27,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Icon(icon, color: primaryTeal, size: 25)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: primaryTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(color: grayText, fontSize: 16, height: 1.55),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GET STARTED
  // ============================================================

  Widget _buildGetStarted(BuildContext context) {
    return Container(
      width: double.infinity,
      color: deepTeal,
      padding: const EdgeInsets.symmetric(vertical: 75, horizontal: 24),
      child: _content(
        child: _clayCard(
          color: primaryTeal,
          radius: 34,
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 38),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 700;

              if (mobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ctaIcon(),
                    const SizedBox(height: 20),
                    _ctaText(),
                    const SizedBox(height: 25),
                    _ctaButtons(context),
                  ],
                );
              }

              return Row(
                children: [
                  _ctaIcon(),
                  const SizedBox(width: 25),
                  Expanded(child: _ctaText(left: true)),
                  const SizedBox(width: 25),
                  _ctaButtons(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _ctaIcon() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.pets_rounded, color: Colors.white, size: 34),
      ),
    );
  }

  Widget _ctaText({bool left = false}) {
    return Column(
      crossAxisAlignment:
          left ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Be part of PawLink.',
          textAlign: left ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'One small action can make it easier for a pet '
          'to get the help it needs.',
          textAlign: left ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD7F5F1),
            fontSize: 17,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _ctaButtons(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryTeal,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: deepTeal,
      padding: const EdgeInsets.fromLTRB(24, 5, 24, 35),
      child: _content(
        child: Column(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Center(
                child: Icon(Icons.pets_rounded, color: Colors.white, size: 27),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'PawLink',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'A Community for Pet and Stray Management',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB9D9D5), fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: const Color(0xFF315D59)),
            const SizedBox(height: 15),
            const Text(
              'Made for the community, one paw at a time. 🐾',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB9D9D5), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: primaryTeal,
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    );
  }

  // ============================================================
  // LEARN MORE
  // ============================================================

  void _showLearnMore(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.pets_rounded, color: primaryTeal),
              SizedBox(width: 10),
              Text(
                'About PawLink',
                style: TextStyle(color: darkText, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: const Text(
            'PawLink connects pet owners, residents, and '
            'barangays in managing lost, found, and stray '
            'pets. It provides tools for pet registration, '
            'QR identification, joint ownership, reports, '
            'location sharing, and community assistance.',
            style: TextStyle(color: grayText, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SECTION SCROLLING
  // ============================================================

  void _scrollToSection(GlobalKey key) {
    final targetContext = key.currentContext;

    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }
}

// ================================================================
// LIVE PAWLINK COMMUNITY BACKGROUND
//
// This is intentionally different from a generic particle
// animation.
//
// The background represents:
//
// PET OWNER
//     ↓
// COMMUNITY
//     ↓
// REPORT / LOCATION
//     ↓
// BARANGAY
//
// Small paw prints and connection nodes slowly move around the
// page while an occasional location pulse appears.
// ================================================================

class _PawLinkCommunityPainter extends CustomPainter {
  final double progress;

  _PawLinkCommunityPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final double angle = progress * math.pi * 2;

    // ----------------------------------------------------------
    // VERY SOFT LARGE ORGANIC GLOWS
    // ----------------------------------------------------------

    _drawGlow(
      canvas,
      center: Offset(
        size.width * 0.12 + math.sin(angle) * 22,
        size.height * 0.22 + math.cos(angle) * 16,
      ),
      radius: 110,
      opacity: 0.018,
    );

    _drawGlow(
      canvas,
      center: Offset(
        size.width * 0.87 + math.cos(angle * 0.8) * 25,
        size.height * 0.42 + math.sin(angle * 0.8) * 18,
      ),
      radius: 135,
      opacity: 0.015,
    );

    _drawGlow(
      canvas,
      center: Offset(
        size.width * 0.48 + math.sin(angle * 0.65) * 28,
        size.height * 0.80 + math.cos(angle * 0.65) * 18,
      ),
      radius: 120,
      opacity: 0.014,
    );

    // ----------------------------------------------------------
    // COMMUNITY CONNECTION NODES
    // ----------------------------------------------------------

    final Offset owner = Offset(
      size.width * 0.13 + math.sin(angle) * 10,
      size.height * 0.63 + math.cos(angle) * 7,
    );

    final Offset community = Offset(
      size.width * 0.49 + math.cos(angle * 0.7) * 14,
      size.height * 0.30 + math.sin(angle * 0.7) * 10,
    );

    final Offset barangay = Offset(
      size.width * 0.84 + math.sin(angle * 0.55) * 12,
      size.height * 0.69 + math.cos(angle * 0.55) * 9,
    );

    _drawConnection(canvas, owner, community);

    _drawConnection(canvas, community, barangay);

    _drawNode(canvas, owner, radius: 4.5, opacity: 0.075);

    _drawNode(canvas, community, radius: 5, opacity: 0.085);

    _drawNode(canvas, barangay, radius: 4.5, opacity: 0.075);

    // ----------------------------------------------------------
    // MOVING PAW TRAIL
    // ----------------------------------------------------------

    final List<_PawPoint> pawTrail = [
      _PawPoint(x: 0.16, y: 0.36, scale: 0.70, phase: 0.0),
      _PawPoint(x: 0.29, y: 0.53, scale: 0.52, phase: 0.18),
      _PawPoint(x: 0.42, y: 0.68, scale: 0.76, phase: 0.36),
      _PawPoint(x: 0.63, y: 0.48, scale: 0.56, phase: 0.55),
      _PawPoint(x: 0.76, y: 0.30, scale: 0.68, phase: 0.74),
      _PawPoint(x: 0.89, y: 0.57, scale: 0.48, phase: 0.91),
    ];

    for (final pawPoint in pawTrail) {
      final double localPhase = (progress + pawPoint.phase) % 1.0;

      final double movement = math.sin(localPhase * math.pi * 2);

      final double x = size.width * pawPoint.x + movement * 16;

      final double y =
          size.height * pawPoint.y + math.cos(localPhase * math.pi * 2) * 10;

      final double opacity = 0.012 + ((movement + 1) / 2) * 0.018;

      _drawPaw(
        canvas,
        Offset(x, y),
        pawPoint.scale,
        opacity,
        rotation: movement * 0.08,
      );
    }

    // ----------------------------------------------------------
    // LOCATION PULSE
    // ----------------------------------------------------------

    final double pulseProgress = (progress * 1.25) % 1.0;

    final Offset pulseCenter = Offset(size.width * 0.72, size.height * 0.78);

    _drawLocationPulse(canvas, pulseCenter, pulseProgress);
  }

  // ============================================================
  // GLOW
  // ============================================================

  void _drawGlow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double opacity,
  }) {
    final Paint paint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: opacity);

    canvas.drawCircle(center, radius, paint);
  }

  // ============================================================
  // CONNECTION
  // ============================================================

  void _drawConnection(Canvas canvas, Offset first, Offset second) {
    final Paint paint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: 0.022)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(first, second, paint);
  }

  // ============================================================
  // NODE
  // ============================================================

  void _drawNode(
    Canvas canvas,
    Offset center, {
    required double radius,
    required double opacity,
  }) {
    final Paint outerPaint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: opacity * 0.45);

    final Paint innerPaint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: opacity);

    canvas.drawCircle(center, radius * 2.3, outerPaint);

    canvas.drawCircle(center, radius, innerPaint);
  }

  // ============================================================
  // PAW
  // ============================================================

  void _drawPaw(
    Canvas canvas,
    Offset center,
    double scale,
    double opacity, {
    required double rotation,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final Paint paint = Paint()
      ..color = const Color(0xFF0F766E).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Main paw pad.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 25 * scale,
        height: 30 * scale,
      ),
      paint,
    );

    // Four toes.
    final List<Offset> toes = [
      Offset(-13 * scale, -14 * scale),
      Offset(-5 * scale, -20 * scale),
      Offset(5 * scale, -20 * scale),
      Offset(13 * scale, -14 * scale),
    ];

    for (final toe in toes) {
      canvas.drawCircle(toe, 4.7 * scale, paint);
    }

    canvas.restore();
  }

  // ============================================================
  // LOCATION PULSE
  // ============================================================

  void _drawLocationPulse(Canvas canvas, Offset center, double progress) {
    final double wave = math.sin(progress * math.pi);

    final double radius = 10 + (progress * 28);

    final Paint ringPaint = Paint()
      ..color =
          const Color(0xFFDC2626).withValues(alpha: 0.025 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, ringPaint);

    final Paint centerPaint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.035 + wave * 0.015);

    canvas.drawCircle(center, 4.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _PawLinkCommunityPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ================================================================
// PAW TRAIL DATA
// ================================================================

class _PawPoint {
  final double x;
  final double y;
  final double scale;
  final double phase;

  const _PawPoint({
    required this.x,
    required this.y,
    required this.scale,
    required this.phase,
  });
}

// ================================================================
// SOFT WAVY SECTION DIVIDER
// ================================================================

class _WaveDivider extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;
  final double height;
  final double curveHeight;

  const _WaveDivider({
    required this.topColor,
    required this.bottomColor,
    this.height = 58,
    this.curveHeight = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _WaveDividerPainter(
          topColor: topColor,
          bottomColor: bottomColor,
          curveHeight: curveHeight,
        ),
      ),
    );
  }
}

class _WaveDividerPainter extends CustomPainter {
  final Color topColor;
  final Color bottomColor;
  final double curveHeight;

  _WaveDividerPainter({
    required this.topColor,
    required this.bottomColor,
    required this.curveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint topPaint = Paint()
      ..color = topColor
      ..style = PaintingStyle.fill;

    final Paint bottomPaint = Paint()
      ..color = bottomColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bottomPaint);

    final Path path = Path();

    path.moveTo(0, 0);

    path.cubicTo(
      size.width * 0.16,
      curveHeight,
      size.width * 0.30,
      curveHeight,
      size.width * 0.45,
      curveHeight * 0.45,
    );

    path.cubicTo(
      size.width * 0.60,
      -curveHeight * 0.15,
      size.width * 0.77,
      -curveHeight * 0.15,
      size.width,
      curveHeight * 0.55,
    );

    path.lineTo(size.width, 0);

    path.close();

    canvas.drawPath(path, topPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveDividerPainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.bottomColor != bottomColor ||
        oldDelegate.curveHeight != curveHeight;
  }
}

// ================================================================
// DECORATIVE QR CODE
//
// Visual illustration only.
// This is NOT the actual QR code used by PawLink.
// ================================================================

class _FakeQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF243333)
      ..style = PaintingStyle.fill;

    final double cell = size.width / 21;

    void square(int x, int y, int width, int height) {
      canvas.drawRect(
        Rect.fromLTWH(x * cell, y * cell, width * cell, height * cell),
        paint,
      );
    }

    void finder(int x, int y) {
      square(x, y, 7, 7);

      final Paint innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH((x + 2) * cell, (y + 2) * cell, 3 * cell, 3 * cell),
        innerPaint,
      );

      square(x + 2, y + 2, 3, 3);
    }

    finder(0, 0);
    finder(14, 0);
    finder(0, 14);

    final List<List<int>> modules = [
      [8, 1],
      [10, 1],
      [12, 1],
      [8, 3],
      [9, 4],
      [11, 3],
      [12, 5],
      [8, 7],
      [10, 6],
      [12, 8],
      [14, 8],
      [16, 8],
      [18, 8],
      [7, 10],
      [9, 9],
      [11, 10],
      [13, 11],
      [15, 10],
      [17, 11],
      [19, 10],
      [8, 13],
      [10, 14],
      [12, 13],
      [14, 13],
      [16, 14],
      [18, 13],
      [20, 15],
      [7, 16],
      [9, 17],
      [11, 16],
      [13, 18],
      [15, 17],
      [17, 19],
      [19, 17],
      [8, 20],
      [10, 19],
      [12, 20],
    ];

    for (final List<int> module in modules) {
      square(module[0], module[1], 1, 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
