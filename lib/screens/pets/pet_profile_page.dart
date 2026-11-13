import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../seasonal/seasonal_controller.dart';
import '../../services/pet_service.dart';
import '../../widgets/qr_card.dart';
import 'edit_pet_page.dart';
import 'joint_owners_page.dart';

class PetProfilePage extends StatefulWidget {
  final String petId;

  const PetProfilePage({super.key, required this.petId});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final PetService _petService = PetService();

  // ============================================================
  // SCROLL + KEYBOARD
  // ============================================================

  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  // ============================================================
  // COLORS
  // ============================================================

  static Color get primaryTeal =>
      SeasonalController.instance.activeTheme?.primary ??
      Color(0xFF0F766E);

  static Color get darkTeal =>
      SeasonalController.instance.activeTheme?.secondary ??
      Color(0xFF115E59);

  static Color get deepTeal =>
      SeasonalController.instance.activeTheme?.secondary ??
      Color(0xFF103B38);

  static Color get darkText =>
      SeasonalController.instance.activeTheme?.textPrimary ??
      Color(0xFF243333);

  static Color get grayText =>
      SeasonalController.instance.activeTheme?.textSecondary ??
      Color(0xFF667373);

  static Color get lightTeal {
    final theme = SeasonalController.instance.activeTheme;
    if (theme == null) return Color(0xFFE7F5F2);
    return Color.alphaBlend(theme.primary.withValues(alpha: 0.10), theme.surface);
  }

  static Color get softerTeal {
    final theme = SeasonalController.instance.activeTheme;
    if (theme == null) return Color(0xFFF0F8F6);
    return Color.alphaBlend(theme.primary.withValues(alpha: 0.05), theme.surface);
  }

  static Color get warmBackground =>
      SeasonalController.instance.activeTheme?.background ??
      Color(0xFFFFFBF5);

  static Color get borderColor =>
      SeasonalController.instance.activeTheme?.border ??
      Color(0xFFE3E5E3);

  static Color get surfaceColor =>
      SeasonalController.instance.activeTheme?.surface ?? Colors.white;

  static Color get onPrimaryColor =>
      SeasonalController.instance.activeTheme?.onPrimary ?? Colors.white;

  static const Color alertRed = Color(0xFFDC2626);
  static const Color cautionOrange = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();

    // Automatically place keyboard focus on the page so that
    // arrow-key scrolling works without clicking the page first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // KEYBOARD SCROLLING
  // ============================================================

