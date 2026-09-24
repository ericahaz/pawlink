import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/pet_service.dart';
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
  bool _isDeleting = false;

  // ============================================================
  // UPDATE PET STATUS
  // ============================================================

  Future<void> _updatePetStatus(String currentStatus) async {
    final newStatus = currentStatus.toLowerCase() == 'alive' ? 'dead' : 'alive';

    if (newStatus == 'dead') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Mark pet as deceased?',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: const Text(
              'If you mark this pet as deceased, the pet profile '
              'will be permanently removed from PawLink.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _petService.updatePetStatus(petId: widget.petId, status: newStatus);

      if (!mounted) return;

      if (newStatus == 'dead') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet profile removed.'),
            backgroundColor: Color(0xFF0F766E),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      } else {
        _showMessage('Pet status updated to Alive.', success: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to update pet status.');
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
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete pet profile?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'This will permanently remove this pet from PawLink. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _petService.deletePet(widget.petId);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet profile deleted.'),
          backgroundColor: Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to delete the pet profile.');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
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
      MaterialPageRoute(
        builder: (context) {
          return JointOwnersPage(petId: widget.petId);
        },
      ),
    );
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
          backgroundColor: success
              ? const Color(0xFF0F766E)
              : const Color(0xFFDC2626),
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
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          'Pet Profile',
          style: TextStyle(
            color: Color(0xFF243333),
            fontWeight: FontWeight.w800,
          ),
        ),

        iconTheme: const IconThemeData(color: Color(0xFF243333)),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),

            onSelected: (value) {
              if (value == 'delete') {
                _deletePet();
              }
            },

            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete pet',
                        style: TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _petService.getPetStream(widget.petId),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F766E)),
            );
          }

          if (snapshot.hasError) {
            return _buildError();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNotFound();
          }

          final data = snapshot.data!.data() ?? {};

          return _buildProfile(data);
        },
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfile(Map<String, dynamic> data) {
    final petName = (data['petName'] ?? 'Unnamed Pet').toString();

    final petId = (data['petId'] ?? widget.petId).toString();

    final breed = (data['breed'] ?? 'Unknown breed').toString();

    final color = (data['color'] ?? 'Not provided').toString();

    final age = (data['age'] ?? 'Not provided').toString();

    final ownerName = (data['ownerName'] ?? 'Not provided').toString();

    final ownerContact = (data['ownerContact'] ?? 'Not provided').toString();

    final status = (data['status'] ?? 'alive').toString();

    final photoUrl = (data['photoUrl'] ?? '').toString();

    final qrEnabled = data['qrEnabled'] != false;

    final ownerIds = (data['ownerIds'] as List<dynamic>? ?? [])
        .map((id) => id.toString())
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 20,
            vertical: 24,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),

              child: isDesktop
                  ? _buildDesktopLayout(
                      petName: petName,
                      petId: petId,
                      breed: breed,
                      color: color,
                      age: age,
                      ownerName: ownerName,
                      ownerContact: ownerContact,
                      status: status,
                      photoUrl: photoUrl,
                      qrEnabled: qrEnabled,
                      ownerCount: ownerIds.length,
                    )
                  : _buildMobileLayout(
                      petName: petName,
                      petId: petId,
                      breed: breed,
                      color: color,
                      age: age,
                      ownerName: ownerName,
                      ownerContact: ownerContact,
                      status: status,
                      photoUrl: photoUrl,
                      qrEnabled: qrEnabled,
                      ownerCount: ownerIds.length,
                    ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout({
    required String petName,
    required String petId,
    required String breed,
    required String color,
    required String age,
    required String ownerName,
    required String ownerContact,
    required String status,
    required String photoUrl,
    required bool qrEnabled,
    required int ownerCount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildPetHeader(
                petName: petName,
                breed: breed,
                photoUrl: photoUrl,
                status: status,
              ),

              const SizedBox(height: 20),

              _buildDetailsCard(
                petId: petId,
                breed: breed,
                color: color,
                age: age,
                ownerName: ownerName,
                ownerContact: ownerContact,
              ),

              const SizedBox(height: 20),

              _buildOwnerCard(ownerCount: ownerCount),

              const SizedBox(height: 20),

              _buildStatusCard(status),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 4,
          child: _buildQrCard(petId: petId, qrEnabled: qrEnabled),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout({
    required String petName,
    required String petId,
    required String breed,
    required String color,
    required String age,
    required String ownerName,
    required String ownerContact,
    required String status,
    required String photoUrl,
    required bool qrEnabled,
    required int ownerCount,
  }) {
    return Column(
      children: [
        _buildPetHeader(
          petName: petName,
          breed: breed,
          photoUrl: photoUrl,
          status: status,
        ),

        const SizedBox(height: 20),

        _buildQrCard(petId: petId, qrEnabled: qrEnabled),

        const SizedBox(height: 20),

        _buildDetailsCard(
          petId: petId,
          breed: breed,
          color: color,
          age: age,
          ownerName: ownerName,
          ownerContact: ownerContact,
        ),

        const SizedBox(height: 20),

        _buildOwnerCard(ownerCount: ownerCount),

        const SizedBox(height: 20),

        _buildStatusCard(status),

        const SizedBox(height: 20),
      ],
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
  }) {
    final isAlive = status.toLowerCase() == 'alive';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E5E3)),
      ),

      child: Row(
        children: [
          _buildPetImage(photoUrl, size: 90),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: isAlive
                        ? const Color(0xFFE7F5F2)
                        : const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    isAlive ? 'ACTIVE PROFILE' : 'INACTIVE',

                    style: TextStyle(
                      color: isAlive
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFDC2626),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  petName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF243333),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  breed,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF667373),
                    fontSize: 14,
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
  // PET IMAGE
  // ============================================================

  Widget _buildPetImage(String photoUrl, {double size = 90}) {
    if (photoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          color: const Color(0xFFE7F5F2),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Icon(
          Icons.pets_rounded,
          size: size * .42,
          color: const Color(0xFF0F766E),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),

      child: Image.network(
        photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,

        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,

            color: const Color(0xFFE7F5F2),

            child: Icon(
              Icons.pets_rounded,
              size: size * .42,
              color: const Color(0xFF0F766E),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // QR CARD
  // ============================================================

  Widget _buildQrCard({required String petId, required bool qrEnabled}) {
    final publicUrl = 'https://pawlink-pet-2026.web.app/p/$petId';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E5E3)),
      ),

      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pet QR Code',
              style: TextStyle(
                color: Color(0xFF243333),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 5),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Scan this code to open the public pet profile.',
              style: TextStyle(
                color: Color(0xFF667373),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (qrEnabled)
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE3E5E3)),
              ),

              child: QrImageView(
                data: publicUrl,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            )
          else
            Container(
              height: 220,
              width: 220,
              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F4),
                borderRadius: BorderRadius.circular(14),
              ),

              child: const Text(
                'QR code disabled',
                style: TextStyle(
                  color: Color(0xFF667373),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),

            decoration: BoxDecoration(
              color: const Color(0xFFE7F5F2),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              children: [
                const Text(
                  'PET ID',
                  style: TextStyle(
                    color: Color(0xFF667373),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  petId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF115E59),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'The QR code belongs to this pet profile. '
            'All co-owners use the same QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF667373),
              fontSize: 12,
              height: 1.4,
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
    required String ownerName,
    required String ownerContact,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Pet Information',
            style: TextStyle(
              color: Color(0xFF243333),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(Icons.badge_outlined, 'Pet ID', petId),

          _buildInfoRow(Icons.pets_outlined, 'Breed', breed),

          _buildInfoRow(Icons.palette_outlined, 'Color', color),

          _buildInfoRow(Icons.cake_outlined, 'Age', age),

          const Divider(height: 26),

          _buildInfoRow(
            Icons.person_outline_rounded,
            'Primary Owner',
            ownerName,
          ),

          _buildInfoRow(Icons.phone_outlined, 'Contact', ownerContact),
        ],
      ),
    );
  }

  // ============================================================
  // OWNER CARD
  // ============================================================

  Widget _buildOwnerCard({required int ownerCount}) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5F2),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.people_outline_rounded,
                  color: Color(0xFF0F766E),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Joint Owners',
                      style: TextStyle(
                        color: Color(0xFF243333),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      ownerCount == 1
                          ? '1 owner connected'
                          : '$ownerCount owners connected',

                      style: const TextStyle(
                        color: Color(0xFF667373),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton.icon(
                onPressed: _openJointOwners,
                icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                label: const Text('Manage'),

                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Invite another person to access this same pet profile. '
            'The Pet ID and QR code will remain the same.',
            style: TextStyle(
              color: Color(0xFF667373),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard(String status) {
    final isAlive = status.toLowerCase() == 'alive';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Pet Status',
            style: TextStyle(
              color: Color(0xFF243333),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: isAlive
                  ? const Color(0xFFE7F5F2)
                  : const Color(0xFFFDECEC),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [
                Icon(
                  isAlive ? Icons.favorite_rounded : Icons.heart_broken_rounded,

                  color: isAlive
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFDC2626),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    isAlive ? 'Alive' : 'Deceased',

                    style: TextStyle(
                      color: isAlive
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: _isUpdatingStatus
                  ? null
                  : () {
                      _updatePetStatus(status);
                    },

              icon: _isUpdatingStatus
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isAlive
                          ? Icons.heart_broken_outlined
                          : Icons.favorite_outline,
                    ),

              label: Text(isAlive ? 'Mark as Deceased' : 'Mark as Alive'),

              style: OutlinedButton.styleFrom(
                foregroundColor: isAlive
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF0F766E),

                side: BorderSide(
                  color: isAlive
                      ? const Color(0xFFF0B5B5)
                      : const Color(0xFF9CCFC8),
                ),

                padding: const EdgeInsets.symmetric(vertical: 13),

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

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E5E3)),
      ),

      child: child,
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, size: 20, color: const Color(0xFF0F766E)),

          const SizedBox(width: 12),

          SizedBox(
            width: 105,

            child: Text(
              label,

              style: const TextStyle(
                color: Color(0xFF667373),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(
                color: Color(0xFF243333),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),

        child: Text(
          'Unable to load this pet profile right now.',
          textAlign: TextAlign.center,

          style: TextStyle(color: Color(0xFF667373)),
        ),
      ),
    );
  }

  // ============================================================
  // NOT FOUND
  // ============================================================

  Widget _buildNotFound() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),

        child: Text(
          'This pet profile could not be found.',
          textAlign: TextAlign.center,

          style: TextStyle(color: Color(0xFF667373)),
        ),
      ),
    );
  }
}
