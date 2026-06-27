import 'package:flutter/widgets.dart';

import 'view_model.dart';

/// Supplies a [ViewModel] instance to the widget subtree.
class ViewModelProvider<T extends ViewModel> extends StatefulWidget {
  const ViewModelProvider({
    super.key,
    required this.create,
    required this.child,
  });

  /// Builds the [ViewModel] instance.
  final T Function(BuildContext context) create;

  /// The widget below this provider in the tree.
  final Widget child;

  /// Obtains the nearest [ViewModel] of type [T] up the widget tree.
  static T of<T extends ViewModel>(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedViewModel<T>>();
    assert(
      inherited != null,
      'No ViewModelProvider<$T> found in context',
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
    if (!_viewModel.initialized) {
      _viewModel.init();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedViewModel<T>(
      viewModel: _viewModel,
      child: widget.child,
    );
  }
}

class _InheritedViewModel<T extends ViewModel> extends InheritedNotifier<T> {
  const _InheritedViewModel({
    required this.viewModel,
    required super.child,
  }) : super(notifier: viewModel);

  final T viewModel;
}
