import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/invitation_service.dart';
import '../home/home_page.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

class AcceptInvitationPage extends StatefulWidget {
  final String invitationId;

  const AcceptInvitationPage({super.key, required this.invitationId});

  @override
  State<AcceptInvitationPage> createState() => _AcceptInvitationPageState();
}

class _AcceptInvitationPageState extends State<AcceptInvitationPage> {
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  final InvitationService _invitationService = InvitationService();

  bool _isAccepting = false;
  bool _isDeclining = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _acceptInvitation() async {
    if (_currentUser == null) {
      _showMessage(
        'Please sign in before accepting the invitation.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isAccepting = true;
    });

    try {
      await _invitationService.acceptInvitation(widget.invitationId);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: primaryTeal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Invitation Accepted',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            content: const Text(
              'You are now connected to this pet. The pet will appear in your My Pets section.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _declineInvitation() async {
    if (_currentUser == null) {
      _showMessage('Please sign in first.', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Decline invitation?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('You will not be connected to this pet.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Go Back'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: alertRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeclining = true;
    });

    try {
      await _invitationService.declineInvitation(widget.invitationId);

      if (!mounted) return;

      _showMessage('Invitation declined.', isError: false);

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isDeclining = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? alertRed : primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('jointInvitations')
              .doc(widget.invitationId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryTeal),
              );
            }

            if (snapshot.hasError) {
              return _buildError();
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildNotFound();
            }

            final data = snapshot.data!.data() ?? {};

            return _buildInvitation(data);
          },
        ),
      ),
    );
  }

  Widget _buildInvitation(Map<String, dynamic> data) {
    final petName = (data['petName'] ?? 'a pet').toString();

    final invitedEmail = (data['invitedEmail'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final status = (data['status'] ?? 'pending').toString();

    final expiresAt = data['expiresAt'];

    final userEmail = _currentUser?.email?.trim().toLowerCase();

    final emailMatches =
        _currentUser != null &&
        invitedEmail.isNotEmpty &&
        invitedEmail == userEmail;

    bool isExpired = false;

    if (expiresAt is Timestamp) {
      isExpired = expiresAt.toDate().isBefore(DateTime.now());
    }

    if (status != 'pending' || isExpired) {
      return _buildUnavailable(status: isExpired ? 'expired' : status);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 40 : 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 34 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildLogoIcon(),

                    const SizedBox(height: 20),

                    const Text(
                      'You\'re invited!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkText,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'You have been invited to become a co-owner of $petName on PawLink.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: grayText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _buildPetCard(petName),

                    const SizedBox(height: 18),

                    _buildEmailCard(
                      invitedEmail: invitedEmail,
                      emailMatches: emailMatches,
                    ),

                    const SizedBox(height: 24),

                    if (_currentUser == null)
                      _buildSignInRequired()
                    else if (!emailMatches)
                      _buildWrongAccount(invitedEmail)
                    else
                      _buildActions(),

                    const SizedBox(height: 20),

                    const Text(
                      'Your account must use the invited email address to accept this invitation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: grayText,
                        fontSize: 11,
                        height: 1.4,
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

  Widget _buildLogoIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.pets_rounded, color: primaryTeal, size: 38),
    );
  }

  Widget _buildPetCard(String petName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8DDD7)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.pets_rounded, color: primaryTeal),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pet',
                  style: TextStyle(color: grayText, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  petName,
                  style: const TextStyle(
                    color: darkTeal,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard({
    required String invitedEmail,
    required bool emailMatches,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: emailMatches ? const Color(0xFFF3FAF8) : const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emailMatches
              ? const Color(0xFFCBE8E3)
              : const Color(0xFFF1CACA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            emailMatches ? Icons.check_circle_outline : Icons.email_outlined,
            color: emailMatches ? primaryTeal : alertRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invitation email',
                  style: TextStyle(color: grayText, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  invitedEmail.isEmpty ? 'Email unavailable' : invitedEmail,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!emailMatches && _currentUser != null) ...[
                  const SizedBox(height: 5),
                  const Text(
                    'You are signed in with a different email.',
                    style: TextStyle(color: alertRed, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInRequired() {
    return Column(
      children: [
        const Text(
          'Sign in or create an account using the invited email address to continue.',
          textAlign: TextAlign.center,
          style: TextStyle(color: grayText, fontSize: 13, height: 1.45),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sign In'),
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: primaryTeal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildWrongAccount(String invitedEmail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFF1CACA)),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: alertRed, size: 30),
          const SizedBox(height: 8),
          const Text(
            'Wrong account',
            style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'Please sign out and sign in using $invitedEmail.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: grayText, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isAccepting ? null : _acceptInvitation,
            icon: _isAccepting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_isAccepting ? 'Accepting...' : 'Accept Invitation'),
            style: FilledButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isDeclining ? null : _declineInvitation,
            style: TextButton.styleFrom(foregroundColor: alertRed),
            child: Text(_isDeclining ? 'Declining...' : 'Decline Invitation'),
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailable({required String status}) {
    String title;
    String message;
    IconData icon;

    switch (status) {
      case 'accepted':
        title = 'Invitation Already Accepted';
        message = 'This invitation has already been accepted.';
        icon = Icons.check_circle_outline;
        break;

      case 'declined':
        title = 'Invitation Declined';
        message = 'This invitation is no longer available.';
        icon = Icons.cancel_outlined;
        break;

      case 'cancelled':
        title = 'Invitation Cancelled';
        message = 'The person who sent this invitation cancelled it.';
        icon = Icons.link_off_rounded;
        break;

      case 'expired':
        title = 'Invitation Expired';
        message = 'This invitation has expired. Ask the primary owner to create a new invitation.';
        icon = Icons.timer_off_outlined;
        break;

      default:
        title = 'Invitation Unavailable';
        message = 'This invitation can no longer be used.';
        icon = Icons.link_off_rounded;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(icon, color: primaryTeal, size: 55),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: grayText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go to PawLink'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Unable to load this invitation. Please try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: grayText),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off_rounded, color: grayText, size: 50),
            const SizedBox(height: 15),
            const Text(
              'Invitation Not Found',
              style: TextStyle(
                color: darkText,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'This invitation may have been deleted or the link may be incorrect.',
              textAlign: TextAlign.center,
              style: TextStyle(color: grayText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to PawLink'),
            ),
          ],
        ),
      ),
    );
  }
}
