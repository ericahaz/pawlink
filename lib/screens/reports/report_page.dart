import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../seasonal/seasonal_controller.dart';
import 'package:latlong2/latlong.dart';

import '../../models/pet_model.dart';
import '../../models/report_model.dart';
import '../../services/pet_service.dart';
import '../../services/report_service.dart';
import '../../services/location_service.dart';
import '../../widgets/location_picker.dart';

import '../home/home_page.dart';
import '../pets/my_pets_page.dart';
import '../barangay/barangay_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ReportService _reportService = ReportService();
  final PetService _petService = PetService();

  final ScrollController _scrollController = ScrollController();

  int _selectedIndex = 2;

  // ============================================================
  // COLORS
  // ============================================================

  static Color get primaryTeal =>
      SeasonalController.instance.activeTheme?.primary ??
      Color(0xFF0F766E);
  static Color get darkTeal =>
      SeasonalController.instance.activeTheme?.secondary ??
      Color(0xFF115E59);
  static Color get lightTeal {
    final theme = SeasonalController.instance.activeTheme;
    if (theme == null) return Color(0xFFE7F5F2);
    return Color.alphaBlend(
      theme.primary.withValues(alpha: 0.10),
      theme.surface,
    );
  }
  static const Color alertRed = Color(0xFFDC2626);
  static Color get warmBackground =>
      SeasonalController.instance.activeTheme?.background ??
      Color(0xFFF7F5F0);
  static Color get darkText =>
      SeasonalController.instance.activeTheme?.textPrimary ??
      Color(0xFF243333);
  static Color get grayText =>
      SeasonalController.instance.activeTheme?.textSecondary ??
      Color(0xFF667373);
  static Color get borderColor =>
      SeasonalController.instance.activeTheme?.border ??
      Color(0xFFE3E5E3);
  static Color get surfaceColor =>
      SeasonalController.instance.activeTheme?.surface ?? Colors.white;
  static Color get onPrimaryColor =>
      SeasonalController.instance.activeTheme?.onPrimary ?? Colors.white;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationChanged(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyPetsPage()),
        );
        break;

      case 2:
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BarangayPage()),
        );
        break;
    }
  }

  // ============================================================
  // SCROLLING
  // ============================================================

  void _scrollDown() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      (_scrollController.offset + 450).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollUp() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      (_scrollController.offset - 450).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // REPORT FORM
  // ============================================================

  Future<void> _showReportForm(String type) async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final detailsController = TextEditingController();

    double? latitude;
    double? longitude;
    String? selectedLocationName;

    String? selectedPetId;
    PetModel? selectedPet;

    String dialogTitle;

    switch (type) {
      case 'lost':
        dialogTitle = 'Report Lost Pet';
        break;

      case 'found':
        dialogTitle = 'Report Found Pet';
        break;

      case 'sighting':
        dialogTitle = 'Report Pet Sighting';
        break;

      case 'stray':
        dialogTitle = 'Report Stray / Safety Concern';
        break;

      default:
        dialogTitle = 'Create Report';
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screenHeight = MediaQuery.of(context).size.height;

            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                dialogTitle,
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),

              // ==========================================================
              // RESPONSIVE DIALOG CONTENT
              // ==========================================================
              content: SizedBox(
                width: 500,
                height: screenHeight > 700 ? null : screenHeight * 0.58,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // LOST PET
                      // ==================================================

                      if (type == 'lost') ...[
                        Text(
                          'Pet Name',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Select the registered pet you want to report as lost.',
                          style: TextStyle(color: grayText, fontSize: 12),
                        ),

                        SizedBox(height: 10),

                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _petService.getMyPetsStream(),
                          builder: (context, snapshot) {
                            // ------------------------------------------------
                            // LOADING
                            // ------------------------------------------------

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: lightTeal,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryTeal,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Loading your registered pets...',
                                        style: TextStyle(
                                          color: grayText,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // ------------------------------------------------
                            // ERROR
                            // ------------------------------------------------

                            if (snapshot.hasError) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF1F1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFFFECACA),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: alertRed,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Unable to load your pets',
                                            style: TextStyle(
                                              color: alertRed,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 7),
                                    Text(
                                      snapshot.error.toString(),
                                      style: TextStyle(
                                        color: grayText,
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // ------------------------------------------------
                            // CONVERT FIRESTORE DOCUMENTS
                            // ------------------------------------------------

                            final allPets = snapshot.data?.docs
                                    .map(PetModel.fromFirestore)
                                    .toList() ??
                                <PetModel>[];

                            // Only alive pets can be reported as lost.
                            final pets =
                                allPets.where((pet) => pet.isAlive).toList();

                            // Sort pets alphabetically.
                            pets.sort(
                              (a, b) => a.petName.toLowerCase().compareTo(
                                    b.petName.toLowerCase(),
                                  ),
                            );

                            // ------------------------------------------------
                            // NO PETS
                            // ------------------------------------------------

                            if (pets.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF8E8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFFF1D48A),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.pets_rounded,
                                          color: Colors.orange,
                                          size: 21,
                                        ),
                                        SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            'No registered pets are available.',
                                            style: TextStyle(
                                              color: darkText,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 7),
                                    Text(
                                      'Register a pet first in My Pets. '
                                      'After the pet is successfully registered, '
                                      'it will appear here automatically.',
                                      style: TextStyle(
                                        color: grayText,
                                        fontSize: 12,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // ------------------------------------------------
                            // KEEP SELECTED VALUE VALID
                            // ------------------------------------------------

                            final validSelectedPetId =
                                pets.any((pet) => pet.petId == selectedPetId)
                                    ? selectedPetId
                                    : null;

                            // ------------------------------------------------
                            // DROPDOWN
                            // ------------------------------------------------

                            return DropdownButtonFormField<String>(
                              initialValue: validSelectedPetId,
                              isExpanded: true,

                              // IMPORTANT:
                              // Gives the dropdown enough height and prevents
                              // the "Bottom overflowed" error.
                              itemHeight: 58,

                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: primaryTeal,
                              ),

                              decoration: InputDecoration(
                                hintText: 'Select Pet Name',
                                hintStyle: TextStyle(
                                  color: grayText,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.pets_rounded,
                                  color: primaryTeal,
                                  size: 21,
                                ),
                                filled: true,
                                fillColor: surfaceColor,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: borderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: borderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryTeal,
                                    width: 1.5,
                                  ),
                                ),
                              ),

                              // ==================================================
                              // DROPDOWN ITEMS
                              // ==================================================
                              items: pets.map((pet) {
                                return DropdownMenuItem<String>(
                                  value: pet.petId,

                                  // FIX:
                                  // Use a single compact Row instead of a
                                  // Column that can overflow vertically.
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: lightTeal,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: pet.photoUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  pet.photoUrl,
                                                  width: 34,
                                                  height: 34,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) {
                                                    return Icon(
                                                      Icons.pets_rounded,
                                                      color: primaryTeal,
                                                      size: 18,
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.pets_rounded,
                                                color: primaryTeal,
                                                size: 18,
                                              ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          pet.breed.isEmpty
                                              ? pet.petName
                                              : '${pet.petName} • ${pet.breed}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: darkText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      PetModel? foundPet;

                                      for (final pet in pets) {
                                        if (pet.petId == value) {
                                          foundPet = pet;
                                          break;
                                        }
                                      }

                                      if (foundPet == null) {
                                        return;
                                      }

                                      setDialogState(() {
                                        selectedPetId = foundPet!.petId;
                                        selectedPet = foundPet;
                                        nameController.text = foundPet.petName;
                                      });
                                    },
                            );
                          },
                        ),

                        // ------------------------------------------------
                        // SELECTED PET PREVIEW
                        // ------------------------------------------------
                        if (selectedPet != null) ...[
                          SizedBox(height: 10),
                          _buildSelectedPetCard(selectedPet!),
                        ],

                        SizedBox(height: 14),
                      ]
                      // ==================================================
                      // OTHER REPORT TYPES
                      // ==================================================
                      else ...[
                        TextField(
                          controller: nameController,
                          decoration: _inputDecoration(
                            type == 'stray' ? 'Report title' : 'Pet name',
                          ),
                        ),
                        SizedBox(height: 14),
                      ],

                      // ==================================================
                      // LOCATION
                      // ==================================================
                      TextField(
                        controller: locationController,
                        decoration: _inputDecoration(
                          type == 'lost' ? 'Last seen location' : 'Location',
                        ).copyWith(
                          hintText: 'Search or enter a location',
                          suffixIcon: Icon(
                            Icons.search_rounded,
                            color: primaryTeal,
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: grayText,
                          ),
                          SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              selectedLocationName == null
                                  ? 'Use Pin Map to search for a place or mark the exact location.'
                                  : 'Selected: $selectedLocationName',
                              style: TextStyle(
                                color: grayText,
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 14),

                      // ==================================================
                      // DETAILS
                      // ==================================================
                      TextField(
                        controller: detailsController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          type == 'stray' ? 'Describe the concern' : 'Details',
                        ),
                      ),

                      SizedBox(height: 16),

                      // ==================================================
                      // MAP LOCATION PICKER
                      // ==================================================
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: lightTeal,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Color(0xFFCBE8E3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: primaryTeal,
                                size: 21,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mark the report location',
                                    style: TextStyle(
                                      color: darkText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Search a place, use your current location, or tap the map to place the pin.',
                                    style: TextStyle(
                                      color: grayText,
                                      fontSize: 11.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            TextButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      final result = await _showMapPicker(
                                        initialLocation: latitude != null &&
                                                longitude != null
                                            ? LatLng(
                                                latitude!,
                                                longitude!,
                                              )
                                            : null,
                                        initialLocationName:
                                            selectedLocationName ??
                                                locationController.text.trim(),
                                      );

                                      if (result != null) {
                                        setDialogState(() {
                                          latitude = result.location.latitude;
                                          longitude = result.location.longitude;
                                          selectedLocationName =
                                              result.displayName;
                                          locationController.text =
                                              result.displayName;
                                        });
                                      }
                                    },
                              child: Text('Pin Map'),
                            ),
                          ],
                        ),
                      ),

                      if (latitude != null && longitude != null) ...[
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: lightTeal,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: primaryTeal,
                                size: 17,
                              ),
                              SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  selectedLocationName?.isNotEmpty == true
                                      ? selectedLocationName!
                                      : 'Location pinned successfully.',
                                  style: TextStyle(
                                    color: darkText,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ==================================================
                      // LOST PET INFORMATION
                      // ==================================================
                      if (type == 'lost') ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: Color(0xFFFECACA)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: alertRed,
                                size: 19,
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Your report will be linked to the selected '
                                  'pet profile using its Pet ID.',
                                  style: TextStyle(
                                    color: grayText,
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // ACTIONS
              // ==========================================================
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: onPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();

                          final location = locationController.text.trim();

                          final details = detailsController.text.trim();

                          // ==================================================
                          // LOST PET VALIDATION
                          // ==================================================

                          if (type == 'lost' && selectedPet == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select a registered pet first.',
                                ),
                                backgroundColor: alertRed,
                              ),
                            );
                            return;
                          }

                          // For lost pets, the name comes directly
                          // from the selected registered pet.
                          if (type != 'lost' && name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter the pet name or report title.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (location.isEmpty || details.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please complete all fields.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            switch (type) {
                              // ============================================
                              // LOST PET
                              // ============================================

                              case 'lost':
                                await _reportService.createLostPetReport(
                                  petId: selectedPet!.petId,
                                  petName: selectedPet!.petName,
                                  lastSeenLocation: location,
                                  details: details,
                                  latitude: latitude,
                                  longitude: longitude,
                                  locationName: selectedLocationName,
                                );
                                break;

                              // ============================================
                              // FOUND PET
                              // ============================================

                              case 'found':
                                await _reportService.createFoundPetReport(
                                  petId: '',
                                  petName: name,
                                  foundLocation: location,
                                  foundDate: DateTime.now().toIso8601String(),
                                  message: details,
                                  latitude: latitude,
                                  longitude: longitude,
                                  locationName: selectedLocationName,
                                );
                                break;

                              // ============================================
                              // PET SIGHTING
                              // ============================================

                              case 'sighting':
                                await _reportService.createSightingReport(
                                  petName: name,
                                  locationName: location,
                                  details: details,
                                  latitude: latitude,
                                  longitude: longitude,
                                );
                                break;

                              // ============================================
                              // BARANGAY / STRAY
                              // ============================================

                              case 'stray':
                                await _reportService.createBarangayReport(
                                  title: name,
                                  location: location,
                                  details: details,
                                  latitude: latitude,
                                  longitude: longitude,
                                  locationName: selectedLocationName,
                                );
                                break;
                            }

                            if (!mounted || !dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Report submitted successfully.'),
                                backgroundColor: primaryTeal,
                              ),
                            );
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });
                            }

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                                backgroundColor: alertRed,
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Submit Report'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    locationController.dispose();
    detailsController.dispose();
  }

  // ============================================================
  // SELECTED PET CARD
  // ============================================================

  Widget _buildSelectedPetCard(PetModel pet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Color(0xFFCBE8E3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: pet.photoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      pet.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.pets_rounded,
                          color: primaryTeal,
                        );
                      },
                    ),
                  )
                : Icon(Icons.pets_rounded, color: primaryTeal),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.petName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  pet.breed.isEmpty ? 'Breed not specified' : pet.breed,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: grayText, fontSize: 12),
                ),
                SizedBox(height: 5),
                Text(
                  'Pet ID: ${pet.petId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
  // MAP PICKER
  // ============================================================

  Future<LocationSelection?> _showMapPicker({
    LatLng? initialLocation,
    String? initialLocationName,
  }) async {
    final fallback = initialLocation ?? LatLng(14.4064, 120.9405);

    return showDialog<LocationSelection>(
      context: context,
      builder: (dialogContext) {
        return LocationPicker(
          initialLocation: fallback,
          initialLocationName: initialLocationName,
          title: 'Pin Report Location',
          confirmLabel: 'Use This Location',
        );
      },
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: grayText),
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
    );
  }

  // ============================================================
  // REPORT HISTORY
  // ============================================================

  Widget _buildReportHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _reportService.getMyReportsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: primaryTeal),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final reports =
            snapshot.data?.docs.map(ReportModel.fromFirestore).toList() ?? [];

        reports.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);

          return bDate.compareTo(aDate);
        });

        if (reports.isEmpty) {
          return _buildEmptyHistory();
        }

        return Column(children: reports.map(_buildHistoryCard).toList());
      },
    );
  }

  // ============================================================
  // HISTORY CARD
  // ============================================================

  Widget _buildHistoryCard(ReportModel report) {
    final Color statusColor = report.isResolved
        ? primaryTeal
        : report.isPending
            ? Colors.orange
            : report.isClosed
                ? grayText
                : alertRed;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.typeLabel,
                      style: TextStyle(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (report.petName != null &&
                        report.petName!.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        report.petName!,
                        style: TextStyle(color: grayText, fontSize: 13),
                      ),
                    ],
                    if (report.petId != null && report.petId!.isNotEmpty) ...[
                      SizedBox(height: 3),
                      Text(
                        'Pet ID: ${report.petId}',
                        style: TextStyle(
                          color: primaryTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _infoRow(Icons.location_on_outlined, 'Location', report.location),
          if (report.details.isNotEmpty)
            _infoRow(Icons.notes_rounded, 'Details', report.details),
          if (report.latitude != null && report.longitude != null)
            _infoRow(
              Icons.map_outlined,
              'Pinned Location',
              '${report.latitude!.toStringAsFixed(5)}, '
                  '${report.longitude!.toStringAsFixed(5)}',
            ),
          if (report.createdAt != null)
            _infoRow(
              Icons.schedule_rounded,
              'Submitted',
              _formatDate(report.createdAt!),
            ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _editReport(report),
                icon: Icon(Icons.edit_outlined, size: 17),
                label: Text('Edit'),
              ),
              if (report.isActive)
                OutlinedButton.icon(
                  onPressed: () => _resolveReport(report),
                  icon: Icon(Icons.check_circle_outline, size: 17),
                  label: Text('Resolve'),
                )
              else if (report.isResolved)
                OutlinedButton.icon(
                  onPressed: () => _reopenReport(report),
                  icon: Icon(Icons.refresh_rounded, size: 17),
                  label: Text('Reopen'),
                ),
              OutlinedButton.icon(
                onPressed: () => _deleteReport(report),
                icon: Icon(Icons.delete_outline, size: 17),
                label: Text('Delete'),
                style: OutlinedButton.styleFrom(foregroundColor: alertRed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EDIT REPORT
  // ============================================================

  Future<void> _editReport(ReportModel report) async {
    final locationController = TextEditingController(text: report.location);

    final detailsController = TextEditingController(text: report.details);

    double? latitude = report.latitude;
    double? longitude = report.longitude;
    String? selectedLocationName = report.locationName ?? report.location;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Report',
                style: TextStyle(fontWeight: FontWeight.w800, color: darkText),
              ),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: locationController,
                      decoration: _inputDecoration('Location').copyWith(
                        hintText: 'Search or enter a location',
                        suffixIcon: Icon(
                          Icons.search_rounded,
                          color: primaryTeal,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    if (selectedLocationName != null &&
                        selectedLocationName!.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selected: $selectedLocationName',
                          style: TextStyle(
                            color: grayText,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    SizedBox(height: 14),
                    TextField(
                      controller: detailsController,
                      maxLines: 4,
                      decoration: _inputDecoration('Details'),
                    ),
                    SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              final result = await _showMapPicker(
                                initialLocation:
                                    latitude != null && longitude != null
                                        ? LatLng(latitude!, longitude!)
                                        : null,
                                initialLocationName: selectedLocationName ??
                                    locationController.text.trim(),
                              );

                              if (result != null) {
                                setState(() {
                                  latitude = result.location.latitude;
                                  longitude = result.location.longitude;
                                  selectedLocationName = result.displayName;
                                  locationController.text = result.displayName;
                                });
                              }
                            },
                      icon: Icon(Icons.location_on_outlined),
                      label: Text(
                        latitude == null
                            ? 'Update Map Location'
                            : 'Change Map Location',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: onPrimaryColor,
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          final location = locationController.text.trim();

                          final details = detailsController.text.trim();

                          if (location.isEmpty || details.isEmpty) {
                            return;
                          }

                          setState(() {
                            saving = true;
                          });

                          try {
                            await _reportService.updateReport(
                              reportId: report.reportId,
                              location: location,
                              details: details,
                              latitude: latitude,
                              longitude: longitude,
                              locationName: selectedLocationName,
                            );

                            if (!mounted || !dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Report updated.'),
                                backgroundColor: primaryTeal,
                              ),
                            );
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                saving = false;
                              });
                            }

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                                backgroundColor: alertRed,
                              ),
                            );
                          }
                        },
                  child: saving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    locationController.dispose();
    detailsController.dispose();
  }

  // ============================================================
  // RESOLVE
  // ============================================================

  Future<void> _resolveReport(ReportModel report) async {
    final confirmed = await _confirmDialog(
      title: 'Resolve Report',
      message: 'Mark this report as resolved?',
      confirmText: 'Resolve',
    );

    if (!confirmed) {
      return;
    }

    try {
      await _reportService.resolveReport(report.reportId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report marked as resolved.'),
          backgroundColor: primaryTeal,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: alertRed,
        ),
      );
    }
  }

  // ============================================================
  // REOPEN
  // ============================================================

  Future<void> _reopenReport(ReportModel report) async {
    try {
      await _reportService.reopenReport(report.reportId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report reopened.'),
          backgroundColor: primaryTeal,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: alertRed,
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteReport(ReportModel report) async {
    final confirmed = await _confirmDialog(
      title: 'Delete Report',
      message: 'Are you sure you want to permanently delete this report?',
      confirmText: 'Delete',
      destructive: true,
    );

    if (!confirmed) {
      return;
    }

    try {
      await _reportService.deleteReport(report.reportId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Report deleted.')));
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: alertRed,
        ),
      );
    }
  }

  // ============================================================
  // CONFIRMATION DIALOG
  // ============================================================

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(message, style: TextStyle(color: grayText)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: destructive ? alertRed : primaryTeal,
                foregroundColor: onPrimaryColor,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // EMPTY HISTORY
  // ============================================================

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: primaryTeal),
          SizedBox(height: 12),
          Text(
            'No reports yet',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your submitted reports will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grayText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR CARD
  // ============================================================

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFFECACA)),
      ),
      child: Text(error, style: TextStyle(color: alertRed, fontSize: 13)),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryTeal),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: darkText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: grayText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$month/$day/$year $hour:$minute $period';
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Icon(Icons.pets_rounded, color: primaryTeal, size: 28),
                SizedBox(width: 9),
                Text(
                  'PawLink',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 35),
          _sidebarItem(icon: Icons.home_outlined, label: 'Home', index: 0),
          _sidebarItem(icon: Icons.pets_outlined, label: 'My Pets', index: 1),
          _sidebarItem(icon: Icons.report_outlined, label: 'Reports', index: 2),
          _sidebarItem(
            icon: Icons.account_balance_outlined,
            label: 'Barangay',
            index: 3,
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout, size: 18),
              label: Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: alertRed,
                minimumSize: Size(double.infinity, 44),
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

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = _selectedIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onNavigationChanged(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? lightTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? primaryTeal : grayText, size: 21),
              SizedBox(width: 11),
              Text(
                label,
                style: TextStyle(
                  color: selected ? darkTeal : grayText,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  // ============================================================
  // REPORT BUTTON
  // ============================================================

  Widget _reportButton({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: grayText,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: onPressed,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 17,
              color: primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: warmBackground,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 42 : 18,
                        vertical: 28,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Community Reports',
                                        style: TextStyle(
                                          color: darkText,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Help keep pets and the community safe by reporting lost pets, found pets, sightings, and safety concerns.',
                                        style: TextStyle(
                                          color: grayText,
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isDesktop)
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: _scrollUp,
                                        icon: Icon(
                                          Icons.keyboard_arrow_up_rounded,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _scrollDown,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            SizedBox(height: 28),

                            // ==================================================
                            // REPORT TYPES
                            // ==================================================
                            Text(
                              'Create a Report',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 14),

                            LayoutBuilder(
                              builder: (context, constraints) {
                                final twoColumns = constraints.maxWidth >= 700;

                                final buttons = [
                                  _reportButton(
                                    icon: Icons.search_off_rounded,
                                    title: 'Lost Pet',
                                    description:
                                        'Report a registered pet that is missing.',
                                    color: alertRed,
                                    onPressed: () => _showReportForm('lost'),
                                  ),
                                  _reportButton(
                                    icon: Icons.pets_rounded,
                                    title: 'Found Pet',
                                    description: 'Report a pet you found.',
                                    color: primaryTeal,
                                    onPressed: () => _showReportForm('found'),
                                  ),
                                  _reportButton(
                                    icon: Icons.visibility_outlined,
                                    title: 'Pet Sighting',
                                    description:
                                        'Report seeing a pet in your area.',
                                    color: Colors.orange,
                                    onPressed: () =>
                                        _showReportForm('sighting'),
                                  ),
                                  _reportButton(
                                    icon: Icons.warning_amber_rounded,
                                    title: 'Stray / Safety Concern',
                                    description:
                                        'Notify the barangay about a stray or safety concern.',
                                    color: alertRed,
                                    onPressed: () => _showReportForm('stray'),
                                  ),
                                ];

                                if (twoColumns) {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        NeverScrollableScrollPhysics(),
                                    itemCount: buttons.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 2.8,
                                    ),
                                    itemBuilder: (context, index) =>
                                        buttons[index],
                                  );
                                }

                                return Column(
                                  children: buttons
                                      .map(
                                        (button) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: button,
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),

                            SizedBox(height: 34),

                            _buildHowReportingWorks(),

                            SizedBox(height: 28),

                            _buildSafetyReminder(),

                            SizedBox(height: 34),

                            Text(
                              'My Report History',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 14),

                            _buildReportHistory(),

                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==========================================================
                  // MOBILE NAVIGATION
                  // ==========================================================
                  if (!isDesktop)
                    NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _onNavigationChanged,
                      backgroundColor: surfaceColor,
                      indicatorColor: lightTeal,
                      destinations: [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.pets_outlined),
                          selectedIcon: Icon(Icons.pets_rounded),
                          label: 'My Pets',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.report_outlined),
                          selectedIcon: Icon(Icons.report_rounded),
                          label: 'Report',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.account_balance_outlined),
                          selectedIcon: Icon(Icons.account_balance_rounded),
                          label: 'Barangay',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HOW REPORTING WORKS
  // ============================================================

  Widget _buildHowReportingWorks() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How reporting works',
            style: TextStyle(
              color: darkTeal,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '1. Choose the type of report.',
            style: TextStyle(color: darkText, fontSize: 13),
          ),
          SizedBox(height: 7),
          Text(
            '2. Select your registered pet when reporting a lost pet.',
            style: TextStyle(color: darkText, fontSize: 13),
          ),
          SizedBox(height: 7),
          Text(
            '3. Enter the location and important details.',
            style: TextStyle(color: darkText, fontSize: 13),
          ),
          SizedBox(height: 7),
          Text(
            '4. Optionally pin the location on the map.',
            style: TextStyle(color: darkText, fontSize: 13),
          ),
          SizedBox(height: 7),
          Text(
            '5. Submit the report so it can be tracked.',
            style: TextStyle(color: darkText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAFETY REMINDER
  // ============================================================

  Widget _buildSafetyReminder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: alertRed, size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety reminder',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'If a pet appears aggressive or unsafe to approach, do not attempt to catch or scan the pet. Keep a safe distance and report the location to the barangay.',
                  style: TextStyle(
                    color: grayText,
                    fontSize: 12.5,
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
}
