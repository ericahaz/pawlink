import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
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
  // PAWLINK ADMIN EMAIL
  // ============================================================

  static const String adminEmail = 'pawlink.help@gmail.com';

  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'General Concern';

  bool _isSubmitting = false;

  // ============================================================
  // SCROLL + KEYBOARD
  // ============================================================

  final ScrollController _scrollController = ScrollController();

  final FocusNode _pageFocusNode = FocusNode();

  final GlobalKey _contactFormKey = GlobalKey();

  // ============================================================
  // FAQ DATA
  // ============================================================

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I register my pet?',
      'answer':
          'Go to My Pets and select Register Pet. Enter your pet information, add a photo if available, and complete the registration process. PawLink will create a unique pet identity that can be connected to the pet QR code.',
    },
    {
      'question': 'How does the pet QR code work?',
      'answer':
          'Each registered pet has a unique QR identity. A person who finds the pet can scan the QR code to view the available public pet information and contact the owner without needing access to the owner account.',
    },
    {
      'question': 'How do I report a lost pet?',
      'answer':
          'Open the Report section and choose Lost Pet. Select your registered pet, provide the last-seen location and other important details, then submit the report.',
    },
    {
      'question': 'How do I report a found pet?',
      'answer':
          'Open the Report section and choose Found Pet. Provide the location and details about the pet. This helps connect the report with the appropriate owner or community response.',
    },
    {
      'question': 'Can two people manage the same pet?',
      'answer':
          'Yes. PawLink can support joint ownership. A primary owner can invite another person as a co-owner so both accounts can access the same registered pet.',
    },
    {
      'question': 'What should I do if a pet is aggressive?',
      'answer':
          'Do not approach or attempt to physically handle an aggressive animal. Use PawLink to report the situation and notify the appropriate barangay or animal-response personnel when necessary.',
    },
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _pageFocusNode.requestFocus();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _pageFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // KEYBOARD SCROLLING
  // ============================================================

  KeyEventResult _handleKeyEvent(
    FocusNode node,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (!_scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    final ScrollPosition position = _scrollController.position;

    // ------------------------------------------------------------
    // ARROW UP
    // ------------------------------------------------------------

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _scrollBy(-80);
      return KeyEventResult.handled;
    }

    // ------------------------------------------------------------
    // ARROW DOWN
    // ------------------------------------------------------------

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _scrollBy(80);
      return KeyEventResult.handled;
    }

    // ------------------------------------------------------------
    // PAGE UP
    // ------------------------------------------------------------

    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      _scrollBy(-position.viewportDimension * 0.85);
      return KeyEventResult.handled;
    }

    // ------------------------------------------------------------
    // PAGE DOWN
    // ------------------------------------------------------------

    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      _scrollBy(position.viewportDimension * 0.85);
      return KeyEventResult.handled;
    }

    // ------------------------------------------------------------
    // HOME
    // ------------------------------------------------------------

    if (event.logicalKey == LogicalKeyboardKey.home) {
      _scrollToPosition(0);
      return KeyEventResult.handled;
    }

    // ------------------------------------------------------------
    // END
    // ------------------------------------------------------------

    if (event.logicalKey == LogicalKeyboardKey.end) {
      _scrollToPosition(position.maxScrollExtent);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _scrollBy(double amount) {
    if (!_scrollController.hasClients) {
      return;
    }

    final double currentPosition = _scrollController.offset;

    final double targetPosition = (currentPosition + amount).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _scrollToPosition(double position) {
    if (!_scrollController.hasClients) {
      return;
    }

    final double targetPosition = position.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  // ============================================================
  // EMAIL ADMIN
  // ============================================================

  Future<void> _emailAdmin() async {
    try {
      Uri emailUri;

      if (kIsWeb) {
        // Flutter Web:
        // Open Gmail compose directly.
        emailUri = Uri.https(
          'mail.google.com',
          '/mail/',
          <String, String>{
            'view': 'cm',
            'fs': '1',
            'to': adminEmail,
            'su': 'PawLink Help Center Inquiry',
            'body': 'Hello PawLink Admin,\n\nI need assistance with:\n\n',
          },
        );
      } else {
        // Android / iOS / Windows / macOS:
        // Use the device's configured email application.
        emailUri = Uri(
          scheme: 'mailto',
          path: adminEmail,
          queryParameters: const {
            'subject': 'PawLink Help Center Inquiry',
            'body': 'Hello PawLink Admin,\n\nI need assistance with:\n\n',
          },
        );
      }

      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && mounted) {
        _showEmailFallback();
      }
    } catch (e) {
      if (!mounted) return;

      _showEmailFallback();
    }
  }

  // ============================================================
  // EMAIL FALLBACK
  // ============================================================

  void _showEmailFallback() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: primaryTeal,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Email PawLink Admin',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Your device could not open an email application automatically.\n\n'
            'Please send your message to:\n\n'
            'pawlink.help@gmail.com',
            style: TextStyle(
              color: grayText,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
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
  // SUBMIT SUPPORT REQUEST
  // ============================================================

  Future<void> _submitSupportRequest() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please log in before contacting PawLink Admin.',
        isError: true,
      );
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final CollectionReference<Map<String, dynamic>> requests =
          FirebaseFirestore.instance.collection('support_requests');

      final DocumentReference<Map<String, dynamic>> requestRef = requests.doc();

      await requestRef.set({
        'requestId': requestRef.id,
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'category': _selectedCategory,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'status': 'open',
        'adminReply': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _subjectController.clear();
      _messageController.clear();

      setState(() {
        _selectedCategory = 'General Concern';
        _isSubmitting = false;
      });

      await _showSuccessDialog();
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (e.code == 'permission-denied') {
        _showMessage(
          'Your request could not be submitted because Firestore '
          'security rules are blocking the request.',
          isError: true,
        );
      } else if (e.code == 'unauthenticated') {
        _showMessage(
          'Your session has expired. Please log in again.',
          isError: true,
        );
      } else if (e.code == 'unavailable') {
        _showMessage(
          'Firestore is temporarily unavailable. Please try again.',
          isError: true,
        );
      } else {
        _showMessage(
          'Unable to submit your request. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Unable to submit your request. Please try again.',
        isError: true,
      );
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            28,
            28,
            28,
            20,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: primaryTeal,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkText,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your concern has been sent to the PawLink support system. '
                'The admin can review your request and respond to it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grayText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? alertRed : primaryTeal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      appBar: AppBar(
        backgroundColor: warmBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: darkText,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Focus(
        focusNode: _pageFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 700;

            return SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1050,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildContactOptions(isMobile),
                      const SizedBox(height: 30),
                      _buildFaqSection(),
                      const SizedBox(height: 30),
                      _buildContactForm(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            darkTeal,
            primaryTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find answers to common questions or contact the PawLink Admin team if you need further assistance.',
                  style: TextStyle(
                    color: Colors.white70,
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

  // ============================================================
  // CONTACT OPTIONS
  // ============================================================

  Widget _buildContactOptions(bool isMobile) {
    final List<Widget> cards = [
      _buildContactCard(
        icon: Icons.support_agent_rounded,
        title: 'Contact Admin',
        description: 'Send a support request directly through PawLink.',
        buttonText: 'Send Request',
        onPressed: _scrollToContactForm,
      ),
      _buildContactCard(
        icon: Icons.email_outlined,
        title: 'Email Admin',
        description: 'Open your email app and send a message to PawLink Admin.',
        buttonText: 'Email Admin',
        onPressed: _emailAdmin,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 14),
          cards[1],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryTeal,
              size: 25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(
              color: grayText,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 17),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryTeal,
              side: const BorderSide(
                color: primaryTeal,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAQ
  // ============================================================

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            color: darkText,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Quick answers to common PawLink questions.',
          style: TextStyle(
            color: grayText,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        ..._faqs.map(
          (faq) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 2,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                18,
              ),
              iconColor: primaryTeal,
              collapsedIconColor: grayText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(
                      color: grayText,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTACT FORM
  // ============================================================

  Widget _buildContactForm() {
    return Container(
      key: _contactFormKey,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    color: primaryTeal,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact PawLink Admin',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Submit a support request through PawLink.',
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
            const SizedBox(height: 24),

            // ----------------------------------------------------
            // CATEGORY
            // ----------------------------------------------------

            const Text(
              'Category',
              style: TextStyle(
                color: darkText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: _inputDecoration(
                'Select a category',
                Icons.category_outlined,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'General Concern',
                  child: Text('General Concern'),
                ),
                DropdownMenuItem(
                  value: 'Account',
                  child: Text('Account'),
                ),
                DropdownMenuItem(
                  value: 'Pet Registration',
                  child: Text('Pet Registration'),
                ),
                DropdownMenuItem(
                  value: 'QR Code',
                  child: Text('QR Code'),
                ),
                DropdownMenuItem(
                  value: 'Lost / Found Pet',
                  child: Text('Lost / Found Pet'),
                ),
                DropdownMenuItem(
                  value: 'Report',
                  child: Text('Report'),
                ),
                DropdownMenuItem(
                  value: 'Technical Problem',
                  child: Text('Technical Problem'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedCategory = value;
                      });
                    },
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------
            // SUBJECT
            // ----------------------------------------------------

            const Text(
              'Subject',
              style: TextStyle(
                color: darkText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),

            TextFormField(
              controller: _subjectController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                'Example: I cannot register my pet',
                Icons.subject_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject.';
                }

                if (value.trim().length < 3) {
                  return 'Subject is too short.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------
            // MESSAGE
            // ----------------------------------------------------

            const Text(
              'Message',
              style: TextStyle(
                color: darkText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),

            TextFormField(
              controller: _messageController,
              enabled: !_isSubmitting,
              minLines: 5,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              decoration: _inputDecoration(
                'Describe your concern or question...',
                Icons.chat_bubble_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message.';
                }

                if (value.trim().length < 10) {
                  return 'Please provide a little more detail.';
                }

                return null;
              },
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------
            // SUBMIT BUTTON
            // ----------------------------------------------------

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitSupportRequest,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryTeal.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        size: 19,
                      ),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Support Request',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Your request will be associated with your PawLink account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grayText,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA5A3),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: grayText,
        size: 20,
      ),
      filled: true,
      fillColor: warmBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryTeal,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: alertRed,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: alertRed,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // SCROLL TO CONTACT FORM
  // ============================================================

  void _scrollToContactForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final BuildContext? formContext = _contactFormKey.currentContext;

      if (formContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        formContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }
}
