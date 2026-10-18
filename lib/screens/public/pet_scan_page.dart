import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'public_pet_page.dart';

class PetScanPage extends StatefulWidget {
  const PetScanPage({super.key});

  @override
  State<PetScanPage> createState() => _PetScanPageState();
}

class _PetScanPageState extends State<PetScanPage> {
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  String? _extractPetId(String value) {
    final String scannedValue = value.trim();

    // Accept a PawLink URL such as:
    // https://pawlink-pet-2026.web.app/p/PET_ID
    final Uri? uri = Uri.tryParse(scannedValue);

    if (uri != null && uri.hasScheme && uri.host == 'pawlink-ten.vercel.app') {
      final List<String> segments = uri.pathSegments;

      if (segments.length == 2 && segments[0] == 'p') {
        final String petId = segments[1].trim();

        if (petId.isNotEmpty) {
          return petId;
        }
      }
    }

    // Also accept a direct pet ID if the QR contains only the ID.
    if (scannedValue.isNotEmpty &&
        !scannedValue.contains('/') &&
        !scannedValue.contains(' ') &&
        !scannedValue.contains(':')) {
      return scannedValue;
    }

    return null;
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final String? value = barcode.rawValue;

      if (value == null || value.trim().isEmpty) continue;

      final String? petId = _extractPetId(value);

      if (petId == null) {
        setState(() {
          _errorMessage =
              'Invalid QR code. Please scan a valid PawLink pet QR code.';
        });
        return;
      }

      _isProcessing = true;
      await _scannerController.stop();

      if (!mounted) return;

      Navigator.of(context)
          .push(
        MaterialPageRoute<void>(
          builder: (_) => PublicPetPage(petId: petId),
        ),
      )
          .then((_) {
        if (!mounted) return;

        _isProcessing = false;

        setState(() {
          _errorMessage = null;
        });

        _scannerController.start();
      });

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        title: const Text('Scan Pet QR Code'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Switch camera',
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
          ),
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: () => _scannerController.toggleTorch(),
            icon: const Icon(Icons.flashlight_on),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Scan a PawLink pet QR code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Position the QR code inside the scanning frame to view the pet profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _handleDetection,
                    ),
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF80CBC4),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFF00897B),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Make sure the entire QR code is visible.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
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
