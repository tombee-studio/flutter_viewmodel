import 'package:flutter/foundation.dart';

/// Base class for all ViewModels.
///
/// A ViewModel is responsible for managing the UI state and business logic
/// for a specific part of the UI. It extends [ChangeNotifier] to provide
/// reactive state management.
abstract class ViewModel extends ChangeNotifier {
  /// Called when the ViewModel is first created and attached to a widget.
  ///
  /// Override this method to perform initialization logic.
  void init() {}

  /// Called when the ViewModel is disposed.
  ///
  /// Override this method to perform cleanup logic. Always call [super.dispose()]
  /// when overriding.
  @override
  void dispose() {
    super.dispose();
  }
}
