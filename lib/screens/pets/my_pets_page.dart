import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  String _searchText = '';

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color alertRed = Color(0xFFDC2626);
  static const Color warmBackground = Color(0xFFFFFBF5);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openRegisterPet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPetPage()),
    );
  }

  void _openPetProfile(String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PetProfilePage(petId: petId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Pets',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegisterPet,
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Register Pet',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _petService.getMyPetsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return _buildError();
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
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  constraints.maxWidth >= 800 ? 40 : 18,
                  24,
                  constraints.maxWidth >= 800 ? 40 : 18,
                  100,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 22),
                        _buildSearch(),
                        const SizedBox(height: 24),
                        if (allPets.isEmpty)
                          _buildEmptyState()
                        else if (pets.isEmpty)
                          _buildNoSearchResults()
                        else
                          _buildPetGrid(pets, constraints.maxWidth),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your pets',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage your pet profiles, QR codes, and ownership.',
          style: TextStyle(color: grayText, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by pet name or breed',
        prefixIcon: const Icon(Icons.search_rounded, color: grayText),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close_rounded, color: grayText),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
      ),
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
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildPetCard(pet),
          );
        }).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pets.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        return _buildPetCard(pets[index]);
      },
    );
  }

  Widget _buildPetCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final petId = data['petId']?.toString() ?? doc.id;
    final name = data['petName']?.toString() ?? 'Unnamed Pet';
    final breed = data['breed']?.toString() ?? 'Breed not specified';
    final age = data['age']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'alive';
    final photoUrl = data['photoUrl']?.toString() ?? '';

    final isAlive = status.toLowerCase() == 'alive';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openPetProfile(petId),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: _buildPetImage(photoUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: darkText,
                              ),
                            ),
                          ),
                          _buildStatus(status, isAlive),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        breed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: grayText, fontSize: 12),
                      ),
                      if (age.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          age,
                          style: const TextStyle(color: grayText, fontSize: 12),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 18,
                            color: primaryTeal,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'QR Profile',
                            style: TextStyle(
                              color: primaryTeal,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: grayText,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage(String photoUrl) {
    if (photoUrl.isEmpty) {
      return Container(
        color: lightTeal,
        child: const Center(
          child: Icon(Icons.pets_rounded, color: primaryTeal, size: 60),
        ),
      );
    }

    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: lightTeal,
          child: const Center(
            child: Icon(Icons.pets_rounded, color: primaryTeal, size: 60),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: lightTeal,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryTeal,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatus(String status, bool alive) {
    final color = alive ? const Color(0xFF15803D) : alertRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: alive
            ? const Color(0xFFEFF8EF)
            : alertRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.pets_rounded, color: primaryTeal, size: 36),
          ),
          const SizedBox(height: 17),
          const Text(
            'No pets registered yet',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Create your first pet profile and give it a PawLink QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(color: grayText, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openRegisterPet,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Register a Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: grayText, size: 40),
          SizedBox(height: 12),
          Text(
            'No matching pets',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another pet name or breed.',
            style: TextStyle(color: grayText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: alertRed, size: 45),
            const SizedBox(height: 12),
            const Text(
              'Unable to load your pets.',
              style: TextStyle(fontWeight: FontWeight.w700, color: darkText),
            ),
            const SizedBox(height: 5),
            const Text(
              'Please check your Firebase connection.',
              style: TextStyle(color: grayText),
            ),
          ],
        ),
      ),
    );
  }
}
