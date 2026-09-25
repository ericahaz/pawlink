import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'register_page.dart';
import 'forgot_password_page.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================
  // PAWLINK COLORS
  // ============================================================

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

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // STATE
  // ============================================================

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
      final target = (_scrollController.offset + scrollAmount)
          .clamp(0.0, _scrollController.position.maxScrollExtent)
          .toDouble();

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final target = (_scrollController.offset - scrollAmount)
          .clamp(0.0, _scrollController.position.maxScrollExtent)
          .toDouble();

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      final target =
          (_scrollController.offset + MediaQuery.of(context).size.height * 0.8)
              .clamp(0.0, _scrollController.position.maxScrollExtent)
              .toDouble();

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      final target =
          (_scrollController.offset - MediaQuery.of(context).size.height * 0.8)
              .clamp(0.0, _scrollController.position.maxScrollExtent)
              .toDouble();

      _scrollController.animateTo(
        target,
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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

  // ============================================================
  // DESKTOP
  // ============================================================

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

  // ============================================================
  // DESKTOP SHELL
  // ============================================================

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
            Expanded(flex: 11, child: _buildWelcomePanel()),
            Expanded(flex: 9, child: _buildDesktopFormArea()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP FORM AREA
  // ============================================================

  Widget _buildDesktopFormArea() {
    return Container(
      color: warmBackground,
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: _buildLoginCard(),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        child: Column(
          children: [
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

  // ============================================================
  // WELCOME PANEL
  // ============================================================

  Widget _buildWelcomePanel() {
    return Container(
      constraints: const BoxConstraints(minHeight: 720),
      decoration: const BoxDecoration(color: primaryTeal),
      child: Stack(
        children: [
          // ------------------------------------------------------
          // DECORATIVE CIRCLES
          // ------------------------------------------------------

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

          // ------------------------------------------------------
          // MAIN CONTENT
          // ------------------------------------------------------
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

  // ============================================================
  // BRAND MARK
  // ============================================================

  Widget _buildBrandMark({bool darkBackground = false}) {
    return Row(
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
                fontSize: 23,
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
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME COPY
  // ============================================================

  Widget _buildWelcomeCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waving_hand_rounded, color: Colors.white, size: 15),
              SizedBox(width: 7),
              Text(
                'WELCOME BACK, KA-PAWLINK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
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
            fontSize: 41,
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
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME HIGHLIGHTS
  // ============================================================

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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 10.5,
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

  // ============================================================
  // COMMUNITY MINI CARD
  // ============================================================

  Widget _buildCommunityMiniCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: deepTeal,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Every report can help a pet get home safely.',
                  style: TextStyle(
                    color: Color(0xB8FFFFFF),
                    fontSize: 10.5,
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

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 1.2),
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

          const SizedBox(height: 7),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryTeal,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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

  // ============================================================
  // FORM HEADING
  // ============================================================

  Widget _buildFormHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primaryTeal.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.login_rounded, color: primaryTeal, size: 21),
        ),

        const SizedBox(height: 17),

        const Text(
          'Sign in',
          style: TextStyle(
            color: darkText,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Pick up where you left off.',
          style: TextStyle(color: grayText, fontSize: 13.5, height: 1.4),
        ),
      ],
    );
  }

  // ============================================================
  // EMAIL FIELD
  // ============================================================

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(
        hint: 'you@example.com',
        icon: Icons.alternate_email_rounded,
      ),
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
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

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
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

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Widget _buildCreateAccountRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: softerTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryTeal.withValues(alpha: 0.08)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'New to PawLink? ',
            style: TextStyle(color: grayText, fontSize: 12.5),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Create an account',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURITY NOTE
  // ============================================================

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
            style: TextStyle(color: grayText, fontSize: 10.5, height: 1.45),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE HEADER
  // ============================================================

  Widget _buildMobileHeader() {
    return Column(
      children: [
        _buildBrandMark(),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded, color: primaryTeal, size: 14),
              SizedBox(width: 7),
              Text(
                'WELCOME BACK, KA-PAWLINK',
                style: TextStyle(
                  color: darkTeal,
                  fontSize: 9.5,
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

  // ============================================================
  // MOBILE SAFETY NOTE
  // ============================================================

  Widget _buildMobileSafetyNote() {
    return Text(
      'PawLink helps owners, residents, and the barangay stay connected for safer pet care.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: grayText.withValues(alpha: 0.75),
        fontSize: 10.5,
        height: 1.45,
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: darkText,
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA0A9A7), fontSize: 13),
      prefixIcon: Icon(icon, color: primaryTeal, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
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
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: alertRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: alertRed, width: 1.5),
      ),
    );
  }

  // ============================================================
  // DECORATIVE CIRCLE
  // ============================================================

  Widget _decorativeCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ============================================================
  // FIREBASE LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text;

    // ----------------------------------------------------------
    // REQUIRED FIELDS
    // ----------------------------------------------------------

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // EMAIL
    // ----------------------------------------------------------

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    setState(() {
      _isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // FIREBASE SIGN IN
      // --------------------------------------------------------

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Login successful!');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // --------------------------------------------------------
      // GO TO PAWLINK DASHBOARD
      // --------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
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
          message = 'Login failed. Please try again.';
      }

      _showMessage(message, isError: true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Something went wrong. Please try again.', isError: true);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? alertRed : primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
