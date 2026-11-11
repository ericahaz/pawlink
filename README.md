# PawLink organized `lib`

This package contains the reorganized PawLink source tree.

## How to use it
Replace the `lib` folder in your existing Flutter project with the `lib` folder here.
Do **not** remove your existing `pubspec.yaml`, `android`, or `web` folders.

Then open the whole Flutter project in VS Code, for example:

`C:\Users\Steven Sanchez\Documents\my_app`

VS Code Explorer will display every PawLink feature as folders and subfolders under `lib`.

## Run
```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

The existing project must keep `qr_flutter` in `pubspec.yaml`.
