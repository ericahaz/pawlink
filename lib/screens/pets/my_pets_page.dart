import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../seasonal/seasonal_controller.dart';

import '../../services/pet_service.dart';
import 'pet_profile_page.dart';
import 'register_pet_page.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  final PetService _petService = PetService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _keyboardFocusNode = FocusNode();

  String _searchText = '';

  static Color get primaryTeal =>
      SeasonalController.instance.activeTheme?.primary ??
      Color(0xFF0F766E);
  static Color get darkTeal =>
      SeasonalController.instance.activeTheme?.secondary ??
      Color(0xFF115E59);
  static Color get deepTeal {
    final theme = SeasonalController.instance.activeTheme;
    if (theme == null) return Color(0xFF103B38);
    return Color.lerp(theme.secondary, theme.primary, 0.28) ?? theme.secondary;
  }
  static Color get lightTeal {
    final theme = SeasonalController.instance.activeTheme;
    if (theme == null) return Color(0xFFE7F5F2);
    return Color.alphaBlend(theme.primary.withValues(alpha: 0.10), theme.surface);
  }
  static Color get softerTeal {
    final theme = SeasonalController.instance.activeTheme;
    if (theme == null) return Color(0xFFF0F8F6);
    return Color.alphaBlend(theme.primary.withValues(alpha: 0.055), theme.surface);
  }
  static const Color alertRed = Color(0xFFDC2626);
  static Color get warmBackground =>
      SeasonalController.instance.activeTheme?.background ??
      Color(0xFFFFFBF5);
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
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _searchText = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _openRegisterPet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterPetPage()),
    );
  }

  void _openPetProfile(String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PetProfilePage(petId: petId)),
    );
  }

  void _handleKeyboardEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (!_scrollController.hasClients) return;

    final viewportHeight = MediaQuery.of(context).size.height;
    final currentOffset = _scrollController.offset;

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
      targetOffset = _scrollController.position.maxScrollExtent;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      targetOffset = HardwareKeyboard.instance.isShiftPressed
          ? currentOffset - viewportHeight * 0.85
          : currentOffset + viewportHeight * 0.85;
    }

    if (targetOffset != null) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final safeOffset = targetOffset.clamp(0.0, maxScroll).toDouble();

      _scrollController.animateTo(
        safeOffset,
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: Focus(
        focusNode: _keyboardFocusNode,
        onKeyEvent: (node, event) {
          _handleKeyboardEvent(event);
          return KeyEventResult.handled;
        },
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _petService.getMyPetsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('========== PAWLINK MY PETS ERROR ==========');
              debugPrint('Error type: ${snapshot.error.runtimeType}');
              debugPrint('Error details: ${snapshot.error}');
              debugPrint('Stack trace: ${snapshot.stackTrace}');
              debugPrint('===========================================');

              return _buildError(error: snapshot.error);
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: primaryTeal),
              );
            }

            final allPets = snapshot.data?.docs ?? [];

            final pets = allPets.where((doc) {
              final data = doc.data();
              final name = data['petName']?.toString().toLowerCase() ?? '';
              final breed = data['breed']?.toString().toLowerCase() ?? '';

              return name.contains(_searchText) || breed.contains(_searchText);
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 800;

                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: isDesktop,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 40 : 18,
                      24,
                      isDesktop ? 40 : 18,
                      110,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroHeader(allPets),
                            SizedBox(height: 20),
                            _buildStats(allPets),
                            SizedBox(height: 22),
                            _buildSearch(),
                            SizedBox(height: 24),
                            if (allPets.isEmpty)
                              _buildEmptyState()
                            else if (pets.isEmpty)
                              _buildNoSearchResults()
                            else ...[
                              _buildSectionHeader(
                                pets.length,
                                _searchText.isEmpty,
                              ),
                              SizedBox(height: 14),
                              _buildPetGrid(pets, constraints.maxWidth),
                              SizedBox(height: 22),
                              _buildRegisterPrompt(),
                            ],
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: primaryTeal.withValues(alpha: 0.08)),
            ),
            child: Center(
              child: Icon(Icons.pets_rounded, color: primaryTeal, size: 21),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'My Pets',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(color: darkText),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _openRegisterPet,
      backgroundColor: primaryTeal,
      foregroundColor: onPrimaryColor,
      elevation: 4,
      icon: Icon(Icons.add_rounded),
      label: Text(
        'Register Pet',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildHeroHeader(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> pets,
  ) {
    final petCount = pets.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deepTeal, darkTeal],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkTeal.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: onPrimaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -50,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: onPrimaryColor.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: onPrimaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: onPrimaryColor.withValues(alpha: 0.10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, color: onPrimaryColor, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'PAWLINK PET CARE',
                      style: TextStyle(
                        color: onPrimaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text(
                petCount == 0
                    ? 'Start your pet\'s PawLink journey.'
                    : 'Your pets, all in one place.',
                style: TextStyle(
                  color: onPrimaryColor,
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                petCount == 0
                    ? 'Register a pet to create a profile and connect it to a unique QR code.'
                    : 'Keep their profiles updated, manage safety information, and access their QR profiles anytime.',
                style: TextStyle(
                  color: onPrimaryColor.withValues(alpha: 0.76),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              if (petCount == 0) ...[
                SizedBox(height: 17),
                ElevatedButton.icon(
                  onPressed: _openRegisterPet,
                  icon: Icon(Icons.add_rounded, size: 19),
                  label: Text('Register Your First Pet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: surfaceColor,
                    foregroundColor: darkTeal,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<QueryDocumentSnapshot<Map<String, dynamic>>> pets) {
    int qrCount = 0;
    int safetyAlerts = 0;

    for (final pet in pets) {
      final data = pet.data();

      if (data['qrEnabled'] == true) {
        qrCount++;
      }

      final safetyTag = data['safetyTag']?.toString().toLowerCase() ?? 'safe';

      if (safetyTag == 'caution' ||
          safetyTag == 'yellow' ||
          safetyTag == 'aggressive' ||
          safetyTag == 'red') {
        safetyAlerts++;
      }
    }

    final cards = [
      _buildStatCard(
        icon: Icons.pets_rounded,
        label: 'Total Pets',
        value: pets.length.toString(),
        background: softerTeal,
        iconColor: primaryTeal,
      ),
      _buildStatCard(
        icon: Icons.qr_code_2_rounded,
        label: 'QR Profiles',
        value: qrCount.toString(),
        background: softerTeal,
        iconColor: darkTeal,
      ),
      _buildStatCard(
        icon: Icons.shield_rounded,
        label: 'Safety Alerts',
        value: safetyAlerts.toString(),
        background: safetyAlerts > 0
            ? alertRed.withValues(alpha: 0.055)
            : softerTeal,
        iconColor: safetyAlerts > 0 ? alertRed : Color(0xFF15803D),
      ),
    ];

    return Row(
      children: [
        Expanded(child: cards[0]),
        SizedBox(width: 10),
        Expanded(child: cards[1]),
        SizedBox(width: 10),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color background,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: grayText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by pet name or breed',
          hintStyle: TextStyle(color: grayText, fontSize: 13),
          prefixIcon: Container(
            width: 45,
            margin: EdgeInsets.only(left: 6, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Icon(Icons.search_rounded, color: primaryTeal, size: 20),
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 57,
            minHeight: 50,
          ),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  onPressed: _searchController.clear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: grayText,
                    size: 19,
                  ),
                )
              : null,
          filled: true,
          fillColor: surfaceColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryTeal, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int count, bool showingAll) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: lightTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(Icons.grid_view_rounded, color: primaryTeal, size: 19),
          ),
        ),
        SizedBox(width: 10),
        Text(
          showingAll ? 'Your pet profiles' : 'Search results',
          style: TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            '$count ${count == 1 ? 'pet' : 'pets'}',
            style: TextStyle(
              color: grayText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetGrid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> pets,
    double width,
  ) {
    int columns = 1;

    if (width >= 1100) {
      columns = 3;
    } else if (width >= 700) {
      columns = 2;
    }

    if (columns == 1) {
      return Column(
        children: pets.map((pet) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: _buildPetCard(pet, compact: true),
          );
        }).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: pets.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.02,
      ),
      itemBuilder: (context, index) => _buildPetCard(pets[index]),
    );
  }

  Widget _buildPetCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    bool compact = false,
  }) {
    final data = doc.data();
    final petId = data['petId']?.toString() ?? doc.id;
    final name = data['petName']?.toString() ?? 'Unnamed Pet';
    final breed = data['breed']?.toString() ?? 'Breed not specified';
    final age = data['age']?.toString() ?? '';
    final color = data['color']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'alive';
    final safetyTag = data['safetyTag']?.toString() ?? 'safe';
    final photoUrl = data['photoUrl']?.toString() ?? '';
    final qrEnabled = data['qrEnabled'] == true;
    final isAlive = status.toLowerCase() == 'alive';
    final safetyInfo = _getSafetyInfo(safetyTag);

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openPetProfile(petId),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: compact
              ? _buildCompactPetCardContent(
                  photoUrl: photoUrl,
                  name: name,
                  breed: breed,
                  age: age,
                  color: color,
                  status: status,
                  isAlive: isAlive,
                  safetyInfo: safetyInfo,
                  qrEnabled: qrEnabled,
                )
              : _buildGridPetCardContent(
                  photoUrl: photoUrl,
                  name: name,
                  breed: breed,
                  age: age,
                  color: color,
                  status: status,
                  isAlive: isAlive,
                  safetyInfo: safetyInfo,
                  qrEnabled: qrEnabled,
                ),
        ),
      ),
    );
  }

  Widget _buildGridPetCardContent({
    required String photoUrl,
    required String name,
    required String breed,
    required String age,
    required String color,
    required String status,
    required bool isAlive,
    required Map<String, dynamic> safetyInfo,
    required bool qrEnabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 170,
          width: double.infinity,
          child: _buildPetImage(photoUrl, safetyInfo: safetyInfo),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 13, 15, 13),
            child: _buildPetInformation(
              name: name,
              breed: breed,
              age: age,
              color: color,
              status: status,
              isAlive: isAlive,
              safetyInfo: safetyInfo,
              qrEnabled: qrEnabled,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactPetCardContent({
    required String photoUrl,
    required String name,
    required String breed,
    required String age,
    required String color,
    required String status,
    required bool isAlive,
    required Map<String, dynamic> safetyInfo,
    required bool qrEnabled,
  }) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 115,
            height: 125,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildPetImage(photoUrl, safetyInfo: safetyInfo),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: _buildPetInformation(
                name: name,
                breed: breed,
                age: age,
                color: color,
                status: status,
                isAlive: isAlive,
                safetyInfo: safetyInfo,
                qrEnabled: qrEnabled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInformation({
    required String name,
    required String breed,
    required String age,
    required String color,
    required String status,
    required bool isAlive,
    required Map<String, dynamic> safetyInfo,
    required bool qrEnabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
              ),
            ),
            SizedBox(width: 7),
            _buildStatus(status, isAlive),
          ],
        ),
        SizedBox(height: 6),
        Text(
          breed,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: grayText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (age.isNotEmpty || color.isNotEmpty) ...[
          SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: [
              if (age.isNotEmpty) _buildInfoChip(Icons.cake_rounded, age),
              if (color.isNotEmpty)
                _buildInfoChip(Icons.palette_rounded, color),
            ],
          ),
        ],
        Spacer(),
        Row(
          children: [
            _buildSafetyBadge(safetyInfo),
            Spacer(),
            if (qrEnabled)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    color: primaryTeal,
                    size: 18,
                  ),
                ),
              ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: grayText,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: softerTeal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: grayText),
          SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: grayText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBadge(Map<String, dynamic> safetyInfo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: safetyInfo['background'] as Color,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            safetyInfo['icon'] as IconData,
            size: 13,
            color: safetyInfo['color'] as Color,
          ),
          SizedBox(width: 4),
          Text(
            safetyInfo['label'] as String,
            style: TextStyle(
              color: safetyInfo['color'] as Color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetImage(
    String photoUrl, {
    required Map<String, dynamic> safetyInfo,
  }) {
    Widget image;

    if (photoUrl.isEmpty) {
      image = Container(
        color: lightTeal,
        child: Center(
          child: Icon(Icons.pets_rounded, color: primaryTeal, size: 58),
        ),
      );
    } else {
      image = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: lightTeal,
            child: Center(
              child: Icon(Icons.pets_rounded, color: primaryTeal, size: 58),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            color: lightTeal,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryTeal,
              ),
            ),
          );
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Positioned(
          left: 10,
          top: 10,
          child: _buildImageSafetyBadge(safetyInfo),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new_rounded, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text(
                  'View profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSafetyBadge(Map<String, dynamic> safetyInfo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: onPrimaryColor.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            safetyInfo['icon'] as IconData,
            size: 13,
            color: safetyInfo['color'] as Color,
          ),
          SizedBox(width: 4),
          Text(
            safetyInfo['label'] as String,
            style: TextStyle(
              color: safetyInfo['color'] as Color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getSafetyInfo(String safetyTag) {
    final tag = safetyTag.toLowerCase().trim();

    if (tag == 'aggressive' || tag == 'red') {
      return {
        'label': 'Do Not Approach',
        'color': alertRed,
        'background': alertRed.withValues(alpha: 0.08),
        'icon': Icons.warning_rounded,
      };
    }

    if (tag == 'caution' || tag == 'yellow') {
      return {
        'label': 'Caution',
        'color': Color(0xFFB7791F),
        'background': Color(0xFFFFF8E7),
        'icon': Icons.info_rounded,
      };
    }

    return {
      'label': 'Safe',
      'color': Color(0xFF15803D),
      'background': Color(0xFFEFF8EF),
      'icon': Icons.verified_rounded,
    };
  }

  Widget _buildStatus(String status, bool alive) {
    final color = alive ? Color(0xFF15803D) : alertRed;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            alive ? Color(0xFFEFF8EF) : alertRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5),
          Text(
            alive ? 'Alive' : 'Deceased',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: softerTeal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryTeal.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: primaryTeal,
                size: 23,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have another pet?',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Create another PawLink profile and QR code.',
                  style: TextStyle(color: grayText, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: _openRegisterPet,
            style: TextButton.styleFrom(
              foregroundColor: primaryTeal,
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            ),
            child: Text(
              'Register',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Icon(Icons.pets_rounded, color: primaryTeal, size: 42),
            ),
          ),
          SizedBox(height: 17),
          Text(
            'No pets registered yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Give your pet a digital identity with a PawLink profile and unique QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grayText, fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openRegisterPet,
            icon: Icon(Icons.add_rounded, size: 19),
            label: Text('Register a Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: onPrimaryColor,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: softerTeal,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Icon(Icons.search_off_rounded, color: grayText, size: 31),
            ),
          ),
          SizedBox(height: 13),
          Text(
            'No matching pets',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another pet name or breed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grayText, fontSize: 13),
          ),
          SizedBox(height: 14),
          TextButton.icon(
            onPressed: _searchController.clear,
            icon: Icon(Icons.refresh_rounded, size: 17),
            label: Text('Clear search'),
            style: TextButton.styleFrom(foregroundColor: primaryTeal),
          ),
        ],
      ),
    );
  }

  // Diagnostic error screen: shows the real Firebase error.
  Widget _buildError({Object? error}) {
    final errorMessage = error?.toString() ?? 'Unknown error';

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 550),
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: alertRed.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: alertRed.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: alertRed,
                    size: 31,
                  ),
                ),
              ),
              SizedBox(height: 13),
              Text(
                'Unable to load your pets.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: darkText,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'We encountered a problem loading your pet profiles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grayText,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: alertRed.withValues(alpha: 0.12),
                  ),
                ),
                child: SelectableText(
                  errorMessage,
                  style: TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.refresh_rounded),
                label: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: onPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
