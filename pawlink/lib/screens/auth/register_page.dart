import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_page.dart';
import '../landing/landing_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // COLORS

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color softerTeal = Color(0xFFF0F8F6);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color warmBackground = Color(0xFFF7F1E8);
  static const Color cream = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  // FONT SIZES
  // Slightly larger text improves readability on both phones and laptops.

  static const double bodyFontSize = 15;
  static const double labelFontSize = 15;
  static const double inputFontSize = 15;
  static const double hintFontSize = 14;
  static const double smallFontSize = 13;

  // CONTROLLERS

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  // FIREBASE

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // STATE

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToGuidelines = false;

  // LANDING PAGE NAVIGATION

  void _goToLandingPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LandingPage(),
      ),
      (route) => false,
    );
  }

  // INIT

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  // DISPOSE

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // KEYBOARD SCROLL

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }

    if (!_scrollController.hasClients) {
      return false;
    }

    const double scrollAmount = 120;
    double target;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      target = (_scrollController.offset + scrollAmount)
          .clamp(0.0, _scrollController.position.maxScrollExtent)
          .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      target = (_scrollController.offset - scrollAmount)
          .clamp(0.0, _scrollController.position.maxScrollExtent)
          .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      target =
          (_scrollController.offset + MediaQuery.of(context).size.height * 0.8)
              .clamp(0.0, _scrollController.position.maxScrollExtent)
              .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      target =
          (_scrollController.offset - MediaQuery.of(context).size.height * 0.8)
              .clamp(0.0, _scrollController.position.maxScrollExtent)
              .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      target = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      target = _scrollController.position.maxScrollExtent;
    } else {
      return false;
    }

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    return true;
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: SafeArea(
        child: Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            final handled = _handleKeyEvent(event);
            return handled ? KeyEventResult.handled : KeyEventResult.ignored;
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1000) {
                return _buildDesktopLayout();
              }
              return _buildMobileLayout();
            },
          ),
        ),
      ),
    );
  }

  // BACK BUTTON

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: _goToLandingPage,
      icon: const Icon(
        Icons.arrow_back_rounded,
        size: 20,
      ),
      label: const Text('Back to Home Page'),
      style: TextButton.styleFrom(
        foregroundColor: primaryTeal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // DESKTOP

  Widget _buildDesktopLayout() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 11,
                  child: _buildCommunitySide(),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 10,
                  child: _buildDesktopFormArea(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DESKTOP FORM AREA

  Widget _buildDesktopFormArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        const SizedBox(height: 12),
        _buildFormCard(isDesktop: true),
      ],
    );
  }

  // MOBILE

  Widget _buildMobileLayout() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _buildBackButton(),
            ),
            const SizedBox(height: 14),
            _buildMobileHeader(),
            const SizedBox(height: 20),
            _buildFormCard(isDesktop: false),
          ],
        ),
      ),
    );
  }

  // COMMUNITY SIDE

  Widget _buildCommunitySide() {
    return Container(
      constraints: const BoxConstraints(minHeight: 690),
      decoration: BoxDecoration(
        color: darkTeal,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -80,
            child: _clayCircle(
              size: 220,
              color: primaryTeal.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -80,
            child: _clayCircle(
              size: 200,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            right: 45,
            bottom: 42,
            child: Transform.rotate(
              angle: -0.08,
              child: _smallClayTag(),
            ),
          ),
          Positioned(
            left: 42,
            bottom: 38,
            child: _pawBubble(),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandMark(),
                const SizedBox(height: 52),
                const Text(
                  'A safer place\nfor every paw.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create your PawLink account and become part of a community that helps owners, residents, and the barangay keep pets safe.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 42),
                _buildCommunityCard(
                  icon: Icons.qr_code_2_rounded,
                  number: '01',
                  title: 'One profile, one QR',
                  description:
                      'Give your registered pet a digital identity that can be reached when needed.',
                ),
                const SizedBox(height: 14),
                _buildCommunityCard(
                  icon: Icons.people_alt_outlined,
                  number: '02',
                  title: 'Community-powered',
                  description:
                      'Owners and residents can work together when a pet goes missing or is found.',
                ),
                const SizedBox(height: 14),
                _buildCommunityCard(
                  icon: Icons.shield_outlined,
                  number: '03',
                  title: 'Safety comes first',
                  description:
                      'Unsafe or aggressive animals can be reported without requiring anyone to approach them.',
                ),
                const SizedBox(height: 45),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Community Pet & Stray Management',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CLICKABLE BRAND MARK

  Widget _buildBrandMark() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _goToLandingPage,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pets,
                  color: primaryTeal,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'PawLink',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // COMMUNITY CARD

  Widget _buildCommunityCard({
    required IconData icon,
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CLAY CIRCLE

  Widget _clayCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // SMALL CLAY TAG

  Widget _smallClayTag() {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_2,
                color: primaryTeal,
                size: 28,
              ),
              const SizedBox(width: 7),
              const Icon(
                Icons.pets,
                color: alertRed,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'PET ID',
            style: TextStyle(
              color: darkText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // PAW BUBBLE

  Widget _pawBubble() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.pets,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // MOBILE HEADER

  Widget _buildMobileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: darkTeal,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.13),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _goToLandingPage,
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: primaryTeal,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'PawLink',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A community for every paw.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORM CARD

  Widget _buildFormCard({required bool isDesktop}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 34 : 22,
        isDesktop ? 36 : 28,
        isDesktop ? 34 : 22,
        isDesktop ? 32 : 26,
      ),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeading(isDesktop: isDesktop),
          const SizedBox(height: 28),
          _buildLabel('Full Name'),
          const SizedBox(height: 9),
          TextField(
            controller: nameController,
            style: const TextStyle(
              color: darkText,
              fontSize: inputFontSize,
            ),
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'Enter your full name',
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Email Address'),
          const SizedBox(height: 9),
          TextField(
            controller: emailController,
            style: const TextStyle(
              color: darkText,
              fontSize: inputFontSize,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'Enter your email address',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Password'),
          const SizedBox(height: 9),
          TextField(
            controller: passwordController,
            style: const TextStyle(
              color: darkText,
              fontSize: inputFontSize,
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'Create a password',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: grayText,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Confirm Password'),
          const SizedBox(height: 9),
          TextField(
            controller: confirmPasswordController,
            style: const TextStyle(
              color: darkText,
              fontSize: inputFontSize,
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _register(),
            decoration: _inputDecoration(
              hintText: 'Re-enter your password',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                tooltip:
                    _obscureConfirmPassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: grayText,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildPasswordHint(),
          const SizedBox(height: 18),
          _buildAgreement(),
          const SizedBox(height: 24),
          _buildRegisterButton(),
          const SizedBox(height: 22),
          _buildLoginLink(),
          const SizedBox(height: 18),
          _buildFirebaseNote(),
        ],
      ),
    );
  }

  // FORM HEADING

  Widget _buildFormHeading({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'JOIN THE COMMUNITY',
            style: TextStyle(
              color: darkTeal,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Create your account',
          style: TextStyle(
            color: darkText,
            fontSize: isDesktop ? 32 : 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start connecting your pets to a safer community.',
          style: TextStyle(
            color: grayText,
            fontSize: bodyFontSize,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // PASSWORD HINT

  Widget _buildPasswordHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: softerTeal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: darkTeal,
            size: 19,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Use at least 6 characters, one uppercase letter, and one special character.',
              style: TextStyle(
                color: grayText,
                fontSize: smallFontSize,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // REGISTER BUTTON

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryTeal.withValues(alpha: 0.55),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 9),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  // LOGIN LINK

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Already have an account?',
            style: TextStyle(
              color: grayText,
              fontSize: bodyFontSize,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryTeal,
              padding: const EdgeInsets.only(left: 7),
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Log in',
              style: TextStyle(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIREBASE NOTE

  Widget _buildFirebaseNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: darkTeal,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Your account is secured by Firebase Authentication.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkTeal.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LABEL

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: darkText,
        fontSize: labelFontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // INPUT DECORATION

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF7D8989),
        fontSize: hintFontSize,
      ),
      prefixIcon: Icon(
        icon,
        color: grayText,
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryTeal,
          width: 1.5,
        ),
      ),
    );
  }

  // AGREEMENT

  Widget _buildAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Checkbox(
            value: _agreedToGuidelines,
            activeColor: primaryTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _agreedToGuidelines = value ?? false;
                    });
                  },
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading
                ? null
                : () {
                    setState(() {
                      _agreedToGuidelines = !_agreedToGuidelines;
                    });
                  },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: grayText,
                  fontSize: 13,
                  height: 1.55,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: _showCommunityGuidelines,
                      child: const Text(
                        'Community Guidelines',
                        style: TextStyle(
                          color: darkTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' and consent to sharing pet contact information when a QR code is scanned.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // COMMUNITY GUIDELINES

  void _showCommunityGuidelines() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Community Guidelines',
            style: TextStyle(
              color: darkText,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'PawLink is a community platform created to help pet owners, residents, and the barangay work together to keep pets safe.\n\n'
              'By using PawLink, please:\n\n'
              '• Provide accurate information about yourself and your pets.\n\n'
              '• Use pet information only for responsible contact and reunification purposes.\n\n'
              '• Do not misuse another person’s contact information.\n\n'
              '• Submit truthful lost, found, or stray pet reports.\n\n'
              '• Respect the privacy and safety of other community members.\n\n'
              '• Do not approach aggressive or dangerous animals. Contact the appropriate barangay personnel when necessary.\n\n'
              'When a pet QR code is scanned, limited contact information may be displayed to help reunite the pet with its owner.',
              style: TextStyle(
                color: grayText,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: primaryTeal,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // FIREBASE REGISTER

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_agreedToGuidelines) {
      _showMessage(
        'Please agree to the Community Guidelines first.',
        isError: true,
      );
      return;
    }

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage(
        'Please complete all required fields.',
        isError: true,
      );
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (!email.contains('@')) {
      _showMessage(
        'Please enter a valid email address.',
        isError: true,
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters.',
        isError: true,
      );
      return;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);

    if (!hasUppercase) {
      _showMessage(
        'Password must contain at least one uppercase letter.',
        isError: true,
      );
      return;
    }

    final hasSpecialCharacter = RegExp(
      r"""[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];']""",
    ).hasMatch(password);

    if (!hasSpecialCharacter) {
      _showMessage(
        'Password must contain at least one special character.',
        isError: true,
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Account created successfully!');

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password authentication is not enabled in Firebase.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Registration failed. Please try again.';
      }

      _showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
        isError: true,
      );
    }
  }

  // MESSAGE

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: isError ? alertRed : primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
