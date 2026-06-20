import 'package:flutter/widgets.dart';
import 'view_model.dart';
import 'view_model_provider.dart';

/// A widget that rebuilds in response to [ViewModel] state changes.
///
/// [ViewModelBuilder] listens to the [ViewModel] provided by the nearest
/// [ViewModelProvider] ancestor and rebuilds its subtree whenever the
/// [ViewModel] notifies its listeners.
class ViewModelBuilder<T extends ViewModel> extends StatefulWidget {
  /// Creates a [ViewModelBuilder].
  ///
  /// The [builder] function is called whenever the [ViewModel] notifies
  /// its listeners.
  ///
  /// The optional [child] widget is passed to the [builder] function and
  /// can be used for parts of the widget tree that do not depend on the
  /// [ViewModel] state, improving performance by avoiding unnecessary rebuilds.
  const ViewModelBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  /// A builder function that creates the widget tree based on the [ViewModel] state.
  final Widget Function(BuildContext context, T viewModel, Widget? child)
      builder;

  /// An optional widget that is passed to the [builder] function.
  final Widget? child;

  @override
  State<ViewModelBuilder<T>> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends ViewModel>
    extends State<ViewModelBuilder<T>> {
  T? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newViewModel = ViewModelProvider.of<T>(context);
    if (_viewModel != newViewModel) {
      _viewModel?.removeListener(_onViewModelChanged);
      _viewModel = newViewModel;
      _viewModel?.addListener(_onViewModelChanged);
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _viewModel as T, widget.child);
  }
}
