import 'package:flutter/widgets.dart';

import 'view_model.dart';
import 'view_model_provider.dart';

/// Signature for building a widget from a [ViewModel].
typedef ViewModelWidgetBuilder<T extends ViewModel> = Widget Function(
  BuildContext context,
  T viewModel,
  Widget? child,
);

/// A widget that rebuilds in response to [ViewModel] state changes.
///
/// The [ViewModel] is obtained from the nearest [ViewModelProvider] of type
/// [T] unless an explicit [viewModel] is provided.
class ViewModelBuilder<T extends ViewModel> extends StatefulWidget {
  const ViewModelBuilder({
    Key? key,
    required this.builder,
    this.viewModel,
    this.child,
  }) : super(key: key);

  /// Builds the widget tree using the current [ViewModel] state.
  final ViewModelWidgetBuilder<T> builder;

  /// An optional explicit [ViewModel]. When null, the [ViewModel] is read from
  /// the nearest [ViewModelProvider].
  final T? viewModel;

  /// An optional child that does not depend on the [ViewModel] state.
  final Widget? child;

  @override
  State<ViewModelBuilder<T>> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends ViewModel>
    extends State<ViewModelBuilder<T>> {
  T? _viewModel;

  T _resolveViewModel() {
    return widget.viewModel ?? ViewModelProvider.of<T>(context);
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _subscribe(T viewModel) {
    _viewModel = viewModel;
    _viewModel!.addListener(_onChanged);
  }

  void _unsubscribe() {
    _viewModel?.removeListener(_onChanged);
    _viewModel = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final resolved = _resolveViewModel();
    if (!identical(resolved, _viewModel)) {
      _unsubscribe();
      _subscribe(resolved);
    }
  }

  @override
  void didUpdateWidget(ViewModelBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resolved = _resolveViewModel();
    if (!identical(resolved, _viewModel)) {
      _unsubscribe();
      _subscribe(resolved);
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _viewModel!, widget.child);
  }
}
