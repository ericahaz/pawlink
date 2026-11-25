
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum _PetQrTagShape {
  square,
  circle,
}

class PetQrPrintButton extends StatelessWidget {
  final String petId;
  final String petName;
  final bool qrEnabled;

  const PetQrPrintButton({
    super.key,
    required this.petId,
    required this.petName,
    required this.qrEnabled,
  });

  Future<Uint8List> _generateQrImage() async {
    final String qrData =
        'https://pawlink-ten.vercel.app/p/${Uri.encodeComponent(petId)}';

    final painter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      gapless: true,
    );

    final ByteData? byteData = await painter.toImageData(
      800,
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Unable to generate QR code image.');
    }

    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> _generatePdf(_PetQrTagShape shape) async {
    final qrBytes = await _generateQrImage();
    final qrImage = pw.MemoryImage(qrBytes);

    final pdf = pw.Document();

    const double tagSize = 127.56;
    const double columnGap = 12;
    const double rowGap = 10;

    final String safePetName =
        petName.trim().isEmpty ? 'Pet' : petName.trim();

    final bool isCircle = shape == _PetQrTagShape.circle;

    pw.Widget buildTag() {
      return pw.Container(
        width: tagSize,
        height: tagSize,
        padding: const pw.EdgeInsets.all(7),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(
            color: PdfColors.grey700,
            width: 0.8,
          ),
          shape: isCircle
              ? pw.BoxShape.circle
              : pw.BoxShape.rectangle,
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.SizedBox(
              height: 12,
              child: pw.Center(
                child: pw.Text(
                  safePetName,
                  textAlign: pw.TextAlign.center,
                  maxLines: 1,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Image(
              qrImage,
              width: isCircle ? 64 : 72,
              height: isCircle ? 64 : 72,
              fit: pw.BoxFit.contain,
            ),
            pw.SizedBox(height: 4),
            pw.SizedBox(
              height: 12,
              child: pw.Center(
                child: pw.Text(
                  'SCAN ME',
                  textAlign: pw.TextAlign.center,
                  maxLines: 1,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildTagCell() {
      return pw.SizedBox(
        width: tagSize,
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            buildTag(),
            pw.SizedBox(height: 3),
            pw.Text(
              'PLEASE CUT HERE',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(
                fontSize: 6,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.min,
              children: List.generate(5, (rowIndex) {
                return pw.Padding(
                  padding: pw.EdgeInsets.only(
                    bottom: rowIndex == 4 ? 0 : rowGap,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      buildTagCell(),
                      pw.SizedBox(width: columnGap),
                      buildTagCell(),
                      pw.SizedBox(width: columnGap),
                      buildTagCell(),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _printTag(
    BuildContext context,
    _PetQrTagShape shape,
  ) async {
    try {
      final pdfBytes = await _generatePdf(shape);

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'PawLink_${petId}_QR_Tags.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to print QR tags: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPrintOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Print Pet QR Tag'),
          content: const Text(
            'Choose the shape of your pet QR tag.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _printTag(context, _PetQrTagShape.square);
              },
              child: const Text('Square'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _printTag(context, _PetQrTagShape.circle);
              },
              child: const Text('Circle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: qrEnabled && petId.trim().isNotEmpty
          ? () => _showPrintOptions(context)
          : null,
      icon: const Icon(Icons.print_outlined),
      label: const Text('Print QR Tag'),
    );
  }
}