  KeyEventResult _handleKeyboardEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (!_scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    final double currentOffset = _scrollController.offset;
    final double maxOffset = _scrollController.position.maxScrollExtent;
    final double viewportHeight =
        _scrollController.position.viewportDimension;

    double? targetOffset;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      targetOffset = currentOffset + 70;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      targetOffset = currentOffset - 70;
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      targetOffset = currentOffset + viewportHeight * 0.85;
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      targetOffset = currentOffset - viewportHeight * 0.85;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      targetOffset = 0;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      targetOffset = maxOffset;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        targetOffset = currentOffset - viewportHeight * 0.85;
      } else {
        targetOffset = currentOffset + viewportHeight * 0.85;
      }
    }

    if (targetOffset == null) {
      return KeyEventResult.ignored;
    }

    final double clampedOffset = targetOffset.clamp(0, maxOffset);

    _scrollController.animateTo(
      clampedOffset,
      duration: Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );

    return KeyEventResult.handled;
  }

  // ============================================================
  // EDIT PET INFORMATION
  // ============================================================

  Future<void> _openEditPet() async {
    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditPetPage(petId: widget.petId)),
    );

    if (!mounted || updated != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pet information updated successfully.')),
    );
  }

  // ============================================================
  // CHANGE SAFETY LEVEL
  // ============================================================

  Future<void> _changeSafetyLevel(String currentSafetyTag) async {
    final String normalizedCurrent = _normalizeSafetyTag(currentSafetyTag);

    String selectedSafety = normalizedCurrent;

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: warmBackground,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 12),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lightTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shield_outlined,
                        color: primaryTeal,
                        size: 21,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Change Safety Level',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose the level that best describes your pet right now.',
                      style: TextStyle(
                        color: grayText,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSafetyOption(
                    value: 'safe',
                    title: 'Safe',
                    description: 'Currently safe to approach.',
                    icon: Icons.verified_user_outlined,
                    color: primaryTeal,
                    selectedValue: selectedSafety,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedSafety = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  _buildSafetyOption(
                    value: 'caution',
                    title: 'Caution',
                    description: 'Approach carefully and give space.',
                    icon: Icons.warning_amber_rounded,
                    color: cautionOrange,
                    selectedValue: selectedSafety,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedSafety = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  _buildSafetyOption(
                    value: 'aggressive',
                    title: 'Aggressive / Do Not Approach',
                    description:
                        'Avoid approaching. Report or notify the barangay.',
                    icon: Icons.shield_outlined,
                    color: alertRed,
                    selectedValue: selectedSafety,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedSafety = value;
                      });
                    },
                  ),
                ],
              ),
              actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 18),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: grayText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, selectedSafety);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: onPrimaryColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result == normalizedCurrent) {
      return;
    }

    try {
      await _petService.updatePetSafetyTag(
        petId: widget.petId,
        safetyTag: result,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Safety level changed to ${_safetyLabel(result)}.'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update safety level: $e')),
      );
    }
  }

  // ============================================================
  // SAFETY OPTION
  // ============================================================

  Widget _buildSafetyOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    final bool selected = selectedValue == value;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 160),
        width: double.infinity,
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : borderColor,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: color, size: 21)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: grayText,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? color : grayText,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHANGE PET STATUS
  // ============================================================

  Future<void> _changePetStatus(String currentStatus) async {
    final String normalizedStatus = currentStatus.toLowerCase().trim();

    final bool isCurrentlyAlive = normalizedStatus != 'dead';

    if (isCurrentlyAlive) {
      await _showAliveStatusOptions();
    }
  }

  // ============================================================
  // ALIVE STATUS OPTIONS
  // ============================================================

  Future<void> _showAliveStatusOptions() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: warmBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 12),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite_outline_rounded,
                    color: primaryTeal,
                    size: 21,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Update Pet Status',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose the current status of your pet.',
                  style: TextStyle(color: grayText, fontSize: 13, height: 1.4),
                ),
              ),
              SizedBox(height: 16),
              _buildStatusOption(
                dialogContext: dialogContext,
                title: 'Alive',
                description: 'Keep the pet profile active.',
                icon: Icons.favorite_rounded,
                color: primaryTeal,
                background: lightTeal,
                value: 'alive',
              ),
              SizedBox(height: 10),
              _buildStatusOption(
                dialogContext: dialogContext,
                title: 'Mark as Deceased',
                description: 'Permanently remove this pet profile.',
                icon: Icons.heart_broken_rounded,
                color: alertRed,
                background: Color(0xFFFFEEEE),
                value: 'dead',
              ),
            ],
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: grayText, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    if (result == 'alive') {
      await _setAliveStatus();
      return;
    }

    if (result == 'dead') {
      await _confirmDeceasedStatus();
    }
  }

  Widget _buildStatusOption({
    required BuildContext dialogContext,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color background,
    required String value,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pop(dialogContext, value);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: color, size: 21)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: grayText,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SET ALIVE
  // ============================================================

  Future<void> _setAliveStatus() async {
    try {
      await _petService.updatePetStatus(petId: widget.petId, status: 'alive');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet status updated to Alive.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update pet status: $e')),
      );
    }
  }

  // ============================================================
  // CONFIRM DECEASED
  // ============================================================

  Future<void> _confirmDeceasedStatus() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: warmBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 12),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: alertRed,
                    size: 22,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mark Pet as Deceased?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: alertRed.withValues(alpha: 0.16)),
            ),
            child: Text(
              'This action will permanently remove the pet profile '
              'from PawLink and delete its stored photo. The pet '
              'profile cannot be restored after this action.',
              style: TextStyle(color: grayText, fontSize: 13, height: 1.5),
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: grayText, fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: alertRed,
                foregroundColor: onPrimaryColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Yes, Remove Profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _petService.updatePetStatus(petId: widget.petId, status: 'dead');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pet profile has been permanently removed.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update pet status: $e')),
      );
    }
  }

  // ============================================================
  // DELETE PET
  // ============================================================

  Future<void> _deletePet() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: warmBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 12),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: alertRed,
                    size: 21,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Pet Profile?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'This will permanently remove the pet profile and its '
            'stored photo. This action cannot be undone.',
            style: TextStyle(color: grayText, fontSize: 13, height: 1.45),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: grayText, fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: alertRed,
                foregroundColor: onPrimaryColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
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

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet profile deleted successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete pet profile: $e')),
      );
    }
  }

  // ============================================================
  // JOINT OWNERS
  // ============================================================

  Future<void> _openJointOwners() async {
    await Navigator.push(
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
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: darkText),
        ),
        title: Text(
          'Pet Profile',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Pet Information',
            onPressed: _openEditPet,
            icon: Icon(Icons.edit_outlined, color: darkText),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: Icon(Icons.more_vert_rounded, color: darkText),
            onSelected: (value) {
              if (value == 'delete') {
                _deletePet();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: alertRed),
                      SizedBox(width: 10),
                      Text(
                        'Delete Pet',
                        style: TextStyle(
                          color: alertRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyboardEvent,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _petService.getPetStream(widget.petId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryTeal),
              );
            }

            if (snapshot.hasError) {
              return _buildMessageState(
                icon: Icons.error_outline_rounded,
                title: 'Unable to load pet profile',
                message: snapshot.error.toString(),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildMessageState(
                icon: Icons.pets_outlined,
                title: 'Pet profile not found',
                message: 'This pet profile may have been deleted.',
              );
            }

            final Map<String, dynamic> data = snapshot.data!.data()!;

            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop = constraints.maxWidth >= 900;

                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: isDesktop,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 40 : 16,
                      20,
                      isDesktop ? 40 : 16,
                      48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPetHeader(data),
                            SizedBox(height: 16),
                            _buildEditButton(),
                            SizedBox(height: 20),
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildDetailsCard(data),
                                        SizedBox(height: 18),
                                        _buildSafetyCard(data),
                                        SizedBox(height: 18),
                                        _buildStatusCard(data),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildQrCard(data),
                                        SizedBox(height: 18),
                                        _buildJointOwnersCard(data),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildDetailsCard(data),
                                  SizedBox(height: 18),
                                  _buildSafetyCard(data),
                                  SizedBox(height: 18),
                                  _buildStatusCard(data),
                                  SizedBox(height: 18),
                                  _buildQrCard(data),
                                  SizedBox(height: 18),
                                  _buildJointOwnersCard(data),
                                ],
                              ),
                          ],
                        ),
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

  // ============================================================
  // PET HEADER
  // ============================================================

  
