import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/pet_service.dart';
import '../../widgets/qr_card.dart';
import 'joint_owners_page.dart';

class PetProfilePage extends StatefulWidget {
  final String petId;

  const PetProfilePage({super.key, required this.petId});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final PetService _petService = PetService();

  bool _isUpdatingStatus = false;
  bool _isUpdatingSafety = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  static const Color safeGreen = Color(0xFF16A34A);
  static const Color cautionYellow = Color(0xFFF59E0B);
  static const Color aggressiveRed = Color(0xFFDC2626);

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _updatePetStatus(String currentStatus) async {
    final isAlive = currentStatus.toLowerCase() == 'alive';

    if (!isAlive) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Mark Pet as Deceased?',
            style: TextStyle(fontWeight: FontWeight.w800, color: darkText),
          ),
          content: const Text(
            'If you continue, this pet profile will be permanently removed '
            'from the database. The stored pet photo will also be deleted.',
            style: TextStyle(color: grayText, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: aggressiveRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete Pet'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _petService.updatePetStatus(petId: widget.petId, status: 'dead');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile permanently deleted.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to delete pet: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE PET
  // ============================================================

  Future<void> _deletePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Pet Profile?',
            style: TextStyle(fontWeight: FontWeight.w800, color: darkText),
          ),
          content: const Text(
            'This will permanently delete the pet profile from the '
            'database. This action cannot be undone.',
            style: TextStyle(color: grayText, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: aggressiveRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _petService.deletePet(widget.petId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile deleted successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to delete pet: $e')));
    }
  }

  // ============================================================
  // UPDATE SAFETY TAG
  // ============================================================

  Future<void> _updateSafetyTag(String currentSafetyTag) async {
    String selectedTag = _normalizeSafetyTag(currentSafetyTag);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Update Safety Level',
                style: TextStyle(fontWeight: FontWeight.w800, color: darkText),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSafetyOption(
                    value: 'safe',
                    selectedValue: selectedTag,
                    icon: Icons.check_circle_rounded,
                    title: 'Safe',
                    description: 'Normal behavior. Safe to approach with care.',
                    color: safeGreen,
                    onTap: () {
                      setDialogState(() {
                        selectedTag = 'safe';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSafetyOption(
                    value: 'caution',
                    selectedValue: selectedTag,
                    icon: Icons.warning_amber_rounded,
                    title: 'Caution',
                    description:
                        'Be careful. Pet may be frightened or nervous.',
                    color: cautionYellow,
                    onTap: () {
                      setDialogState(() {
                        selectedTag = 'caution';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSafetyOption(
                    value: 'aggressive',
                    selectedValue: selectedTag,
                    icon: Icons.do_not_touch_rounded,
                    title: 'Aggressive / Do Not Approach',
                    description:
                        'Do not approach. Report the pet to the barangay.',
                    color: aggressiveRed,
                    onTap: () {
                      setDialogState(() {
                        selectedTag = 'aggressive';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, selectedTag),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result == _normalizeSafetyTag(currentSafetyTag)) {
      return;
    }

    setState(() {
      _isUpdatingSafety = true;
    });

    try {
      await _petService.updatePetSafetyTag(
        petId: widget.petId,
        safetyTag: result,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safety level updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update safety level: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingSafety = false;
        });
      }
    }
  }

  // ============================================================
  // OPEN JOINT OWNERS
  // ============================================================

  void _openJointOwners() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JointOwnersPage(petId: widget.petId)),
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
          icon: const Icon(Icons.arrow_back_rounded, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pet Profile',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: darkText),
            onSelected: (value) {
              if (value == 'delete') {
                _deletePet();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: aggressiveRed),
                    SizedBox(width: 10),
                    Text('Delete Pet'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
            return _buildErrorState(
              'Something went wrong while loading this pet.',
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildErrorState('This pet profile no longer exists.');
          }

          final data = snapshot.data!.data();

          if (data == null) {
            return _buildErrorState('No pet information was found.');
          }

          return _buildProfile(data);
        },
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfile(Map<String, dynamic> data) {
    final String petName = data['petName']?.toString() ?? 'Unnamed Pet';
    final String petId = data['petId']?.toString() ?? widget.petId;
    final String breed = data['breed']?.toString() ?? 'Unknown breed';
    final String petColor = data['color']?.toString() ?? 'Not specified';
    final String age = data['age']?.toString() ?? 'Not specified';

    final String ownerName = data['ownerName']?.toString() ?? 'Primary owner';

    final String ownerContact =
        data['ownerContact']?.toString() ?? 'No contact available';

    final String status = data['status']?.toString().toLowerCase() ?? 'alive';

    final String safetyTag = _normalizeSafetyTag(data['safetyTag']?.toString());

    final String photoUrl = data['photoUrl']?.toString() ?? '';

    final bool qrEnabled = data['qrEnabled'] == true;

    final List<dynamic> rawOwnerIds = data['ownerIds'] is List
        ? data['ownerIds'] as List
        : [];

    final List<String> ownerIds = rawOwnerIds
        .map((id) => id.toString())
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : 16,
            20,
            isDesktop ? 40 : 16,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildPetHeader(
                                petName: petName,
                                breed: breed,
                                photoUrl: photoUrl,
                                status: status,
                                safetyTag: safetyTag,
                              ),
                              const SizedBox(height: 18),
                              _buildDetailsCard(
                                petId: petId,
                                breed: breed,
                                color: petColor,
                                age: age,
                              ),
                              const SizedBox(height: 18),
                              _buildOwnerCard(
                                ownerName: ownerName,
                                ownerContact: ownerContact,
                                ownerIds: ownerIds,
                              ),
                              const SizedBox(height: 18),
                              _buildSafetyCard(safetyTag),
                              const SizedBox(height: 18),
                              _buildStatusCard(status),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              QrCard(petId: petId, qrEnabled: qrEnabled),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildPetHeader(
                          petName: petName,
                          breed: breed,
                          photoUrl: photoUrl,
                          status: status,
                          safetyTag: safetyTag,
                        ),
                        const SizedBox(height: 18),
                        QrCard(petId: petId, qrEnabled: qrEnabled),
                        const SizedBox(height: 18),
                        _buildDetailsCard(
                          petId: petId,
                          breed: breed,
                          color: petColor,
                          age: age,
                        ),
                        const SizedBox(height: 18),
                        _buildOwnerCard(
                          ownerName: ownerName,
                          ownerContact: ownerContact,
                          ownerIds: ownerIds,
                        ),
                        const SizedBox(height: 18),
                        _buildSafetyCard(safetyTag),
                        const SizedBox(height: 18),
                        _buildStatusCard(status),
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
    required String breed,
    required String photoUrl,
    required String status,
    required String safetyTag,
  }) {
    final bool isAlive = status == 'alive';
    final Color safetyColor = _getSafetyColor(safetyTag);

    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPetPhoto(photoUrl, size: 82),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        petName,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: darkText,
                        ),
                      ),
                    ),
                    _buildStatusBadge(
                      text: isAlive ? 'Alive' : 'Deceased',
                      color: isAlive ? safeGreen : aggressiveRed,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  breed,
                  style: const TextStyle(
                    fontSize: 14,
                    color: grayText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: safetyColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: safetyColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getSafetyIcon(safetyTag),
                        size: 16,
                        color: safetyColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getSafetyLabel(safetyTag),
                        style: TextStyle(
                          color: safetyColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
  // DETAILS CARD
  // ============================================================

  Widget _buildDetailsCard({
    required String petId,
    required String breed,
    required String color,
    required String age,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.pets_rounded,
            title: 'Pet Information',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Pet ID',
            value: petId,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.category_outlined,
            label: 'Breed',
            value: breed,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.palette_outlined,
            label: 'Color',
            value: color,
          ),
          _buildDivider(),
          _buildInfoRow(icon: Icons.cake_outlined, label: 'Age', value: age),
        ],
      ),
    );
  }

  // ============================================================
  // OWNER CARD
  // ============================================================

  Widget _buildOwnerCard({
    required String ownerName,
    required String ownerContact,
    required List<String> ownerIds,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle(
                  icon: Icons.people_alt_outlined,
                  title: 'Owners',
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openJointOwners,
                icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                label: const Text('Manage'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryTeal,
                  side: const BorderSide(color: primaryTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Primary Owner',
            value: ownerName,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Contact',
            value: ownerContact,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.group_outlined,
            label: 'Linked Accounts',
            value: '${ownerIds.length}',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAFETY CARD
  // ============================================================

  Widget _buildSafetyCard(String safetyTag) {
    final Color color = _getSafetyColor(safetyTag);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionTitle(
                  icon: Icons.shield_outlined,
                  title: 'Safety Level',
                ),
              ),
              if (_isUpdatingSafety)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryTeal,
                  ),
                )
              else
                TextButton(
                  onPressed: () => _updateSafetyTag(safetyTag),
                  child: const Text('Update'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSafetyIcon(safetyTag),
                    color: color,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSafetyLabel(safetyTag),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSafetyDescription(safetyTag),
                        style: const TextStyle(
                          color: grayText,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (safetyTag == 'aggressive') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: aggressiveRed.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: aggressiveRed,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Do not approach or attempt to handle the pet. '
                      'If assistance is needed, use the report feature '
                      'to notify the barangay.',
                      style: TextStyle(
                        color: aggressiveRed,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard(String status) {
    final bool isAlive = status == 'alive';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.favorite_border_rounded,
            title: 'Pet Status',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: (isAlive ? safeGreen : aggressiveRed).withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(
                  isAlive
                      ? Icons.favorite_rounded
                      : Icons.remove_circle_outline_rounded,
                  color: isAlive ? safeGreen : aggressiveRed,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAlive
                        ? 'This pet is currently marked as alive.'
                        : 'This pet is marked as deceased.',
                    style: const TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAlive) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUpdatingStatus
                    ? null
                    : () => _updatePetStatus(status),
                icon: _isUpdatingStatus
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_forever_outlined),
                label: const Text('Mark as Deceased & Delete Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: aggressiveRed,
                  side: const BorderSide(color: aggressiveRed),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SAFETY OPTION
  // ============================================================

  Widget _buildSafetyOption({
    required String value,
    required String selectedValue,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool selected = value == selectedValue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? color : darkText,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: grayText,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedValue,
              onChanged: (_) => onTap(),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.circle, color: Colors.transparent),
        ),
        Transform.translate(
          offset: const Offset(-36, 0),
          child: Icon(icon, color: primaryTeal, size: 20),
        ),
        Transform.translate(
          offset: const Offset(-26, 0),
          child: Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryTeal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: grayText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(height: 1, color: borderColor),
    );
  }

  // ============================================================
  // PET PHOTO
  // ============================================================

  Widget _buildPetPhoto(String photoUrl, {required double size}) {
    if (photoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: lightTeal,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.pets_rounded, color: primaryTeal, size: 38),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: lightTeal,
            child: const Icon(Icons.pets_rounded, color: primaryTeal, size: 38),
          );
        },
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.pets_outlined,
                color: primaryTeal,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SAFETY HELPERS
  // ============================================================

  String _normalizeSafetyTag(String? value) {
    final tag = value?.toLowerCase().trim();

    switch (tag) {
      case 'safe':
        return 'safe';

      case 'caution':
      case 'yellow':
        return 'caution';

      case 'aggressive':
      case 'red':
        return 'aggressive';

      default:
        return 'safe';
    }
  }

  Color _getSafetyColor(String safetyTag) {
    switch (_normalizeSafetyTag(safetyTag)) {
      case 'caution':
        return cautionYellow;

      case 'aggressive':
        return aggressiveRed;

      case 'safe':
      default:
        return safeGreen;
    }
  }

  IconData _getSafetyIcon(String safetyTag) {
    switch (_normalizeSafetyTag(safetyTag)) {
      case 'caution':
        return Icons.warning_amber_rounded;

      case 'aggressive':
        return Icons.do_not_touch_rounded;

      case 'safe':
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _getSafetyLabel(String safetyTag) {
    switch (_normalizeSafetyTag(safetyTag)) {
      case 'caution':
        return 'CAUTION';

      case 'aggressive':
        return 'AGGRESSIVE • DO NOT APPROACH';

      case 'safe':
      default:
        return 'SAFE';
    }
  }

  String _getSafetyDescription(String safetyTag) {
    switch (_normalizeSafetyTag(safetyTag)) {
      case 'caution':
        return 'Be careful. This pet may be frightened, nervous, or defensive.';

      case 'aggressive':
        return 'Do not approach or attempt to handle this pet. Notify the barangay if assistance is needed.';

      case 'safe':
      default:
        return 'No special safety warning has been reported for this pet.';
    }
  }
}
