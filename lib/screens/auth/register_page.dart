import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

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
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToGuidelines = false;

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    _scrollController.dispose();
    _keyboardFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // KEYBOARD SCROLL
  // ============================================================

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }

    if (!_scrollController.hasClients) {
      return false;
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

      return true;
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

      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _scrollController.animateTo(
        (_scrollController.offset + MediaQuery.of(context).size.height * 0.8)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _scrollController.animateTo(
        (_scrollController.offset - MediaQuery.of(context).size.height * 0.8)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.home) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.end) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      return true;
    }

    return false;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          final handled = _handleKeyEvent(event);

          return handled ? KeyEventResult.handled : KeyEventResult.ignored;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return _buildDesktopLayout();
            }

            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewportHeight = constraints.maxHeight;

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewportHeight),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: darkTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 60,
                        ),
                        child: _buildWelcomePanel(),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        color: warmBackground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 40,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 450),
                            child: _buildRegisterForm(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            _buildMobileLogo(),

            const SizedBox(height: 30),

            _buildRegisterForm(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME PANEL
  // ============================================================

  Widget _buildWelcomePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pets, color: Colors.white, size: 40),
        ),

        const SizedBox(height: 30),

        const Text(
          'Welcome to PawLink',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'Create your account and become part of a community that helps protect pets and support stray animals in the barangay.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 17,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 45),

        _buildWelcomeFeature(
          icon: Icons.qr_code_2,
          title: 'Pet QR Profiles',
          description: 'Give your pet a digital profile that can be accessed through a QR code.',
        ),

        const SizedBox(height: 28),

        _buildWelcomeFeature(
          icon: Icons.groups_outlined,
          title: 'Community Support',
          description:
              'Connect pet owners and residents to help keep pets safe.',
        ),

        const SizedBox(height: 28),

        _buildWelcomeFeature(
          icon: Icons.location_on_outlined,
          title: 'Lost & Found Reports',
          description:
              'Report lost, found, or stray pets and help return them safely.',
        ),

        const Spacer(),
      ],
    );
  }

  // ============================================================
  // WELCOME FEATURE
  // ============================================================

  Widget _buildWelcomeFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 25),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14,
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
  // MOBILE LOGO
  // ============================================================

  Widget _buildMobileLogo() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: primaryTeal,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pets, color: Colors.white, size: 36),
        ),

        const SizedBox(height: 14),

        const Text(
          'PawLink',
          style: TextStyle(
            color: primaryTeal,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Community Pet & Stray Management',
          textAlign: TextAlign.center,
          style: TextStyle(color: grayText, fontSize: 13),
        ),
      ],
    );
  }

  // ============================================================
  // REGISTER FORM
  // ============================================================

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create an account',
          style: TextStyle(
            color: darkText,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Join PawLink and help build a safer community for pets.',
          style: TextStyle(color: grayText, fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 30),

        _buildLabel('Full Name'),

        const SizedBox(height: 8),

        TextField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            hintText: 'Enter your full name',
            icon: Icons.person_outline,
          ),
        ),

        const SizedBox(height: 20),

        _buildLabel('Email Address'),

        const SizedBox(height: 8),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            hintText: 'Enter your email address',
            icon: Icons.email_outlined,
          ),
        ),

        const SizedBox(height: 20),

        _buildLabel('Password'),

        const SizedBox(height: 8),

        TextField(
          controller: passwordController,
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
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: grayText,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildLabel('Confirm Password'),

        const SizedBox(height: 8),

        TextField(
          controller: confirmPasswordController,
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
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: grayText,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Password must be at least 6 characters, contain one uppercase letter and one special character.',
          style: TextStyle(color: grayText, fontSize: 11, height: 1.4),
        ),

        const SizedBox(height: 18),

        _buildAgreement(),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primaryTeal.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                : const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: grayText, fontSize: 14),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryTeal,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Log in',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 15,
                color: darkTeal,
              ),

              const SizedBox(width: 6),

              Flexible(
                child: Text(
                  'Your account is secured by Firebase Authentication.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkTeal.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(color: Color(0xFF9AA3A3), fontSize: 14),

      prefixIcon: Icon(icon, color: grayText, size: 21),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkTeal, width: 1.5),
      ),
    );
  }

  // ============================================================
  // AGREEMENT
  // ============================================================

  Widget _buildAgreement() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _agreedToGuidelines,
              activeColor: primaryTeal,
              onChanged: (value) {
                setState(() {
                  _agreedToGuidelines = value ?? false;
                });
              },
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _agreedToGuidelines = !_agreedToGuidelines;
                });
              },
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: grayText,
                    fontSize: 12,
                    height: 1.5,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const TextSpan(
                      text: ' and consent to sharing pet contact information when a QR code is scanned.',
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

  // ============================================================
  // COMMUNITY GUIDELINES
  // ============================================================

  void _showCommunityGuidelines() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Community Guidelines',
            style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: const Text(
              'PawLink is a community platform created to help pet owners, residents, and the barangay work together to keep pets safe.\n\n'
              'By using PawLink, please:\n\n'
              '• Provide accurate information about yourself and your pets.\n\n'
              '• Use pet information only for responsible contact and reunification purposes.\n\n'
              '• Do not misuse another person’s contact information.\n\n'
              '• Submit truthful lost, found, or stray pet reports.\n\n'
              '• Respect the privacy and safety of other community members.\n\n'
              '• Do not approach aggressive or dangerous animals. Contact the appropriate barangay personnel when necessary.\n\n'
              'When a pet QR code is scanned, limited contact information may be displayed to help reunite the pet with its owner.',
              style: TextStyle(color: grayText, fontSize: 14, height: 1.6),
            ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FIREBASE REGISTER
  // ============================================================

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    // ----------------------------------------------------------
    // AGREEMENT
    // ----------------------------------------------------------

    if (!_agreedToGuidelines) {
      _showMessage(
        'Please agree to the Community Guidelines first.',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // REQUIRED FIELDS
    // ----------------------------------------------------------

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage('Please complete all required fields.', isError: true);
      return;
    }

    final name = nameController.text.trim();

    final email = emailController.text.trim();

    final password = passwordController.text;

    final confirmPassword = confirmPasswordController.text;

    // ----------------------------------------------------------
    // EMAIL
    // ----------------------------------------------------------

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // PASSWORD LENGTH
    // ----------------------------------------------------------

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // UPPERCASE
    // ----------------------------------------------------------

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);

    if (!hasUppercase) {
      _showMessage(
        'Password must contain at least one uppercase letter.',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // SPECIAL CHARACTER
    // ----------------------------------------------------------

    final hasSpecialCharacter = RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];'
      "'"
      ']',
    ).hasMatch(password);

    if (!hasSpecialCharacter) {
      _showMessage(
        'Password must contain at least one special character.',
        isError: true,
      );
      return;
    }

    // ----------------------------------------------------------
    // CONFIRM PASSWORD
    // ----------------------------------------------------------

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.', isError: true);
      return;
    }

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    setState(() {
      _isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // CREATE FIREBASE AUTH ACCOUNT
      // --------------------------------------------------------

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // --------------------------------------------------------
      // SAVE USER DISPLAY NAME
      // --------------------------------------------------------

      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Account created successfully!');

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
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
          message = 'Email/password authentication is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
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
      ),
    );
  }
}
