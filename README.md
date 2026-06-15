# flutter_viewmodel

A Flutter package that introduces the ViewModel pattern for Flutter applications, inspired by Android's Architecture Components ViewModel. It provides a clean way to separate business logic from UI, manage state, and survive widget rebuilds.

## Features

- **ViewModel lifecycle management**: ViewModels are created once and persist across widget rebuilds.
- **Automatic disposal**: ViewModels are disposed when they are no longer needed.
- **Clean separation of concerns**: Keep business logic out of your widgets.
- **Reactive UI updates**: Uses `ChangeNotifier` to notify widgets of state changes.

## Getting Started

Add `flutter_viewmodel` to your `pubspec.yaml`:

