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
  static const Color alertRed = Color(0xFFDC2626);

  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _keyboardFocusNode = FocusNode();

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

    // ARROW DOWN
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

    // ARROW UP
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

    // PAGE DOWN
    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _scrollController.animateTo(
        (_scrollController.offset + MediaQuery.of(context).size.height * 0.8)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    // PAGE UP
    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _scrollController.animateTo(
        (_scrollController.offset - MediaQuery.of(context).size.height * 0.8)
            .clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    // HOME
    if (event.logicalKey == LogicalKeyboardKey.home) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      return KeyEventResult.handled;
    }

    // END
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

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: warmBackground,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: darkText),
        ),

        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: constraints.maxWidth >= 700,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 60,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // ICON
        // ========================================================

        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              color: primaryTeal,
              size: 42,
            ),
          ),
        ),

        const SizedBox(height: 30),

        // ========================================================
        // TITLE
        // ========================================================
        const Center(
          child: Text(
            'Reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ========================================================
        // DESCRIPTION
        // ========================================================
        const Center(
          child: Text(
            'Enter the email address connected to your '
            'PawLink account and we will help you reset '
            'your password.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grayText, fontSize: 14, height: 1.6),
          ),
        ),

        const SizedBox(height: 35),

        // ========================================================
        // EMAIL LABEL
        // ========================================================
        const Text(
          'Email Address',
          style: TextStyle(
            color: darkText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // ========================================================
        // EMAIL FIELD
        // ========================================================
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _resetPassword(),
          decoration: _inputDecoration(),
        ),

        const SizedBox(height: 25),

        // ========================================================
        // RESET BUTTON
        // ========================================================
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primaryTeal.withAlpha(120),
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
                    'Send Reset Link',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
          ),
        ),

        const SizedBox(height: 25),

        // ========================================================
        // INFORMATION BOX
        // ========================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: primaryTeal, size: 19),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'If the email belongs to a PawLink account, '
                  'a password reset message will be sent '
                  'to that email address.',
                  style: TextStyle(color: darkTeal, fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // ========================================================
        // BACK TO LOGIN
        // ========================================================
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: TextButton.styleFrom(foregroundColor: primaryTeal),
            child: const Text(
              'Back to Login',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'Enter your email',
      hintStyle: const TextStyle(color: Color(0xFF9AA5A3), fontSize: 13),

      prefixIcon: const Icon(
        Icons.email_outlined,
        color: primaryTeal,
        size: 20,
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

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
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
    );
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  void _resetPassword() {
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

    // TEMPORARY PASSWORD RESET
    // Firebase password reset will be connected here later.

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Password reset is ready to connect to Firebase.');
    });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
