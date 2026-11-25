import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/invitation_service.dart';
import '../../services/owner_service.dart';
import '../../services/pet_service.dart';

class JointOwnersPage extends StatefulWidget {
  final String petId;

  const JointOwnersPage({super.key, required this.petId});

  @override
  State<JointOwnersPage> createState() => _JointOwnersPageState();
}

class _JointOwnersPageState extends State<JointOwnersPage> {
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  final PetService _petService = PetService();

  // FIX:
  // This service is now actually used by _buildOwnerCard().
  final OwnerService _ownerService = OwnerService();

  final InvitationService _invitationService = InvitationService();

  final TextEditingController _emailController = TextEditingController();

  bool _isSendingInvite = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND INVITATION
  // ============================================================

  Future<void> _sendInvite(String petName) async {
    final email = _emailController.text.trim().toLowerCase();

    final currentUser = _currentUser;

    if (currentUser == null) {
      _showMessage('Please sign in first.');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter the co-owner email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (email == currentUser.email?.trim().toLowerCase()) {
      _showMessage('You cannot invite your own account.');
      return;
    }

    setState(() {
      _isSendingInvite = true;
    });

    try {
      final invitationId = await _invitationService.createInvitation(
        petId: widget.petId,
        petName: petName,
        invitedEmail: email,
      );

      final link = _invitationService.buildInvitationLink(invitationId);

      if (!mounted) return;

      _emailController.clear();

      await _showInvitationCreatedDialog(email: email, link: link);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(e.message ?? 'Unable to create the invitation.');
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSendingInvite = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // ============================================================
  // INVITATION CREATED
  // ============================================================

  Future<void> _showInvitationCreatedDialog({
    required String email,
    required String link,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: primaryTeal),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Invitation Created',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'An invitation was created for $email.',
                  style: const TextStyle(color: darkText, height: 1.4),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Invitation link',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: grayText,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: SelectableText(
                    link,
                    style: const TextStyle(fontSize: 12, color: darkText),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Send this link to the invited person. They must sign in using the invited email before they can accept it.',
                  style: TextStyle(fontSize: 12, color: grayText, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));

                if (!context.mounted) return;

                Navigator.pop(context);

                _showMessage('Invitation link copied.', success: true);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy Link'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CANCEL INVITATION
  // ============================================================

  Future<void> _cancelInvitation(String invitationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancel invitation?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('The invitation link will no longer be usable.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: alertRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Invitation'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _invitationService.cancelInvitation(invitationId);

      if (!mounted) return;

      _showMessage('Invitation cancelled.', success: true);
    } catch (_) {
      if (!mounted) return;

      _showMessage('Unable to cancel the invitation.');
    }
  }

  // ============================================================
  // REMOVE CO-OWNER
  // ============================================================

  Future<void> _removeCoOwner(String ownerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove co-owner?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'This person will no longer have access to this pet profile.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: alertRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _petService.removeCoOwner(petId: widget.petId, ownerId: ownerId);

      if (!mounted) return;

      _showMessage('Co-owner removed successfully.', success: true);
    } catch (_) {
      if (!mounted) return;

      _showMessage('Unable to remove co-owner.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? primaryTeal : alertRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      appBar: AppBar(
        backgroundColor: warmBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Joint Owners',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _petService.getPetStream(widget.petId),
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
            return _buildPetNotFound();
          }

          final petData = snapshot.data!.data() ?? {};

          return _buildContent(petData);
        },
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(Map<String, dynamic> petData) {
    final petName = (petData['petName'] ?? petData['name'] ?? 'Your Pet')
        .toString();

    final petBreed = (petData['breed'] ?? 'Pet').toString();

    final photoUrl = (petData['photoUrl'] ?? '').toString();

    final primaryOwnerId = (petData['primaryOwnerId'] ?? '').toString();

    final ownerIds = List<String>.from(petData['ownerIds'] ?? <String>[]);

    final isPrimaryOwner = _currentUser?.uid == primaryOwnerId;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 20,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPetHeader(
                    petName: petName,
                    petBreed: petBreed,
                    photoUrl: photoUrl,
                  ),

                  const SizedBox(height: 24),

                  _buildSharedQrNotice(),

                  const SizedBox(height: 24),

                  if (isPrimaryOwner) _buildInviteCard(petName),

                  if (isPrimaryOwner) const SizedBox(height: 24),

                  _buildPendingInvitations(isPrimaryOwner: isPrimaryOwner),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    'People connected to $petName',
                    'Everyone below is linked to the same pet profile.',
                  ),

                  const SizedBox(height: 14),

                  _buildOwnersList(
                    ownerIds: ownerIds,
                    primaryOwnerId: primaryOwnerId,
                  ),

                  const SizedBox(height: 28),

                  _buildHowItWorks(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PET HEADER
  // ============================================================

  Widget _buildPetHeader({
    required String petName,
    required String petBreed,
    required String photoUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 500;

          final image = _buildPetImage(photoUrl);

          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pet profile',
                  style: TextStyle(
                    color: grayText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  petName,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  petBreed,
                  style: const TextStyle(color: grayText, fontSize: 14),
                ),
              ],
            ),
          );

          final badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link_rounded, size: 16, color: primaryTeal),
                SizedBox(width: 5),
                Text(
                  'Shared',
                  style: TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [image, const SizedBox(width: 16), details]),
                const SizedBox(height: 15),
                badge,
              ],
            );
          }

          return Row(
            children: [image, const SizedBox(width: 16), details, badge],
          );
        },
      ),
    );
  }

  Widget _buildPetImage(String photoUrl) {
    if (photoUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: lightTeal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.pets_rounded, size: 34, color: primaryTeal),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        photoUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 70,
            height: 70,
            color: lightTeal,
            child: const Icon(Icons.pets_rounded, color: primaryTeal),
          );
        },
      ),
    );
  }

  // ============================================================
  // QR NOTICE
  // ============================================================

  Widget _buildSharedQrNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8DDD7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.qr_code_2_rounded, color: primaryTeal, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One pet, one QR code',
                  style: TextStyle(
                    color: darkTeal,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'All owners are connected to the same pet document. '
                  'The pet keeps the same Pet ID and QR code even when '
                  'another owner is added.',
                  style: TextStyle(
                    color: Color(0xFF46615F),
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
  // INVITE CARD
  // ============================================================

  Widget _buildInviteCard(String petName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: primaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite a co-owner',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Share access to this pet with another owner or caregiver.',
                      style: TextStyle(color: grayText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_isSendingInvite) {
                _sendInvite(petName);
              }
            },
            decoration: InputDecoration(
              labelText: 'Co-owner email',
              hintText: 'example@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: warmBackground,
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
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSendingInvite ? null : () => _sendInvite(petName),
              icon: _isSendingInvite
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _isSendingInvite
                    ? 'Creating invitation...'
                    : 'Create Invitation',
              ),
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

          const SizedBox(height: 10),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 15, color: grayText),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'The invited person must sign in with the invited email before gaining access.',
                  style: TextStyle(color: grayText, fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PENDING INVITATIONS
  // ============================================================

  Widget _buildPendingInvitations({required bool isPrimaryOwner}) {
    if (!isPrimaryOwner) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _invitationService.getPetInvitationsStream(widget.petId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data?.docs ?? [];

        final pendingDocs = docs.where((doc) {
          final data = doc.data();

          return (data['status'] ?? '') == 'pending';
        }).toList();

        if (pendingDocs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pending_actions_outlined, color: darkTeal),
                  SizedBox(width: 9),
                  Text(
                    'Pending Invitations',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...pendingDocs.map((doc) => _buildInvitationCard(doc)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvitationCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final email = (data['invitedEmail'] ?? '').toString();

    final invitationId = (data['invitationId'] ?? doc.id).toString();

    final link = _invitationService.buildInvitationLink(invitationId);

    final expiresAt = data['expiresAt'];

    String expiryText = 'Expires in 7 days';

    if (expiresAt is Timestamp) {
      expiryText = 'Expires ${_formatDate(expiresAt.toDate())}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Color(0xFF9A5B16),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email.isEmpty ? 'Pending recipient' : email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkText,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      expiryText,
                      style: const TextStyle(color: grayText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Color(0xFF9A5B16),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: borderColor),
            ),
            child: SelectableText(
              link,
              style: const TextStyle(fontSize: 11, color: grayText),
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: link));

                  if (!mounted) return;

                  _showMessage('Invitation link copied.', success: true);
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Link'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _cancelInvitation(invitationId);
                },
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(foregroundColor: alertRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: grayText, fontSize: 13)),
      ],
    );
  }

  // ============================================================
  // OWNERS LIST
  // ============================================================

  Widget _buildOwnersList({
    required List<String> ownerIds,
    required String primaryOwnerId,
  }) {
    if (ownerIds.isEmpty) {
      return _buildEmptyOwners();
    }

    return Column(
      children: ownerIds.map((ownerId) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildOwnerCard(
            ownerId: ownerId,
            isPrimary: ownerId == primaryOwnerId,
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // OWNER CARD
  // ============================================================

  Widget _buildOwnerCard({required String ownerId, required bool isPrimary}) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      // ========================================================
      // FIX:
      // Use OwnerService instead of directly accessing
      // FirebaseFirestore.instance here.
      //
      // This makes _ownerService useful and removes the
      // "field '_ownerService' isn't used" warning.
      // ========================================================
      stream: _ownerService.getOwnerStream(ownerId),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final name = (data?['name'] ?? 'PawLink User').toString();

        final email = (data?['email'] ?? '').toString();

        final contact = (data?['contact'] ?? '').toString();

        final isCurrentUser = ownerId == _currentUser?.uid;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 500;

              final identity = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 7),
                          const Text(
                            '(You)',
                            style: TextStyle(
                              color: primaryTeal,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email.isEmpty ? 'Email not available' : email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: grayText, fontSize: 12),
                    ),
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact,
                        style: const TextStyle(color: grayText, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );

              final role = Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPrimary ? lightTeal : const Color(0xFFF3F4F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPrimary ? 'Primary' : 'Co-owner',
                      style: TextStyle(
                        color: isPrimary ? primaryTeal : grayText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (!isPrimary && !isCurrentUser)
                    IconButton(
                      tooltip: 'Remove co-owner',
                      onPressed: () {
                        _removeCoOwner(ownerId);
                      },
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: grayText,
                      ),
                    ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ownerAvatar(),
                        const SizedBox(width: 13),
                        identity,
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [role],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  _ownerAvatar(),
                  const SizedBox(width: 13),
                  identity,
                  const SizedBox(width: 8),
                  role,
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _ownerAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.person_rounded, color: primaryTeal),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyOwners() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline_rounded, size: 42, color: grayText),
          SizedBox(height: 10),
          Text(
            'No owners connected yet.',
            style: TextStyle(color: darkText, fontWeight: FontWeight.w700),
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0DEC9)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF9A5B16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'How joint ownership works',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '1. The primary owner creates an invitation.',
            style: TextStyle(
              color: Color(0xFF5F5145),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          Text(
            '2. The invitation link is shared with the other person.',
            style: TextStyle(
              color: Color(0xFF5F5145),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          Text(
            '3. The invited person signs in using the invited email.',
            style: TextStyle(
              color: Color(0xFF5F5145),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          Text(
            '4. They accept the invitation.',
            style: TextStyle(
              color: Color(0xFF5F5145),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          Text(
            '5. Both accounts access the same pet, Pet ID, and QR code.',
            style: TextStyle(
              color: Color(0xFF5F5145),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATES
  // ============================================================

  Widget _buildError() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Unable to load the pet owners right now.',
          textAlign: TextAlign.center,
          style: TextStyle(color: grayText),
        ),
      ),
    );
  }

  Widget _buildPetNotFound() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'This pet profile could not be found.',
          textAlign: TextAlign.center,
          style: TextStyle(color: grayText),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
