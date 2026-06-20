import 'package:flutter/widgets.dart';
import 'view_model.dart';

/// An [InheritedWidget] that provides a [ViewModel] to its subtree.
///
/// Use [ViewModelProvider.of] to retrieve the [ViewModel] from the subtree.
class ViewModelProvider<T extends ViewModel> extends StatefulWidget {
  /// Creates a [ViewModelProvider].
  ///
  /// The [create] function is called once to create the [ViewModel].
  /// The [child] is the widget subtree that can access the [ViewModel].
  const ViewModelProvider({
    super.key,
    required this.create,
    required this.child,
  });

  /// A function that creates the [ViewModel].
  final T Function() create;

  /// The widget subtree that can access the [ViewModel].
  final Widget child;

  /// Retrieves the [ViewModel] of type [T] from the nearest [ViewModelProvider]
  /// ancestor in the widget tree.
  ///
  /// If [listen] is true (the default), the calling widget will rebuild
  /// whenever the [ViewModel] notifies its listeners.
  ///
  /// Throws a [FlutterError] if no [ViewModelProvider] of type [T] is found.
  static T? of<T extends ViewModel>(BuildContext context,
      {bool listen = true}) {
    final provider = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_ViewModelInheritedWidget<T>>()
        : context
            .findAncestorWidgetOfExactType<_ViewModelInheritedWidget<T>>();

    if (provider == null) {
      throw FlutterError(
        'ViewModelProvider.of<$T> called with a context that does not contain a ViewModelProvider<$T>.\n'
        'No ViewModelProvider<$T> ancestor could be found starting from the context that was passed to ViewModelProvider.of<$T>.\n'
        'Make sure that the context you are using to retrieve the ViewModel is a descendant of a ViewModelProvider<$T> widget.',
      );
    }

    return provider.viewModel;
  }

  @override
  State<ViewModelProvider<T>> createState() => _ViewModelProviderState<T>();
}

class _ViewModelProviderState<T extends ViewModel>
    extends State<ViewModelProvider<T>> {
  late T _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.create();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ViewModelInheritedWidget<T>(
      viewModel: _viewModel,
      child: widget.child,
    );
  }
}

class _ViewModelInheritedWidget<T extends ViewModel> extends InheritedWidget {
  const _ViewModelInheritedWidget({
    super.key,
    required this.viewModel,
    required super.child,
  });

  final T viewModel;

  @override
  bool updateShouldNotify(_ViewModelInheritedWidget<T> oldWidget) {
    return oldWidget.viewModel != viewModel;
  }
}
