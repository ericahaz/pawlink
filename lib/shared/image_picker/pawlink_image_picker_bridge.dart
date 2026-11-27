import 'dart:typed_data';
import 'pawlink_image_picker_stub.dart'
    if (dart.library.html) 'pawlink_image_picker_web.dart'
    if (dart.library.io) 'pawlink_image_picker_io.dart';

class PickedPetImage {
  final String name;
  final double sizeMb;
  final Uint8List bytes;

  const PickedPetImage({
    required this.name,
    required this.sizeMb,
    required this.bytes,
  });
}

void pickPetImageFromDevice(void Function(PickedPetImage? result) onPicked) {
  platformPickPetImage(onPicked);
}