Widget _buildPetHeader(Map<String, dynamic> data) {
  final String petName = _stringValue(data['petName']);
  final String breed = _stringValue(data['breed']);
  final String photoUrl = _stringValue(data['photoUrl']);

  final dynamic photosValue = data['photoUrls'];

  final List<String> photoUrls = photosValue is List
      ? photosValue
          .whereType<String>()
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList()
      : <String>[];

  if (photoUrls.isEmpty && photoUrl.isNotEmpty) {
    photoUrls.add(photoUrl);
  }

  final String albumCover = photoUrls.isNotEmpty
      ? photoUrls.first
      : '';

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [surfaceColor, softerTeal],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
        BoxShadow(
          color: Color(0xFFFFFFFF),
          blurRadius: 8,
          offset: Offset(-4, -4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPetImage(photoUrl: photoUrl, size: 92),
            SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: lightTeal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PET PROFILE',
                      style: TextStyle(
                        color: primaryTeal,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    petName.isEmpty ? 'Unnamed Pet' : petName,
                    style: TextStyle(
                      color: darkText,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    breed.isEmpty ? 'Breed not specified' : breed,
                    style: TextStyle(
                      color: grayText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 11),
                  _buildPetIdBadge(_stringValue(data['petId'])),
                ],
              ),
            ),
          ],
        ),
        if (photoUrls.isNotEmpty) ...[
          SizedBox(height: 20),
          Text(
            'Pet Photos',
            style: TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                _showPetPhotoAlbum(photoUrls, 0);
              },
              borderRadius: BorderRadius.circular(17),
              child: Container(
                width: 420,
                constraints: BoxConstraints(maxWidth: 420),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            albumCover,
                            width: 94,
                            height: 94,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 94,
                                height: 94,
                                color: lightTeal,
                                child: Icon(
                                  Icons.pets_rounded,
                                  color: primaryTeal,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              '${photoUrls.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uploaded Photos',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${photoUrls.length} photos',
                            style: TextStyle(
                              color: grayText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: grayText,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}



Future<void> _showPetPhotoAlbum(
  List<String> photoUrls,
  int initialIndex,
) async {
  if (photoUrls.isEmpty || !mounted) return;

  final int safeIndex = initialIndex.clamp(0, photoUrls.length - 1);

  final PageController pageController = PageController(
    initialPage: safeIndex,
  );

  int currentIndex = safeIndex;

  try {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.black,
              insetPadding: EdgeInsets.all(18),
              child: SizedBox(
                width: 900,
                height: MediaQuery.of(context).size.height * 0.78,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Uploaded Photos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${currentIndex + 1} / ${photoUrls.length}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: photoUrls.length,
                        onPageChanged: (index) {
                          setDialogState(() {
                            currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Center(
                            child: InteractiveViewer(
                              minScale: 0.8,
                              maxScale: 4,
                              child: Image.network(
                                photoUrls[index],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white70,
                                    size: 55,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 82,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: photoUrls.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(width: 9);
                        },
                        itemBuilder: (context, index) {
                          final bool isSelected = currentIndex == index;

                          return InkWell(
                            onTap: () {
                              pageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? primaryTeal
                                      : Colors.white30,
                                  width: isSelected ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  photoUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    pageController.dispose();
  }
}

  Widget _buildPetImage({required String photoUrl, required double size}) {
    if (photoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: lightTeal,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.pets_rounded, color: primaryTeal, size: 38),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Icon(Icons.pets_rounded, color: primaryTeal, size: 38),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPetIdBadge(String petId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: primaryTeal.withValues(alpha: 0.10)),
      ),
      child: Text(
        'ID: ${petId.isEmpty ? 'N/A' : petId}',
        style: TextStyle(
          color: primaryTeal,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // EDIT BUTTON
  // ============================================================

  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _openEditPet,
          icon: Icon(Icons.edit_outlined, size: 18),
          label: Text(
            'Edit Pet Information',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryTeal,
            backgroundColor: surfaceColor,
            side: BorderSide(color: primaryTeal.withValues(alpha: 0.35)),
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PET DETAILS
  // ============================================================

  Widget _buildDetailsCard(Map<String, dynamic> data) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.pets_rounded,
            title: 'Pet Information',
          ),
          SizedBox(height: 18),
          _buildInfoRow(
            icon: Icons.pets_rounded,
            label: 'Pet Name',
            value: _stringValue(data['petName']),
          ),
          SizedBox(height: 11),
          _buildInfoRow(
            icon: Icons.category_outlined,
            label: 'Breed',
            value: _stringValue(data['breed']),
          ),
          SizedBox(height: 11),
          _buildInfoRow(
            icon: Icons.palette_outlined,
            label: 'Color',
            value: _stringValue(data['color']),
          ),
          SizedBox(height: 11),
          _buildInfoRow(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: _stringValue(data['age']),
          ),
          SizedBox(height: 11),

          // ADDED: SEX
          _buildInfoRow(
            icon: Icons.pets_rounded,
            label: 'Sex',
            value: _displaySex(_stringValue(data['sex'])),
          ),
          SizedBox(height: 11),

          // ADDED: IDENTIFYING MARKS
          _buildInfoRow(
            icon: Icons.fingerprint_rounded,
            label: 'Identifying Marks',
            value: _stringValue(data['identifyingMarks']).trim().isEmpty
                ? 'Not specified'
                : _stringValue(data['identifyingMarks']),
          ),
          SizedBox(height: 11),
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Owner Name',
            value: _stringValue(data['ownerName']),
          ),
          SizedBox(height: 11),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Contact Number',
            value: _stringValue(data['ownerContact']),
          ),
        ],
      ),
    );
  }

  // ADDED: DISPLAY SEX LABEL
  String _displaySex(String sex) {
    switch (sex.trim().toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return 'Unknown';
    }
  }

  // ============================================================
  // SAFETY CARD
  // ============================================================

  Widget _buildSafetyCard(Map<String, dynamic> data) {
    final String safetyTag = _normalizeSafetyTag(
      _stringValue(data['safetyTag']),
    );

    final bool isAggressive = safetyTag == 'aggressive';
    final bool isCaution = safetyTag == 'caution';

    final Color tagColor = isAggressive
        ? alertRed
        : isCaution
        ? cautionOrange
        : primaryTeal;

    final Color tagBackground = isAggressive
        ? Color(0xFFFFEEEE)
        : isCaution
        ? Color(0xFFFFF7E6)
        : lightTeal;

    final String label = isAggressive
        ? 'Do Not Approach'
        : isCaution
        ? 'Caution'
        : 'Safe';

    final IconData icon = isAggressive
        ? Icons.shield_outlined
        : isCaution
        ? Icons.warning_amber_rounded
        : Icons.verified_user_outlined;

    return _buildCard(
      accentColor: tagColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.shield_outlined,
            title: 'Safety Level',
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: tagBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tagColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(child: Icon(icon, color: tagColor, size: 22)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isAggressive
                            ? 'Avoid approaching the pet. Use the report feature or notify the barangay.'
                            : isCaution
                            ? 'Approach carefully and give the pet enough space.'
                            : 'This pet is currently marked as safe to approach.',
                        style: TextStyle(
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
          SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _changeSafetyLevel(safetyTag);
              },
              icon: Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Change Safety Level',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: tagColor,
                side: BorderSide(color: tagColor.withValues(alpha: 0.45)),
                padding: EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard(Map<String, dynamic> data) {
    final String status = _stringValue(data['status']).toLowerCase().trim();

    final bool isAlive = status != 'dead';

    return _buildCard(
      accentColor: isAlive ? primaryTeal : alertRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.favorite_outline_rounded,
            title: 'Pet Status',
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isAlive ? lightTeal : Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAlive
                    ? primaryTeal.withValues(alpha: 0.20)
                    : alertRed.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isAlive
                        ? primaryTeal.withValues(alpha: 0.10)
                        : alertRed.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Icon(
                      isAlive
                          ? Icons.favorite_rounded
                          : Icons.heart_broken_rounded,
                      color: isAlive ? primaryTeal : alertRed,
                      size: 21,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAlive ? 'Alive' : 'Deceased',
                        style: TextStyle(
                          color: isAlive ? primaryTeal : alertRed,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isAlive
                            ? 'This pet profile is currently active.'
                            : 'This pet profile is no longer active.',
                        style: TextStyle(
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
          SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _changePetStatus(status);
              },
              icon: Icon(Icons.sync_rounded, size: 18),
              label: Text(
                'Update Pet Status',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isAlive ? primaryTeal : alertRed,
                side: BorderSide(
                  color: (isAlive ? primaryTeal : alertRed).withValues(
                    alpha: 0.45,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QR CARD
  // ============================================================

  Widget _buildQrCard(Map<String, dynamic> data) {
    final String storedPetId = _stringValue(data['petId']);

    final String petId = storedPetId.isEmpty ? widget.petId : storedPetId;

    final bool qrEnabled = data['qrEnabled'] == true;

    if (qrEnabled) {
      return QrCard(
        petId: petId,
        petName: _stringValue(data['petName']),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warmBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        'QR profile is currently unavailable.',
        style: TextStyle(color: grayText, fontSize: 13),
      ),
    );
  }

  // ============================================================
  // JOINT OWNERS
  // ============================================================

  Widget _buildJointOwnersCard(Map<String, dynamic> data) {
    final dynamic ownerIdsValue = data['ownerIds'];

    final List<dynamic> ownerIds = ownerIdsValue is List
        ? ownerIdsValue
        : <dynamic>[];

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.people_outline_rounded,
            title: 'Joint Owners',
          ),
          SizedBox(height: 9),
          Text(
            ownerIds.length <= 1
                ? 'You are currently the only owner of this pet.'
                : '${ownerIds.length} owner accounts are connected to this pet.',
            style: TextStyle(color: grayText, fontSize: 12, height: 1.45),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: softerTeal,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: primaryTeal,
                      size: 18,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All connected owners can access this pet profile.',
                    style: TextStyle(
                      color: darkTeal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openJointOwners,
              icon: Icon(Icons.people_outline_rounded, size: 19),
              label: Text(
                'Manage Joint Owners',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryTeal,
                side: BorderSide(color: primaryTeal.withValues(alpha: 0.4)),
                padding: EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warmBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: primaryTeal, size: 19)),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: grayText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 13,
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: Color(0x0B000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Icon(icon, color: primaryTeal, size: 20)),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
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
  // GENERIC CARD
  // ============================================================

  Widget _buildCard({required Widget child, Color? accentColor}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0xFFFFFFFF),
            blurRadius: 6,
            offset: Offset(-3, -3),
          ),
          if (accentColor != null)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.035),
              blurRadius: 20,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // MESSAGE STATE
  // ============================================================

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 20,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Center(child: Icon(icon, color: primaryTeal, size: 30)),
              ),
              SizedBox(height: 17),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grayText,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  String _normalizeSafetyTag(String value) {
    switch (value.toLowerCase().trim()) {
      case 'green':
      case 'safe':
        return 'safe';

      case 'yellow':
      case 'caution':
        return 'caution';

      case 'red':
      case 'aggressive':
        return 'aggressive';

      default:
        return 'safe';
    }
  }

  String _safetyLabel(String value) {
    switch (_normalizeSafetyTag(value)) {
      case 'aggressive':
        return 'Do Not Approach';

      case 'caution':
        return 'Caution';

      default:
        return 'Safe';
    }
  }
}