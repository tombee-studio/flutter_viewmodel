import 'package:flutter/widgets.dart';

import 'view_model.dart';

/// Signature for a function that creates a [ViewModel].
typedef ViewModelCreate<T extends ViewModel> = T Function(BuildContext context);

/// A widget that creates a [ViewModel] and supplies it to the widget subtree.
///
/// The [ViewModel] is created once and persists across widget rebuilds. It is
/// automatically disposed when this widget is removed from the tree.
class ViewModelProvider<T extends ViewModel> extends StatefulWidget {
  const ViewModelProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  /// Creates the [ViewModel] instance to be provided.
  final ViewModelCreate<T> create;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Obtains the nearest [ViewModel] of type [T] up the widget tree.
  static T of<T extends ViewModel>(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ViewModelScope<T>>();
    assert(
      inherited != null,
      'No ViewModelProvider<$T> found in context.',
    );
    return inherited!.viewModel;
  }

  @override
  State<ViewModelProvider<T>> createState() => _ViewModelProviderState<T>();
}

class _ViewModelProviderState<T extends ViewModel>
    extends State<ViewModelProvider<T>> {
  late final T _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.create(context);
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ViewModelScope<T>(
      viewModel: _viewModel,
      child: widget.child,
    );
  }
}

class _ViewModelScope<T extends ViewModel> extends InheritedWidget {
  const _ViewModelScope({
    Key? key,
    required this.viewModel,
    required Widget child,
  }) : super(key: key, child: child);

  final T viewModel;

  @override
  bool updateShouldNotify(_ViewModelScope<T> oldWidget) {
    return viewModel != oldWidget.viewModel;
  }
}
