import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../reports/report_found_pet_page.dart';

class PublicPetPage extends StatefulWidget {
  final String petId;

  const PublicPetPage({super.key, required this.petId});

  @override
  State<PublicPetPage> createState() => _PublicPetPageState();
}

class _PublicPetPageState extends State<PublicPetPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getPet() {
    return _firestore.collection('public_pets').doc(widget.petId).get();
  }

  int _selectedPhotoIndex = 0;

  List<String> _readPhotoUrls(Map<String, dynamic> data) {
    final dynamic savedUrls = data['photoUrls'];

    if (savedUrls is List) {
      final urls = savedUrls
          .whereType<String>()
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .take(4)
          .toList();

      if (urls.isNotEmpty) {
        return urls;
      }
    }

    final String legacyUrl = (data['photoUrl'] ?? '').toString().trim();

    return legacyUrl.isEmpty ? <String>[] : <String>[legacyUrl];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        title: const Text('PawLink Pet Profile'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getPet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00897B),
              ),
            );
          }

          if (snapshot.hasError) {
            return const _MessagePage(
              icon: Icons.error_outline,
              title: 'Unable to load pet profile.',
              message: 'Please try again later. If the problem continues, '
                  'contact PawLink support.',
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const _MessagePage(
              icon: Icons.pets_outlined,
              title: 'Pet profile not found.',
              message: 'This QR profile may not have been created yet or '
                  'may no longer be available.',
            );
          }

          final data = snapshot.data!.data()!;

          if (data['qrEnabled'] != true) {
            return const _MessagePage(
              icon: Icons.qr_code_2,
              title: 'QR profile unavailable.',
              message: 'The owner has disabled this pet profile.',
            );
          }

          final String petName = (data['petName'] ?? 'Unknown Pet').toString();
          final String breed = (data['breed'] ?? 'Not specified').toString();
          final String color = (data['color'] ?? 'Not specified').toString();
          final String age = (data['age'] ?? 'Not specified').toString();
          final String status = (data['status'] ?? 'alive').toString();

          final List<String> photoUrls = _readPhotoUrls(data);

          final int selectedIndex = photoUrls.isEmpty
              ? 0
              : _selectedPhotoIndex.clamp(0, photoUrls.length - 1);

          final bool isLost = status.toLowerCase() == 'lost';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MAIN PHOTO
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: photoUrls.isNotEmpty
                      ? Image.network(
                          photoUrls[selectedIndex],
                          key: ValueKey(photoUrls[selectedIndex]),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;

                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF00897B),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.pets,
                              size: 90,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(
                          Icons.pets,
                          size: 90,
                          color: Colors.grey,
                        ),
                ),

                // PHOTO GALLERY
                if (photoUrls.length > 1) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photoUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final bool isSelected = index == selectedIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPhotoIndex = index;
                            });
                          },
                          child: Container(
                            width: 78,
                            height: 78,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00897B)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photoUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Photo ${selectedIndex + 1} of ${photoUrls.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // PET NAME
                Text(
                  petName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 10),

                // PET STATUS
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isLost ? Colors.red.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: isLost
                            ? Colors.red.shade800
                            : Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _InfoCard(
                  icon: Icons.category_outlined,
                  label: 'Breed',
                  value: breed,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.palette_outlined,
                  label: 'Color',
                  value: color,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: age,
                ),

                const SizedBox(height: 28),

                // EXISTING FOUND-PET REPORT ACTION
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportFoundPetPage(
                            petId: widget.petId,
                            petName: petName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.pets),
                    label: const Text(
                      'I Found This Pet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'If you found this pet, you can send a report to '
                  'the owner through PawLink.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MessagePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessagePage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00897B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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
}
