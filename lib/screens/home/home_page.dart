import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/pet_service.dart';
import '../../services/report_service.dart';
import '../account/my_account_page.dart';
import '../account/settings_page.dart';
import '../barangay/barangay_page.dart';
import '../pets/my_pets_page.dart';
import '../pets/pet_profile_page.dart';
import '../pets/register_pet_page.dart';
import '../reports/report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PetService _petService = PetService();
  final ReportService _reportService = ReportService();

  int _selectedNav = 0;

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
    return Scaffold(
      backgroundColor: warmBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: [
                _buildDesktopSidebar(),
                Expanded(child: SafeArea(child: _buildDashboardContent())),
              ],
            );
          }

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildMobileHeader(),
                Expanded(child: _buildDashboardContent()),
                _buildMobileBottomNavigation(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP SIDEBAR
  // ============================================================

  Widget _buildDesktopSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          // ----------------------------------------------------
          // LOGO
          // ----------------------------------------------------

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              children: [
                _buildLogo(size: 42),
                const SizedBox(width: 12),
                const Text(
                  'PawLink',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: darkTeal,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: borderColor),

          // ----------------------------------------------------
          // SCROLLABLE NAVIGATION
          // ----------------------------------------------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 18, bottom: 10),
              child: Column(
                children: [
                  // ------------------------------------------------
                  // MAIN NAVIGATION
                  // ------------------------------------------------

                  _buildSidebarItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: _selectedNav == 0,
                    onTap: () {
                      setState(() {
                        _selectedNav = 0;
                      });
                    },
                  ),

                  _buildSidebarItem(
                    icon: Icons.pets_rounded,
                    label: 'My Pets',
                    selected: _selectedNav == 1,
                    onTap: _goToMyPets,
                  ),

                  _buildSidebarItem(
                    icon: Icons.campaign_rounded,
                    label: 'Report',
                    selected: _selectedNav == 2,
                    onTap: _goToReports,
                  ),

                  _buildSidebarItem(
                    icon: Icons.location_city_rounded,
                    label: 'Barangay',
                    selected: _selectedNav == 3,
                    onTap: _goToBarangay,
                  ),

                  // ------------------------------------------------
                  // ACCOUNT SECTION
                  // ------------------------------------------------
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 7,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ACCOUNT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),

                  _buildSidebarItem(
                    icon: Icons.person_outline_rounded,
                    label: 'My Account',
                    selected: _selectedNav == 4,
                    onTap: _goToMyAccount,
                  ),

                  _buildSidebarItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    selected: _selectedNav == 5,
                    onTap: _goToSettings,
                  ),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------
          // SAFETY CARD
          // ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: _buildSidebarSafetyCard(),
          ),

          // ----------------------------------------------------
          // LOGOUT
          // ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            child: _buildLogoutButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Material(
        color: selected ? lightTeal : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 21, color: selected ? primaryTeal : grayText),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? darkTeal : darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarSafetyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alertRed.withValues(alpha: 0.15)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded, color: alertRed, size: 23),
          SizedBox(height: 10),
          Text(
            'Stay safe',
            style: TextStyle(fontWeight: FontWeight.w800, color: darkText),
          ),
          SizedBox(height: 5),
          Text(
            'Do not approach an aggressive or frightened animal.',
            style: TextStyle(fontSize: 12, height: 1.4, color: grayText),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Log out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: alertRed,
        side: BorderSide(color: alertRed.withValues(alpha: 0.35)),
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // MOBILE HEADER
  // ============================================================

  Widget _buildMobileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Row(
        children: [
          _buildLogo(size: 40),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'PawLink',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: darkTeal,
              ),
            ),
          ),
          IconButton(
            onPressed: _showNotifications,
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded, color: darkText),
          ),
          _buildUserAvatar(),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE BOTTOM NAVIGATION
  // ============================================================

  Widget _buildMobileBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              _buildBottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: _selectedNav == 0,
                onTap: () {
                  setState(() {
                    _selectedNav = 0;
                  });
                },
              ),
              _buildBottomNavItem(
                icon: Icons.pets_rounded,
                label: 'My Pets',
                selected: _selectedNav == 1,
                onTap: _goToMyPets,
              ),
              _buildBottomNavItem(
                icon: Icons.campaign_rounded,
                label: 'Report',
                selected: _selectedNav == 2,
                onTap: _goToReports,
              ),
              _buildBottomNavItem(
                icon: Icons.location_city_rounded,
                label: 'Barangay',
                selected: _selectedNav == 3,
                onTap: _goToBarangay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: selected ? primaryTeal : grayText),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? darkTeal : grayText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN DASHBOARD
  // ============================================================

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 22),
              _buildHeroCard(),
              const SizedBox(height: 22),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 28),
              _buildPetsAndCommunitySection(),
              const SizedBox(height: 26),
              _buildSafetyReminder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = _auth.currentUser;

    String name = 'Pet Parent';

    if (user != null) {
      final displayName = user.displayName?.trim();

      if (displayName != null && displayName.isNotEmpty) {
        name = displayName;
      } else if (user.email != null && user.email!.isNotEmpty) {
        name = user.email!.split('@').first;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name! 🐾',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Keep your pets connected and help your community.',
          style: TextStyle(fontSize: 14, color: grayText),
        ),
      ],
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 600;

          final textSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'COMMUNITY PET CARE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'One place for your pets\nand your community.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Register your pet, manage its profile, '
                'and help report lost or found animals.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 17),
              FilledButton(
                onPressed: _goToRegisterPet,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: darkTeal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Register a Pet',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );

          final iconSection = Container(
            width: compact ? 90 : 150,
            height: compact ? 90 : 150,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets_rounded,
              size: compact ? 48 : 75,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSection,
                const SizedBox(height: 20),
                Align(alignment: Alignment.centerRight, child: iconSection),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: textSection),
              const SizedBox(width: 30),
              iconSection,
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 650;

        final cards = [
          _buildStatCard(
            title: 'My Pets',
            icon: Icons.pets_rounded,
            stream: _petService.getMyPetsCountStream(),
          ),
          _buildStatCard(
            title: 'QR Profiles',
            icon: Icons.qr_code_2_rounded,
            stream: _petService.getQrProfilesCountStream(),
          ),
          _buildStatCard(
            title: 'My Reports',
            icon: Icons.assignment_rounded,
            stream: _reportService.getMyReportsCountStream(),
          ),
          _buildFoundPetStatCard(),
        ];

        if (compact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 10),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Stream<int> stream,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: StreamBuilder<int>(
        stream: stream,
        builder: (context, snapshot) {
          final int count = snapshot.data ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: lightTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: primaryTeal, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: grayText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // FOUND REPORT COUNT
  // ============================================================

  Widget _buildFoundPetStatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _petService.getMyPetsStream(),
        builder: (context, petSnapshot) {
          if (petSnapshot.connectionState == ConnectionState.waiting) {
            return _buildStatCardContent(
              title: 'Found Reports',
              icon: Icons.favorite_rounded,
              count: 0,
              loading: true,
            );
          }

          if (petSnapshot.hasError ||
              !petSnapshot.hasData ||
              petSnapshot.data!.docs.isEmpty) {
            return _buildStatCardContent(
              title: 'Found Reports',
              icon: Icons.favorite_rounded,
              count: 0,
            );
          }

          final List<String> petIds = petSnapshot.data!.docs
              .map((doc) {
                final data = doc.data();
                final value = data['petId'];

                if (value != null && value.toString().trim().isNotEmpty) {
                  return value.toString().trim();
                }

                return doc.id;
              })
              .where((id) => id.isNotEmpty)
              .take(10)
              .toList();

          if (petIds.isEmpty) {
            return _buildStatCardContent(
              title: 'Found Reports',
              icon: Icons.favorite_rounded,
              count: 0,
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _reportService.getFoundReportsStream(petIds),
            builder: (context, reportSnapshot) {
              final int count = reportSnapshot.data?.docs.length ?? 0;

              return _buildStatCardContent(
                title: 'Found Reports',
                icon: Icons.favorite_rounded,
                count: count,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCardContent({
    required String title,
    required IconData icon,
    required int count,
    bool loading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFD97706), size: 20),
            ),
            const Spacer(),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryTeal,
                ),
              )
            else
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: grayText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 650;

            final actions = [
              _buildActionCard(
                icon: Icons.add_circle_outline_rounded,
                title: 'Register Pet',
                subtitle: 'Create a pet profile',
                color: primaryTeal,
                onTap: _goToRegisterPet,
              ),
              _buildActionCard(
                icon: Icons.search_rounded,
                title: 'Report Lost',
                subtitle: 'Report a missing pet',
                color: alertRed,
                onTap: _goToReports,
              ),
              _buildActionCard(
                icon: Icons.volunteer_activism_rounded,
                title: 'Found a Pet',
                subtitle: 'Help reunite a pet',
                color: const Color(0xFFD97706),
                onTap: _goToReports,
              ),
            ];

            if (compact) {
              return Column(
                children: [
                  actions[0],
                  const SizedBox(height: 10),
                  actions[1],
                  const SizedBox(height: 10),
                  actions[2],
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: actions[0]),
                const SizedBox(width: 12),
                Expanded(child: actions[1]),
                const SizedBox(width: 12),
                Expanded(child: actions[2]),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: grayText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: grayText),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PETS SECTION
  // ============================================================

  Widget _buildPetsAndCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'My Pets',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
            ),
            TextButton(
              onPressed: _goToMyPets,
              child: const Text(
                'View all',
                style: TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildPetsStream(),
      ],
    );
  }

  Widget _buildPetsStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _petService.getMyPetsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildEmptyCard(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load your pets',
            subtitle: 'Please try again later.',
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyPetsCard();
        }

        final pets = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 650;

            if (compact) {
              return Column(
                children: pets.take(3).map((doc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPetCard(doc),
                  );
                }).toList(),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: pets.take(3).map((doc) {
                return SizedBox(
                  width: (constraints.maxWidth - 24) / 3,
                  child: _buildPetCard(doc),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // PET CARD
  // ============================================================

  Widget _buildPetCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final String petId = (data['petId'] ?? doc.id).toString();

    final String petName = (data['petName'] ?? 'Pet').toString();

    final String breed = (data['breed'] ?? 'Breed not specified').toString();

    final String status = (data['status'] ?? 'alive').toString();

    final String photoUrl = (data['photoUrl'] ?? '').toString();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: petId.isEmpty ? null : () => _openPetProfile(petId),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _buildPetPhoto(
                photoUrl: photoUrl.isEmpty ? null : photoUrl,
                size: 58,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      breed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: grayText),
                    ),
                    const SizedBox(height: 7),
                    _buildStatusBadge(status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: grayText),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY / LOADING CARDS
  // ============================================================

  Widget _buildEmptyPetsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: lightTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets_rounded, color: primaryTeal, size: 28),
          ),
          const SizedBox(height: 13),
          const Text(
            'No pets registered yet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: darkText,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Add your first pet to create its PawLink profile and QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.4, color: grayText),
          ),
          const SizedBox(height: 15),
          FilledButton.icon(
            onPressed: _goToRegisterPet,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Register Pet'),
            style: FilledButton.styleFrom(
              backgroundColor: primaryTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: grayText),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: grayText),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: const Center(child: CircularProgressIndicator(color: primaryTeal)),
    );
  }

  // ============================================================
  // PET PHOTO
  // ============================================================

  Widget _buildPetPhoto({required String? photoUrl, required double size}) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.network(
          photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPetPlaceholder(size);
          },
        ),
      );
    }

    return _buildPetPlaceholder(size);
  }

  Widget _buildPetPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(Icons.pets_rounded, color: primaryTeal, size: size * 0.45),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(String status) {
    final String normalized = status.toLowerCase();

    Color background = lightTeal;
    Color foreground = darkTeal;

    if (normalized.contains('lost')) {
      background = alertRed.withValues(alpha: 0.10);
      foreground = alertRed;
    } else if (normalized.contains('dead')) {
      background = Colors.grey.withValues(alpha: 0.12);
      foreground = Colors.grey.shade700;
    } else if (normalized.contains('found')) {
      background = const Color(0xFFFFF4E5);
      foreground = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  // ============================================================
  // SAFETY REMINDER
  // ============================================================

  Widget _buildSafetyReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'If an animal looks aggressive, injured, or scared, '
                  'keep your distance. Do not try to catch it. '
                  'Send the location and details instead.',
                  style: TextStyle(fontSize: 12, height: 1.45, color: grayText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _goToRegisterPet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPetPage()),
    );
  }

  void _goToMyPets() {
    setState(() {
      _selectedNav = 1;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyPetsPage()),
    );
  }

  void _goToReports() {
    setState(() {
      _selectedNav = 2;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportPage()),
    );
  }

  void _goToBarangay() {
    setState(() {
      _selectedNav = 3;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarangayPage()),
    );
  }

  // ============================================================
  // MY ACCOUNT
  // ============================================================

  void _goToMyAccount() {
    setState(() {
      _selectedNav = 4;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyAccountPage()),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  void _goToSettings() {
    setState(() {
      _selectedNav = 5;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  // ============================================================
  // PET PROFILE
  // ============================================================

  void _openPetProfile(String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PetProfilePage(petId: petId)),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: primaryTeal,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You have no new notifications.',
                          style: TextStyle(fontSize: 13, color: darkText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Log out?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Are you sure you want to log out of PawLink?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel', style: TextStyle(color: grayText)),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(backgroundColor: alertRed),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await _auth.signOut();
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.pets_rounded, color: primaryTeal, size: size * 0.55),
    );
  }

  // ============================================================
  // USER AVATAR
  // ============================================================

  Widget _buildUserAvatar() {
    final user = _auth.currentUser;

    final String? photoUrl = user?.photoURL;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(radius: 18, backgroundImage: NetworkImage(photoUrl));
    }

    String letter = 'P';

    final String? displayName = user?.displayName;

    if (displayName != null && displayName.trim().isNotEmpty) {
      letter = displayName.trim()[0].toUpperCase();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      letter = user.email!.trim()[0].toUpperCase();
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: lightTeal,
      child: Text(
        letter,
        style: const TextStyle(color: darkTeal, fontWeight: FontWeight.w800),
      ),
    );
  }
}
