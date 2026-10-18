import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCard extends StatelessWidget {
  final String petId;
  final bool qrEnabled;

  const QrCard({
    super.key,
    required this.petId,
    this.qrEnabled = true,
  });

  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color darkTeal = Color(0xFF115E59);
  static const Color lightTeal = Color(0xFFE7F5F2);
  static const Color darkText = Color(0xFF243333);
  static const Color grayText = Color(0xFF667373);
  static const Color borderColor = Color(0xFFE3E5E3);

  // PawLink live website.
  static const String publicBaseUrl = 'https://pawlink-ten.vercel.app';

  @override
  Widget build(BuildContext context) {
    // Remove accidental whitespace from the pet ID.
    final String actualPetId = petId.trim();

    // Each QR code must contain the website URL AND this pet's ID.
    final String publicUrl =
        '$publicBaseUrl/p/${Uri.encodeComponent(actualPetId)}';

    final bool hasValidPetId = actualPetId.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pet QR Code',
            style: TextStyle(
              color: darkText,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Scan this code to open the public pet profile.',
            style: TextStyle(
              color: grayText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          Center(
            child: !qrEnabled || !hasValidPetId
                ? Container(
                    height: 220,
                    width: 220,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          size: 42,
                          color: grayText,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          !qrEnabled ? 'QR code disabled' : 'Pet ID is missing',
                          style: const TextStyle(
                            color: grayText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      // IMPORTANT: Encode the complete pet-specific URL.
                      data: publicUrl,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: lightTeal,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              children: [
                const Text(
                  'PET ID',
                  style: TextStyle(
                    color: grayText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  actualPetId.isEmpty ? 'No pet ID available' : actualPetId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkTeal,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'QR CODE DESTINATION',
            style: TextStyle(
              color: grayText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),

          // This lets you verify the exact URL encoded in the QR code.
          if (hasValidPetId)
            SelectableText(
              publicUrl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkTeal,
                fontSize: 12,
                height: 1.5,
              ),
            )
          else
            const Text(
              'A valid pet ID is required to create the QR URL.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),

          const SizedBox(height: 12),

          const Text(
            'The QR code belongs to this pet profile. '
            'All co-owners use the same QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: grayText,
              fontSize: 12,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.public_rounded,
                  size: 19,
                  color: primaryTeal,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Anyone who scans this QR can access '
                    'the public pet profile without '
                    'creating a PawLink account, provided '
                    'the website route and public data are configured.',
                    style: TextStyle(
                      color: grayText,
                      fontSize: 11.5,
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
}
