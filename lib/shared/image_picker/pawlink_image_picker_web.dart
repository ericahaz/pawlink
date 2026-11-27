// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';
import 'pawlink_image_picker_bridge.dart';

void platformPickPetImage(void Function(PickedPetImage? result) onPicked) {
  try {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;

    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) {
        onPicked(null);
        return;
      }

      final file = files.first;
      final sizeMb = file.size / (1024 * 1024);

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        final rawResult = reader.result;
        if (rawResult != null && rawResult is Uint8List) {
          onPicked(PickedPetImage(
            name: file.name,
            sizeMb: sizeMb,
            bytes: rawResult,
          ));
        } else if (rawResult != null && rawResult is ByteBuffer) {
          onPicked(PickedPetImage(
            name: file.name,
            sizeMb: sizeMb,
            bytes: rawResult.asUint8List(),
          ));
        } else {
          onPicked(null);
        }
      });
    });
  } catch (_) {
    onPicked(null);
  }
}
