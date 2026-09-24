import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pawlink/screens/auth/login_page.dart';
import 'package:pawlink/screens/auth/register_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // ============================================================
  // PAWLINK COLORS
  // ============================================================

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);

  static const Color alertRed = Color(0xFFDC2626);
  static const Color lightRed = Color(0xFFFEECEC);

  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color cardBackground = Color(0xFFFFFEFA);

  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE8E3D9);

  // ============================================================
  // SCROLL + KEYBOARD
  // ============================================================

  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();

  // ============================================================
  // INIT / DISPOSE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // KEYBOARD SCROLLING
  // ============================================================

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (!_scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    const double scrollAmount = 120;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _scrollController.animateTo(
        (_scrollController.offset + scrollAmount).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _scrollController.animateTo(
        (_scrollController.offset - scrollAmount).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _scrollController.animateTo(
        (_scrollController.offset + MediaQuery.of(context).size.height * 0.8)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _scrollController.animateTo(
        (_scrollController.offset - MediaQuery.of(context).size.height * 0.8)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

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
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildNavigation(context),
                  _buildHeroSection(context),
                  _buildAboutSection(context),
                  _buildPurposeSection(),
                  _buildHowItWorks(),
                  _buildFeatures(),
                  _buildLostPetSection(),
                  _buildCommunitySection(),
                  _buildGetStarted(context),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESPONSIVE CONTENT WIDTH
  // ============================================================

  Widget _content({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 24),
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1150),
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  // ============================================================
  // NAVIGATION BAR
  // ============================================================

  Widget _buildNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: warmBackground,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: _content(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;

            return Row(
              children: [
                // LOGO
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.pets, color: Colors.white, size: 25),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Pet & Stray Management',
                      style: TextStyle(color: grayText, fontSize: 10),
                    ),
                  ],
                ),

                const Spacer(),

                if (!isMobile) ...[
                  TextButton(
                    onPressed: () {
                      _scrollToSection(_aboutKey);
                    },
                    child: const Text(
                      'About',
                      style: TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      _scrollToSection(_howItWorksKey);
                    },
                    child: const Text(
                      'How It Works',
                      style: TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      _scrollToSection(_featuresKey);
                    },
                    child: const Text(
                      'Features',
                      style: TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
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
                    side: const BorderSide(color: primaryTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),

                if (!isMobile) ...[
                  const SizedBox(width: 10),

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
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HERO SECTION
  // ============================================================

  Widget _buildHeroSection(BuildContext context) {
    return _content(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 80),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

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
              Expanded(flex: 6, child: _heroText(context)),
              const SizedBox(width: 50),
              Expanded(flex: 4, child: _heroVisual()),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waving_hand_outlined, color: primaryTeal, size: 17),
              SizedBox(width: 7),
              Text(
                'Kumusta, ka-PawLink!',
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'A community that\nlooks out for every paw.',
          style: TextStyle(
            color: darkText,
            fontSize: 48,
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'PawLink is a community platform that connects '
          'pet owners, residents, and barangays to help '
          'manage, report, locate, and reunite lost and '
          'found pets.',
          style: TextStyle(color: grayText, fontSize: 17, height: 1.6),
        ),

        const SizedBox(height: 28),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            OutlinedButton(
              onPressed: () {
                _showLearnMore(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryTeal,
                side: const BorderSide(color: primaryTeal),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Learn More'),
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
    return Container(
      constraints: const BoxConstraints(minHeight: 350),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 25,
            right: 25,
            child: _circle(80, Colors.white.withAlpha(100)),
          ),

          Positioned(
            bottom: 30,
            left: 25,
            child: _circle(55, Colors.white.withAlpha(100)),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.pets, color: primaryTeal, size: 70),
              ),

              const SizedBox(height: 20),

              const Text(
                'Every pet matters.',
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Every community can help.',
                style: TextStyle(color: grayText, fontSize: 14),
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
  // ABOUT SECTION
  // ============================================================

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      key: _aboutKey,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 75),
      child: _content(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 750;

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _aboutTitle(),
                  const SizedBox(height: 30),
                  _aboutCard(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _aboutTitle()),
                const SizedBox(width: 60),
                Expanded(child: _aboutCard()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _aboutTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ABOUT PAWLINK'),
        const SizedBox(height: 12),
        const Text(
          'What is PawLink?',
          style: TextStyle(
            color: darkText,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'A digital community for responsible pet '
          'ownership and better stray animal management.',
          style: TextStyle(color: grayText, fontSize: 16, height: 1.6),
        ),
      ],
    );
  }

  Widget _aboutCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: warmBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Built for the community',
            style: TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 12),

          Text(
            'PawLink provides one place where pet owners '
            'and community members can share information '
            'about lost, found, and stray pets.',
            style: TextStyle(color: grayText, fontSize: 14, height: 1.6),
          ),

          SizedBox(height: 15),

          Text(
            'From an Aspin or Puspin to any beloved '
            'companion, the goal is simple: make it easier '
            'for people to help pets and their owners.',
            style: TextStyle(color: grayText, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PURPOSE SECTION
  // ============================================================

  Widget _buildPurposeSection() {
    return _content(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
      child: Column(
        children: [
          _sectionLabel('WHAT IS IT FOR?'),

          const SizedBox(height: 10),

          const Text(
            'Helping people help pets.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          const SizedBox(
            width: 700,
            child: Text(
              'PawLink makes it easier for the community to '
              'respond when a pet is lost, found, or needs help.',
              textAlign: TextAlign.center,
              style: TextStyle(color: grayText, fontSize: 15, height: 1.6),
            ),
          ),

          const SizedBox(height: 35),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 650 ? 1 : 3;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: columns == 1 ? 4.2 : 1.05,
                children: [
                  _purposeCard(
                    icon: Icons.pets,
                    title: 'Pet Management',
                    description:
                        'Register and manage important pet information.',
                  ),
                  _purposeCard(
                    icon: Icons.location_on_outlined,
                    title: 'Lost & Found',
                    description:
                        'Report pets and share their current location.',
                  ),
                  _purposeCard(
                    icon: Icons.account_balance_outlined,
                    title: 'Barangay Support',
                    description: 'Connect community reports with the barangay.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _purposeCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryTeal, size: 23),
          ),

          const SizedBox(width: 14),

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

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
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

  // ============================================================
  // HOW IT WORKS
  // ============================================================

  Widget _buildHowItWorks() {
    return Container(
      key: _howItWorksKey,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 75),
      child: _content(
        child: Column(
          children: [
            _sectionLabel('HOW IT WORKS'),

            const SizedBox(height: 12),

            const Text(
              'Simple steps. Real community help.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;

                if (isMobile) {
                  return Column(
                    children: [
                      _step(
                        '01',
                        Icons.person_add_alt_1,
                        'Create an account',
                        'Join PawLink and set up your profile.',
                      ),
                      _step(
                        '02',
                        Icons.pets,
                        'Register your pet',
                        'Add your pet information and photo.',
                      ),
                      _step(
                        '03',
                        Icons.qr_code_2,
                        'Get a QR code',
                        'Generate a unique QR code for your pet.',
                      ),
                      _step(
                        '04',
                        Icons.location_on_outlined,
                        'Report & reconnect',
                        'Finders can submit a location or report.',
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _step(
                        '01',
                        Icons.person_add_alt_1,
                        'Create an account',
                        'Join PawLink and set up your profile.',
                      ),
                    ),
                    Expanded(
                      child: _step(
                        '02',
                        Icons.pets,
                        'Register your pet',
                        'Add your pet information and photo.',
                      ),
                    ),
                    Expanded(
                      child: _step(
                        '03',
                        Icons.qr_code_2,
                        'Get a QR code',
                        'Generate a unique QR code for your pet.',
                      ),
                    ),
                    Expanded(
                      child: _step(
                        '04',
                        Icons.location_on_outlined,
                        'Report & reconnect',
                        'Finders can submit a location or report.',
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

  Widget _step(String number, IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: warmBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Icon(icon, color: primaryTeal, size: 25),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            description,
            style: const TextStyle(color: grayText, fontSize: 13, height: 1.5),
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
      child: _content(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
        child: Column(
          children: [
            _sectionLabel('PAWLINK FEATURES'),

            const SizedBox(height: 12),

            const Text(
              'One platform for the community.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkText,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 600 ? 1 : 3;

                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: columns == 1 ? 3.2 : 1.15,
                  children: [
                    _feature(
                      Icons.qr_code_2,
                      'Instant QR Code Pet ID',
                      'Every registered pet can have a unique QR code linked to its public pet page.',
                    ),
                    _feature(
                      Icons.group_outlined,
                      'Joint Accounts for Multiple',
                      'Multiple owners can be connected to the same registered pet.',
                    ),
                    _feature(
                      Icons.location_on_outlined,
                      'Location Reports',
                      'Share where a lost, found, or sighted pet was seen.',
                    ),
                    _feature(
                      Icons.notifications_none,
                      'Notifications',
                      'Keep owners informed when there is a report about their pet.',
                    ),
                    _feature(
                      Icons.account_balance_outlined,
                      'Barangay Reports',
                      'Provide a way for the community to report concerns to the barangay.',
                    ),
                    _feature(
                      Icons.favorite_border,
                      'Community Help',
                      'Encourage residents to work together to help animals in need.',
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

  Widget _feature(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryTeal, size: 23),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            style: const TextStyle(color: grayText, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOST PET / EMERGENCY
  // ============================================================

  Widget _buildLostPetSection() {
    return Container(
      width: double.infinity,
      color: lightRed,
      padding: const EdgeInsets.symmetric(vertical: 65),
      child: _content(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 750;

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lostText(),
                  const SizedBox(height: 25),
                  _lostAction(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 7, child: _lostText()),
                const SizedBox(width: 50),
                Expanded(flex: 3, child: _lostAction()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _lostText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: alertRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'LOST OR STRAY PET?',
              style: TextStyle(
                color: alertRed,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        const Text(
          'The community can help.',
          style: TextStyle(
            color: Color(0xFF7F1D1D),
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'If you find or see a lost pet, you can report '
          'its location through PawLink. If the animal '
          'appears aggressive or unsafe to approach, '
          'do not put yourself at risk. Submit a report '
          'instead and let the appropriate people respond.',
          style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _lostAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5CACA)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_outlined, color: alertRed, size: 28),

          SizedBox(height: 12),

          Text(
            'Barangay Assistance',
            style: TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 7),

          Text(
            'PawLink can provide a place for community '
            'reports and barangay contact information, '
            'including the appropriate hotline.',
            style: TextStyle(color: grayText, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMUNITY SECTION
  // ============================================================

  Widget _buildCommunitySection() {
    return _content(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Column(
        children: [
          _sectionLabel('FOR OUR COMMUNITY'),

          const SizedBox(height: 12),

          const Text(
            'For pet owners and\ncommunity members.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 34,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 35),

          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;

              if (isMobile) {
                return Column(
                  children: [
                    _communityCard(
                      icon: Icons.person_outline,
                      title: 'Pet Owners',
                      text: 'Register your pets, manage their information, receive reports, and connect with joint owners.',
                    ),
                    const SizedBox(height: 15),
                    _communityCard(
                      icon: Icons.people_outline,
                      title: 'Residents',
                      text: 'Help report lost, found, or stray pets and share useful location information.',
                    ),
                    const SizedBox(height: 15),
                    _communityCard(
                      icon: Icons.account_balance_outlined,
                      title: 'Barangay',
                      text: 'Receive appropriate community reports and provide local assistance when needed.',
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _communityCard(
                      icon: Icons.person_outline,
                      title: 'Pet Owners',
                      text: 'Register your pets, manage their information, receive reports, and connect with joint owners.',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _communityCard(
                      icon: Icons.people_outline,
                      title: 'Residents',
                      text: 'Help report lost, found, or stray pets and share useful location information.',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _communityCard(
                      icon: Icons.account_balance_outlined,
                      title: 'Barangay',
                      text: 'Receive appropriate community reports and provide local assistance when needed.',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _communityCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryTeal, size: 30),

          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            text,
            style: const TextStyle(color: grayText, fontSize: 13, height: 1.55),
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
      color: primaryTeal,
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 24),
      child: _content(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 32),
            ),

            const SizedBox(height: 20),

            const Text(
              'Be part of PawLink.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Together, we can help protect pets, '
              'support responsible ownership, and '
              'help lost animals find their way home.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD7F5F1),
                fontSize: 15,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 25),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF103B38),
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 24),
      child: _content(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, color: Colors.white, size: 25),
                const SizedBox(width: 8),
                const Text(
                  'PawLink',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'A Community for Pet and Stray Management',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB9D9D5), fontSize: 12),
            ),

            const SizedBox(height: 18),

            const Divider(color: Color(0xFF3D6663)),

            const SizedBox(height: 15),

            const Text(
              'Made for the community, one paw at a time. 🐾',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB9D9D5), fontSize: 11),
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
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  // ============================================================
  // LEARN MORE DIALOG
  // ============================================================

  void _showLearnMore(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: warmBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.pets, color: primaryTeal),
              SizedBox(width: 10),
              Text(
                'About PawLink',
                style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: const Text(
            'PawLink is designed to connect pet owners, '
            'residents, and barangays in managing lost, '
            'found, and stray pets. It provides tools for '
            'pet registration, QR identification, reports, '
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
                  fontWeight: FontWeight.w700,
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
    final BuildContext? targetContext = key.currentContext;

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
