import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // ============================================================
  // PAWLINK COLORS
  // ============================================================

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

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _keyboardFocusNode = FocusNode();

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;

  // ============================================================
  // INIT
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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
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
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
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
      thumbVisibility: false,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 11, child: _buildRecoveryVisual()),

                  const SizedBox(width: 30),

                  Expanded(flex: 9, child: Center(child: _buildResetCard())),
                ],
              ),
            ),
          ),
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
      thumbVisibility: false,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
        child: Column(
          children: [
            _buildMobileHeader(),

            const SizedBox(height: 18),

            _buildResetCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP VISUAL
  // ============================================================

  Widget _buildRecoveryVisual() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 650),
      decoration: BoxDecoration(
        color: darkTeal,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ======================================================
          // DECORATIVE CIRCLES
          // ======================================================

          Positioned(
            top: -85,
            right: -65,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: primaryTeal.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -90,
            left: -75,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ======================================================
          // FLOATING LOCK
          // ======================================================
          Positioned(
            top: 62,
            right: 50,
            child: Transform.rotate(angle: 0.08, child: _buildFloatingLock()),
          ),

          // ======================================================
          // PAW
          // ======================================================
          Positioned(bottom: 55, right: 48, child: _buildPawBubble()),

          // ======================================================
          // CONTENT
          // ======================================================
          Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandMark(),

                const SizedBox(height: 42),

                const Text(
                  'Lost access?\nWe can help.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: -1.2,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Enter the email connected to your PawLink account '
                  'and Firebase will send a secure password reset link.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                _buildRecoveryStep(
                  number: '01',
                  icon: Icons.email_outlined,
                  title: 'Enter your email',
                  description:
                      'Use the email address you used when creating '
                      'your PawLink account.',
                ),

                const SizedBox(height: 12),

                _buildRecoveryStep(
                  number: '02',
                  icon: Icons.mark_email_read_outlined,
                  title: 'Check your inbox',
                  description:
                      'Firebase sends a password reset message '
                      'to your email.',
                ),

                const SizedBox(height: 12),

                _buildRecoveryStep(
                  number: '03',
                  icon: Icons.lock_reset_outlined,
                  title: 'Create a new password',
                  description:
                      'Follow the link in the email to securely '
                      'update your password.',
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Flexible(
                      child: Text(
                        'Secure account recovery',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 12,
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

  // ============================================================
  // BRAND MARK
  // CLICKING PAWLINK RETURNS TO LANDING PAGE
  // ============================================================

  Widget _buildBrandMark() {
    return Tooltip(
      message: 'Go to PawLink Home',
      child: InkWell(
        onTap: _goToHome,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(4),
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
                child: const Icon(Icons.pets, color: primaryTeal, size: 29),
              ),

              const SizedBox(width: 14),

              const Text(
                'PawLink',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
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

  // ============================================================
  // FLOATING LOCK
  // ============================================================

  Widget _buildFloatingLock() {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(22),
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              color: primaryTeal,
              size: 29,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'ACCOUNT',
            style: TextStyle(
              color: darkText,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'RECOVERY',
            style: TextStyle(
              color: grayText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAW BUBBLE
  // ============================================================

  Widget _buildPawBubble() {
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
      child: const Icon(Icons.pets, color: Colors.white, size: 28),
    );
  }

  // ============================================================
  // RECOVERY STEP
  // ============================================================

  Widget _buildRecoveryStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 11.5,
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
  // MOBILE HEADER
  // ============================================================

  Widget _buildMobileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: darkTeal,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.13),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: InkWell(
        onTap: _goToHome,
        borderRadius: BorderRadius.circular(22),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.pets, color: primaryTeal, size: 30),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PawLink',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Secure account recovery',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.home_outlined, color: Colors.white70, size: 21),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RESET CARD
  // ============================================================

  Widget _buildResetCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 510),
      padding: const EdgeInsets.fromLTRB(30, 32, 30, 28),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 1.5),
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
          _buildCardHeading(),

          const SizedBox(height: 27),

          _buildEmailField(),

          const SizedBox(height: 20),

          _buildResetButton(),

          const SizedBox(height: 18),

          _buildInformationBox(),

          const SizedBox(height: 20),

          _buildBackToLogin(),

          const SizedBox(height: 12),

          _buildSecurityNote(),
        ],
      ),
    );
  }

  // ============================================================
  // CARD HEADING
  // ============================================================

  Widget _buildCardHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            color: primaryTeal,
            size: 30,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Reset your password',
          style: TextStyle(
            color: darkText,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'No worries. Enter your account email and we will send '
          'you a secure reset link.',
          style: TextStyle(color: grayText, fontSize: 13, height: 1.55),
        ),
      ],
    );
  }

  // ============================================================
  // EMAIL FIELD
  // ============================================================

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            color: darkText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _resetPassword(),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  // ============================================================
  // RESET BUTTON
  // ============================================================

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
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
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send Reset Link',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // INFORMATION BOX
  // ============================================================

  Widget _buildInformationBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softerTeal,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: primaryTeal, size: 17),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'If the email belongs to a PawLink account, Firebase '
              'will send a password reset message to that address.',
              style: TextStyle(color: darkTeal, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACK TO LOGIN
  // ============================================================

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
        icon: const Icon(Icons.arrow_back_rounded, size: 16),
        label: const Text(
          'Back to Login',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        style: TextButton.styleFrom(foregroundColor: primaryTeal),
      ),
    );
  }

  // ============================================================
  // SECURITY NOTE
  // ============================================================

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user_outlined, color: darkTeal, size: 14),

        const SizedBox(width: 6),

        Flexible(
          child: Text(
            'Password recovery is handled by Firebase Authentication.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkTeal.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'Enter your email',
      hintStyle: const TextStyle(color: Color(0xFF9AA3A3), fontSize: 13),
      prefixIcon: const Icon(Icons.email_outlined, color: grayText, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
    );
  }

  // ============================================================
  // GO TO PAWLINK HOME
  // ============================================================

  void _goToHome() {
    FocusScope.of(context).unfocus();

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address.', isError: true);
      return;
    }

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Password reset link sent. Check your email.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No PawLink account was found with that email address.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please wait and try again later.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        case 'operation-not-allowed':
          message = 'Password reset is not enabled for this Firebase project.';
          break;

        default:
          message = 'Unable to send the reset link. Please try again.';
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? alertRed : primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
