import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/pet_service.dart';
import '../../services/report_service.dart';
import '../landing/landing_page.dart';
import 'settings_page.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final petService = PetService();
    final reportService = ReportService();

    if (user == null) {
      return const Scaffold(
        backgroundColor: warmBackground,
        body: Center(
          child: Text(
            'Please sign in to view your account.',
            style: TextStyle(color: darkText, fontSize: 15),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: warmBackground,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            final userData = userSnapshot.data?.data() ?? {};

            final name =
                (userData['name'] ?? user.displayName ?? 'PawLink User')
                    .toString();

            final email = (userData['email'] ?? user.email ?? 'No email')
                .toString();

            final phone = (userData['phone'] ?? 'No phone number added')
                .toString();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 48 : 20,
                    vertical: isDesktop ? 40 : 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),

                          const SizedBox(height: 28),

                          // ==================================================
                          // PROFILE CARD
                          // ==================================================
                          _buildProfileCard(
                            context,
                            name: name,
                            email: email,
                            phone: phone,
                            user: user,
                            isDesktop: isDesktop,
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // STATS
                          // ==================================================
                          _buildStats(
                            petService: petService,
                            reportService: reportService,
                            isDesktop: isDesktop,
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // PERSONAL INFORMATION
                          // ==================================================
                          _buildInformationCard(
                            name: name,
                            email: email,
                            phone: phone,
                            user: user,
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // ACCOUNT STATUS
                          // ==================================================
                          _buildAccountStatus(user),

                          const SizedBox(height: 24),

                          // ==================================================
                          // SETTINGS
                          // ==================================================
                          _buildSettingsCard(context),

                          const SizedBox(height: 24),

                          // ==================================================
                          // LOG OUT
                          // ==================================================
                          _buildLogoutCard(context),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ================================================================
  // HEADER WITH BACK BUTTON
  // ================================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LandingPage(),
                ),
              );
            }
          },
          icon: const Icon(
            Icons.arrow_back,
            color: darkText,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 40,
          ),
          alignment: Alignment.centerLeft,
          tooltip: 'Back',
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'My Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // PROFILE CARD
  // ================================================================

  Widget _buildProfileCard(
    BuildContext context, {
    required String name,
    required String email,
    required String phone,
    required User user,
    required bool isDesktop,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 30 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                _buildAvatar(name),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildProfileText(
                    name: name,
                    email: email,
                    phone: phone,
                  ),
                ),
                _buildEditButton(context),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(name),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProfileText(
                        name: name,
                        email: email,
                        phone: phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _buildEditButton(context),
                ),
              ],
            ),
    );
  }

  // ================================================================
  // AVATAR
  // ================================================================

  Widget _buildAvatar(String name) {
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'P';

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: lightTeal,
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryTeal.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: primaryTeal,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PROFILE TEXT
  // ================================================================

  Widget _buildProfileText({
    required String name,
    required String email,
    required String phone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: grayText),
        ),
        const SizedBox(height: 3),
        Text(
          phone,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: grayText),
        ),
      ],
    );
  }

  // ================================================================
  // EDIT PROFILE BUTTON
  // ================================================================

  Widget _buildEditButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
      },
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Edit Profile'),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ================================================================
  // STATISTICS
  // ================================================================

  Widget _buildStats({
    required PetService petService,
    required ReportService reportService,
    required bool isDesktop,
  }) {
    return StreamBuilder<int>(
      stream: petService.getMyPetsCountStream(),
      builder: (context, petSnapshot) {
        final petCount = petSnapshot.data ?? 0;

        return StreamBuilder<int>(
          stream: reportService.getMyReportsCountStream(),
          builder: (context, reportSnapshot) {
            final reportCount = reportSnapshot.data ?? 0;

            return StreamBuilder<int>(
              stream: petService.getQrProfilesCountStream(),
              builder: (context, qrSnapshot) {
                final qrCount = qrSnapshot.data ?? 0;

                final cards = [
                  _StatCard(
                    icon: Icons.pets_outlined,
                    label: 'Registered Pets',
                    value: '$petCount',
                    color: primaryTeal,
                  ),
                  _StatCard(
                    icon: Icons.qr_code_2_outlined,
                    label: 'QR Profiles',
                    value: '$qrCount',
                    color: darkTeal,
                  ),
                  _StatCard(
                    icon: Icons.description_outlined,
                    label: 'My Reports',
                    value: '$reportCount',
                    color: alertRed,
                  ),
                ];

                if (isDesktop) {
                  return Row(
                    children: cards
                        .map(
                          (card) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: card,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }

                return Column(
                  children: cards
                      .map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: card,
                        ),
                      )
                      .toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  // ================================================================
  // PERSONAL INFORMATION
  // ================================================================

  Widget _buildInformationCard({
    required String name,
    required String email,
    required String phone,
    required User user,
  }) {
    final createdAt = user.metadata.creationTime;

    return _SectionCard(
      title: 'Personal Information',
      subtitle: 'Information connected to your PawLink account.',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Full Name',
            value: name,
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: email,
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: phone,
          ),
          if (createdAt != null) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Account Created',
              value: _formatDate(createdAt),
            ),
          ],
        ],
      ),
    );
  }

  // ================================================================
  // ACCOUNT STATUS
  // ================================================================

  Widget _buildAccountStatus(User user) {
    return _SectionCard(
      title: 'Account Status',
      subtitle: 'Your current PawLink account security status.',
      icon: Icons.verified_user_outlined,
      child: Column(
        children: [
          _StatusRow(
            title: 'Account',
            value: 'Active',
            icon: Icons.check_circle_outline,
            color: primaryTeal,
          ),
          const Divider(height: 24),
          _StatusRow(
            title: 'Email',
            value: user.emailVerified ? 'Verified' : 'Not verified',
            icon: user.emailVerified
                ? Icons.mark_email_read_outlined
                : Icons.mark_email_unread_outlined,
            color: user.emailVerified ? primaryTeal : alertRed,
          ),
          const Divider(height: 24),
          const _StatusRow(
            title: 'Authentication',
            value: 'Firebase Authentication',
            icon: Icons.security_outlined,
            color: darkTeal,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SETTINGS CARD
  // ================================================================

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryTeal.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: primaryTeal,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need to change something?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Update your personal details, password, and preferences.',
                  style: TextStyle(fontSize: 13, color: grayText),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOGOUT CARD
  // ================================================================

  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: alertRed.withValues(alpha: 0.18),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 500;

          final iconBox = Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: alertRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: alertRed,
            ),
          );

          final text = const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Sign out of your PawLink account on this device.',
                  style: TextStyle(fontSize: 13, color: grayText),
                ),
              ],
            ),
          );

          final button = OutlinedButton.icon(
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: alertRed,
              side: const BorderSide(color: alertRed),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconBox,
                    const SizedBox(width: 14),
                    text,
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: button,
                ),
              ],
            );
          }

          return Row(
            children: [
              iconBox,
              const SizedBox(width: 14),
              text,
              const SizedBox(width: 14),
              button,
            ],
          );
        },
      ),
    );
  }

  // ================================================================
  // LOGOUT CONFIRMATION
  // ================================================================

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Log out of PawLink?',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'You will be returned to the PawLink landing page. '
            'You can sign in again anytime.',
            style: TextStyle(color: grayText, height: 1.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: grayText),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: alertRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // LOGOUT
  // ================================================================

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) {
        return;
      }

      // Remove every dashboard/account route from the navigation stack.
      //
      // This prevents the user from pressing the browser/app Back button
      // and returning to the dashboard after logging out.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log out. Please try again.'),
        ),
      );
    }
  }

  // ================================================================
  // DATE FORMAT
  // ================================================================

  static String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ==================================================================
// STAT CARD
// ==================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MyAccountPage.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: MyAccountPage.darkText,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MyAccountPage.grayText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SECTION CARD
// ==================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MyAccountPage.borderColor),
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
                  color: MyAccountPage.lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: MyAccountPage.primaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: MyAccountPage.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MyAccountPage.grayText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ==================================================================
// INFORMATION ROW
// ==================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: MyAccountPage.grayText,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: MyAccountPage.grayText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MyAccountPage.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// STATUS ROW
// ==================================================================

class _StatusRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusRow({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: MyAccountPage.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}