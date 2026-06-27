import 'package:flutter/foundation.dart';

/// Base class for all ViewModels.
///
/// A [ViewModel] manages UI state and business logic separately from
/// Flutter widgets. It extends [ChangeNotifier] so that widgets can react
/// to state changes.
abstract class ViewModel extends ChangeNotifier {
  bool _initialized = false;
  bool _disposed = false;

  /// Whether [init] has already been called.
  bool get initialized => _initialized;

  /// Whether this ViewModel has been disposed.
  bool get isDisposed => _disposed;

  /// Called once when the ViewModel is first created and attached to the
  /// widget tree.
  void init() {
    _initialized = true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
