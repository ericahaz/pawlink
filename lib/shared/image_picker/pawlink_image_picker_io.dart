import 'dart:io';
import 'pawlink_image_picker_bridge.dart';

void platformPickPetImage(void Function(PickedPetImage? result) onPicked) {
  try {
    final script = r'''
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Title = "Select Pet Photo from Album"
$dialog.Filter = "Image Files (*.jpg;*.jpeg;*.png;*.webp;*.bmp)|*.jpg;*.jpeg;*.png;*.webp;*.bmp"
$dialog.InitialDirectory = [Environment]::GetFolderPath("MyPictures")
if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output $dialog.FileName
}
''';

    Process.run('powershell', ['-NoProfile', '-Command', script]).then((result) {
      final path = (result.stdout as String).trim();
      if (path.isNotEmpty) {
        final file = File(path);
        if (file.existsSync()) {
          final bytes = file.readAsBytesSync();
          final sizeMb = bytes.length / (1024 * 1024);
          final fileName = file.uri.pathSegments.last;
          onPicked(PickedPetImage(
            name: fileName,
            sizeMb: sizeMb,
            bytes: bytes,
          ));
          return;
        }
      }
      onPicked(null);
    }, onError: (Object? _) {
      onPicked(null);
    });
  } catch (_) {
    onPicked(null);
  }
}
