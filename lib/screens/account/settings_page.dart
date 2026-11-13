
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../seasonal/seasonal_controller.dart';
import 'my_account_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static Color get primaryTeal =>
      SeasonalController.instance.activeTheme?.primary ??
      const Color(0xFF0F766E);

  static Color get darkTeal =>
      SeasonalController.instance.activeTheme?.secondary ??
      const Color(0xFF115E59);

  static Color get lightTeal {
    final theme = SeasonalController.instance.activeTheme;
    if (theme == null) return const Color(0xFFE7F5F2);
    return Color.alphaBlend(
      theme.primary.withValues(alpha: 0.10),
      theme.surface,
    );
  }

  static const Color alertRed = Color(0xFFDC2626);

  static Color get warmBackground =>
      SeasonalController.instance.activeTheme?.background ??
      const Color(0xFFFFFBF5);

  static Color get darkText =>
      SeasonalController.instance.activeTheme?.textPrimary ??
      const Color(0xFF243333);

  static Color get grayText =>
      SeasonalController.instance.activeTheme?.textSecondary ??
      const Color(0xFF667373);

  static Color get borderColor =>
      SeasonalController.instance.activeTheme?.border ??
      const Color(0xFFE3E5E3);

  static Color get surfaceColor =>
      SeasonalController.instance.activeTheme?.surface ?? Colors.white;

  static Color get onPrimaryColor =>
      SeasonalController.instance.activeTheme?.onPrimary ?? Colors.white;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  bool _foundPetNotifications = true;
  bool _lostPetNotifications = true;
  bool _barangayNotifications = true;
  bool _qrPublicProfile = true;

  User? get _user => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = _user;

    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      final data = doc.data() ?? {};

      _nameController.text =
          (data['name'] ?? user.displayName ?? '').toString();

      _phoneController.text = (data['phone'] ?? '').toString();

      _foundPetNotifications = data['foundPetNotifications'] ?? true;

      _lostPetNotifications = data['lostPetNotifications'] ?? true;

      _barangayNotifications = data['barangayNotifications'] ?? true;

      _qrPublicProfile = data['qrPublicProfile'] ?? true;
    } catch (_) {
      _nameController.text = user.displayName ?? '';
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = _user;

    if (user == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your full name.', isError: true);
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? '',
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(name);

      if (mounted) {
        _showMessage('Your profile has been updated.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          'Unable to update your profile. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _savePreference(String field, bool value) async {
    final user = _user;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not save this setting.', isError: true);
    }
  }

  Future<void> _sendVerificationEmail() async {
    final user = _user;

    if (user == null) return;

    try {
      await user.sendEmailVerification();

      if (mounted) {
        _showMessage('Verification email sent. Please check your inbox.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to send the verification email.', isError: true);
      }
    }
  }

  Future<void> _changePassword() async {
    final user = _user;

    if (user?.email == null) return;

    try {
      await _auth.sendPasswordResetEmail(email: user!.email!);

      if (mounted) {
        _showMessage('A password reset link was sent to ${user.email}.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to send the password reset email.', isError: true);
      }
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sign out?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'You can sign back in anytime using your PawLink account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: onPrimaryColor,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) return;

    await _auth.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showDeleteAccountInfo() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Account deletion should be handled carefully because it may affect your registered pets, joint-owner access, reports, and other PawLink records.\n\n'
            'For now, contact your PawLink administrator before permanently deleting an account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? alertRed : primaryTeal,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: primaryTeal))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 28 : 8,
                      4,
                      isDesktop ? 28 : 8,
                      isDesktop ? 32 : 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            SizedBox(height: isDesktop ? 24 : 18),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 0 : 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileSection(isDesktop),
                                  const SizedBox(height: 18),
                                  _buildSecuritySection(),
                                  const SizedBox(height: 18),
                                  _buildNotificationSection(),
                                  const SizedBox(height: 18),
                                  _buildPrivacySection(),
                                  const SizedBox(height: 18),
                                  _buildAccountActions(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
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
                  builder: (_) => const MyAccountPage(),
                ),
              );
            }
          },
          icon: Icon(
            Icons.arrow_back,
            color: darkText,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 24,
            maxWidth: 24,
            minHeight: 44,
          ),
          alignment: Alignment.centerLeft,
          tooltip: 'Back',
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(bool isDesktop) {
    return _SettingsCard(
      icon: Icons.person_outline,
      title: 'Personal Details',
      subtitle: 'Keep your contact information up to date.',
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                ),
              ],
            ),
          const SizedBox(height: 14),
          _buildEmailField(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveProfile,
              icon: _saving
                  ? SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: onPrimaryColor,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'Saving...' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: onPrimaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 16, color: darkText),
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 15),
        hintStyle: const TextStyle(fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 17,
        ),
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryTeal, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final email = _user?.email ?? 'No email';

    return TextField(
      enabled: false,
      controller: TextEditingController(text: email),
      style: TextStyle(fontSize: 16, color: grayText),
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 15),
        helperStyle: const TextStyle(fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 17,
        ),
        labelText: 'Email Address',
        helperText: 'Your login email is managed by Firebase Authentication.',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    final user = _user;

    return _SettingsCard(
      icon: Icons.security_outlined,
      title: 'Security',
      subtitle: 'Protect your PawLink account.',
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.lock_reset_outlined,
            title: 'Change Password',
            subtitle: 'Receive a secure password reset link by email.',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _changePassword,
          ),
          const Divider(height: 1),
          _ActionTile(
            icon: user?.emailVerified == true
                ? Icons.mark_email_read_outlined
                : Icons.mark_email_unread_outlined,
            title: 'Email Verification',
            subtitle: user?.emailVerified == true
                ? 'Your email address is verified.'
                : 'Your email address has not been verified.',
            trailing: user?.emailVerified == true
                ? Icon(Icons.check_circle_outline, color: primaryTeal)
                : TextButton(
                    onPressed: _sendVerificationEmail,
                    child: const Text('Verify'),
                  ),
            onTap: user?.emailVerified == true ? null : _sendVerificationEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return _SettingsCard(
      icon: Icons.notifications_none_outlined,
      title: 'Notifications',
      subtitle: 'Choose which PawLink updates you want to receive.',
      child: Column(
        children: [
          _buildSwitch(
            title: 'Found Pet Reports',
            subtitle: 'Get notified when someone reports finding your pet.',
            value: _foundPetNotifications,
            onChanged: (value) {
              setState(() {
                _foundPetNotifications = value;
              });
              _savePreference('foundPetNotifications', value);
            },
          ),
          const Divider(height: 1),
          _buildSwitch(
            title: 'Lost Pet Updates',
            subtitle: 'Receive updates related to your lost pet reports.',
            value: _lostPetNotifications,
            onChanged: (value) {
              setState(() {
                _lostPetNotifications = value;
              });
              _savePreference('lostPetNotifications', value);
            },
          ),
          const Divider(height: 1),
          _buildSwitch(
            title: 'Barangay Reports',
            subtitle: 'Receive updates about submitted barangay reports.',
            value: _barangayNotifications,
            onChanged: (value) {
              setState(() {
                _barangayNotifications = value;
              });
              _savePreference('barangayNotifications', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return _SettingsCard(
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy & QR Profile',
      subtitle: 'Control what information is available publicly.',
      child: Column(
        children: [
          _buildSwitch(
            title: 'Public QR Pet Profile',
            subtitle:
                'Allow people who scan your pet QR code to view its public profile.',
            value: _qrPublicProfile,
            onChanged: (value) {
              setState(() {
                _qrPublicProfile = value;
              });
              _savePreference('qrPublicProfile', value);
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 19, color: primaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Only information intended for the public pet profile should be shown when a QR code is scanned. Private account information should remain protected.',
                    style: TextStyle(
                      fontSize: 12,
                      color: grayText,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return _SettingsCard(
      icon: Icons.manage_accounts_outlined,
      title: 'Account Actions',
      subtitle: 'Manage your PawLink account.',
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.person_outline,
            title: 'View My Account',
            subtitle: 'See your profile and account information.',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyAccountPage()),
              );
            },
          ),
          const Divider(height: 1),
          _ActionTile(
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            subtitle: 'Sign out of your PawLink account.',
            titleColor: alertRed,
            iconColor: alertRed,
            onTap: _signOut,
          ),
          const Divider(height: 1),
          _ActionTile(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Request permanent deletion of your account.',
            titleColor: alertRed,
            iconColor: alertRed,
            onTap: _showDeleteAccountInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: grayText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: primaryTeal,
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width >= 900 ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: _SettingsPageState.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _SettingsPageState.borderColor),
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
                  color: _SettingsPageState.lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _SettingsPageState.primaryTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _SettingsPageState.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: _SettingsPageState.grayText,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: iconColor ?? _SettingsPageState.grayText,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? _SettingsPageState.darkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: _SettingsPageState.grayText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}
