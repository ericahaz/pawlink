import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';
import '../home/home_page.dart';
import '../landing/landing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // PAWLINK COLORS

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color deepTeal = Color(0xFF103B38);

  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color softerTeal = Color(0xFFF0F8F6);

  static const Color alertRed = Color(0xFFDC2626);

  static const Color warmBackground = Color(0xFFF7F1E8);
  static const Color cream = Color(0xFFFFFBF5);

  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  // CONTROLLERS

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  // FIREBASE

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // STATE

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  // NAVIGATION

  void _goToLandingPage() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LandingPage(),
      ),
      (route) => false,
    );
  }

  void _goToHomePage() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
      ),
      (route) => false,
    );
  }

  // DISPOSE

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // KEYBOARD SCROLLING

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (!_scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    const double scrollAmount = 120;

    final position = _scrollController.position;
    double target;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      target = (_scrollController.offset + scrollAmount)
          .clamp(0.0, position.maxScrollExtent)
          .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      target = (_scrollController.offset - scrollAmount)
          .clamp(0.0, position.maxScrollExtent)
          .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      target =
          (_scrollController.offset + MediaQuery.of(context).size.height * 0.8)
              .clamp(0.0, position.maxScrollExtent)
              .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      target =
          (_scrollController.offset - MediaQuery.of(context).size.height * 0.8)
              .clamp(0.0, position.maxScrollExtent)
              .toDouble();
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      target = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      target = position.maxScrollExtent;
    } else {
      return KeyEventResult.ignored;
    }

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    return KeyEventResult.handled;
  }

  // BUILD
  //
  // No authStateChanges StreamBuilder here.
  // Successful login navigation is handled by _login().
  // This prevents the login page from redirecting twice.

  @override
  Widget build(BuildContext context) {
    return _buildLoginScreen();
  }

  Widget _buildLoginScreen() {
    return Scaffold(
      backgroundColor: warmBackground,
      body: SafeArea(
        child: Focus(
          focusNode: _keyboardFocusNode,
          onKeyEvent: _handleKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 950) {
                return _buildDesktopLayout();
              }

              return _buildMobileLayout();
            },
          ),
        ),
      ),
    );
  }

  // DESKTOP LAYOUT

  Widget _buildDesktopLayout() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: _buildDesktopShell(),
          ),
        ),
      ),
    );
  }

  // DESKTOP SHELL

  Widget _buildDesktopShell() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 35,
            offset: Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 11,
              child: _buildWelcomePanel(),
            ),
            Expanded(
              flex: 9,
              child: _buildDesktopFormArea(),
            ),
          ],
        ),
      ),
    );
  }

  // DESKTOP FORM AREA

  Widget _buildDesktopFormArea() {
    return Container(
      color: warmBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(),
              const SizedBox(height: 12),
              _buildLoginCard(),
            ],
          ),
        ),
      ),
    );
  }

  // MOBILE LAYOUT

  Widget _buildMobileLayout() {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _buildBackButton(),
            ),
            const SizedBox(height: 14),
            _buildMobileHeader(),
            const SizedBox(height: 24),
            _buildLoginCard(),
            const SizedBox(height: 20),
            _buildMobileSafetyNote(),
          ],
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
        size: 18,
      ),
      label: const Text('Back to Landing Page'),
      style: TextButton.styleFrom(
        foregroundColor: primaryTeal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // WELCOME PANEL

  Widget _buildWelcomePanel() {
    return Container(
      constraints: const BoxConstraints(minHeight: 720),
      decoration: const BoxDecoration(
        color: primaryTeal,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -85,
            right: -70,
            child: _decorativeCircle(
              size: 220,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _decorativeCircle(
              size: 210,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            top: 135,
            left: -45,
            child: _decorativeCircle(
              size: 100,
              color: Colors.white.withValues(alpha: 0.045),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(46),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandMark(darkBackground: true),
                const SizedBox(height: 42),
                _buildWelcomeCopy(),
                const SizedBox(height: 26),
                _buildWelcomeHighlights(),
                const SizedBox(height: 26),
                _buildCommunityMiniCard(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CLICKABLE BRAND MARK

  Widget _buildBrandMark({bool darkBackground = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _goToLandingPage,
        borderRadius: BorderRadius.circular(18),
        mouseCursor: SystemMouseCursors.click,
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
                  color: darkBackground ? Colors.white : primaryTeal,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pets,
                  color: darkBackground ? primaryTeal : Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PawLink',
                    style: TextStyle(
                      color: darkBackground ? Colors.white : primaryTeal,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'PET • COMMUNITY • CARE',
                    style: TextStyle(
                      color: darkBackground
                          ? Colors.white.withValues(alpha: 0.68)
                          : grayText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WELCOME COPY

  Widget _buildWelcomeCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.waving_hand_rounded,
                color: Colors.white,
                size: 15,
              ),
              SizedBox(width: 7),
              Text(
                'WELCOME BACK, KA-PAWLINK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Your pets,\nyour community,\nconnected.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            height: 1.03,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Manage pet profiles, stay updated on reports, '
          'and help keep pets safe around the barangay.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.80),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // WELCOME HIGHLIGHTS

  Widget _buildWelcomeHighlights() {
    return Column(
      children: [
        _highlightItem(
          icon: Icons.qr_code_2_rounded,
          title: 'Pet QR profiles',
          description: 'Keep your pet identity easy to access.',
        ),
        const SizedBox(height: 10),
        _highlightItem(
          icon: Icons.location_on_outlined,
          title: 'Lost & found reports',
          description: 'Stay connected when a pet needs help.',
        ),
        const SizedBox(height: 10),
        _highlightItem(
          icon: Icons.groups_outlined,
          title: 'Community support',
          description: 'Work together with residents and barangay.',
        ),
      ],
    );
  }

  Widget _highlightItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.085),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // COMMUNITY MINI CARD

  Widget _buildCommunityMiniCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: deepTeal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Built for the community',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Every report can help a pet get home safely.',
                  style: TextStyle(
                    color: Color(0xB8FFFFFF),
                    fontSize: 16,
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

  // LOGIN CARD

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width < 380 ? 20 : 28,
      ),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeading(),
          const SizedBox(height: 25),
          _buildLabel('Email address'),
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 17),
          _buildLabel('Password'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 10),
          _buildRememberMeRow(),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
              style: TextButton.styleFrom(
                foregroundColor: primaryTeal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLoginButton(),
          const SizedBox(height: 20),
          _buildCreateAccountRow(),
          const SizedBox(height: 18),
          _buildSecurityNote(),
        ],
      ),
    );
  }

  // REMEMBER ME

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: Checkbox(
            value: _rememberMe,
            activeColor: primaryTeal,
            checkColor: Colors.white,
            side: const BorderSide(
              color: borderColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
          ),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: _isLoading
              ? null
              : () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
          child: const Text(
            'Remember me',
            style: TextStyle(
              color: darkText,
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        if (kIsWeb)
          Tooltip(
            message: _rememberMe
                ? 'Stay signed in on this browser'
                : 'Sign out when the browser session ends',
            child: Icon(
              _rememberMe ? Icons.devices_rounded : Icons.timer_outlined,
              color: grayText,
              size: 17,
            ),
          ),
      ],
    );
  }

  // FORM HEADING

  Widget _buildFormHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 17),
        const Text(
          'Sign in',
          style: TextStyle(
            color: darkText,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pick up where you left off.',
          style: TextStyle(
            color: grayText,
            fontSize: 15.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // EMAIL FIELD

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      style: const TextStyle(
        color: darkText,
        fontSize: 16,
        height: 1.4,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [
        AutofillHints.username,
        AutofillHints.email,
      ],
      autocorrect: false,
      enableSuggestions: false,
      decoration: _inputDecoration(
        hint: 'you@example.com',
        icon: Icons.alternate_email_rounded,
      ),
    );
  }

  // PASSWORD FIELD

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      style: const TextStyle(
        color: darkText,
        fontSize: 16,
        height: 1.4,
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onSubmitted: (_) => _login(),
      decoration: _inputDecoration(
        hint: 'Enter your password',
        icon: Icons.lock_outline_rounded,
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
            size: 20,
          ),
        ),
      ),
    );
  }

  // LOGIN BUTTON

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryTeal.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Continue to PawLink',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // CREATE ACCOUNT

  Widget _buildCreateAccountRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: softerTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryTeal.withValues(alpha: 0.08),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'New to PawLink? ',
            style: TextStyle(
              color: grayText,
              fontSize: 16.5,
            ),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
            style: TextButton.styleFrom(
              foregroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 2,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Create an account',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SECURITY NOTE

  Widget _buildSecurityNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: primaryTeal,
            size: 16,
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            'Your sign-in is handled securely through Firebase Authentication.',
            style: TextStyle(
              color: grayText,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  // MOBILE HEADER

  Widget _buildMobileHeader() {
    return Column(
      children: [
        _buildBrandMark(),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: primaryTeal,
                size: 14,
              ),
              SizedBox(width: 7),
              Text(
                'WELCOME BACK, KA-PAWLINK',
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MOBILE SAFETY NOTE

  Widget _buildMobileSafetyNote() {
    return Text(
      'PawLink helps owners, residents, and the barangay stay connected for safer pet care.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: grayText.withValues(alpha: 0.75),
        fontSize: 16,
        height: 1.45,
      ),
    );
  }

  // LABEL

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: darkText,
        fontSize: 16.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // INPUT DECORATION

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA0A9A7),
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: primaryTeal,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: primaryTeal,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: alertRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: alertRed,
          width: 1.5,
        ),
      ),
    );
  }

  // DECORATIVE CIRCLE

  Widget _decorativeCircle({
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

  // FIREBASE LOGIN

  Future<void> _login() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter your email and password.',
        isError: true,
      );
      return;
    }

    if (!email.contains('@')) {
      _showMessage(
        'Please enter a valid email address.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Configure web persistence before signing in.
      // LOCAL remains signed in across browser restarts.
      // SESSION lasts for the current browser session.

      if (kIsWeb) {
        await _auth.setPersistence(
          _rememberMe ? Persistence.LOCAL : Persistence.SESSION,
        );
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate exactly once after successful authentication.
      _goToHomePage();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'user-not-found':
          message = 'No account was found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'Login failed. Please try again. (${e.code})';
      }

      _showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Something went wrong. Please check your connection and try again.',
        isError: true,
      );
    }
  }

  // MESSAGE

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? alertRed : primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
