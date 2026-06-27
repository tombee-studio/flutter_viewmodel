import 'package:flutter/foundation.dart';

/// Base class to manage UI state and business logic separately from
/// Flutter widgets.
///
/// Extend this class to implement your own view models. Use [notifyListeners]
/// to notify listeners (typically a `ViewModelBuilder`) about state changes.
abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;

  /// Whether this view model has been disposed.
  bool get isDisposed => _disposed;

  /// Called once after the view model is created and attached to the widget
  /// tree.
  void init() {}

  @override
  void notifyListeners() {
    if (_disposed) {
      return;
    }
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
