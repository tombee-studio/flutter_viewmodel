import 'package:flutter/widgets.dart';

import 'view_model.dart';
import 'view_model_provider.dart';

/// Rebuilds the UI in response to [ViewModel] state changes.
class ViewModelBuilder<T extends ViewModel> extends StatelessWidget {
  const ViewModelBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  /// Builds the widget tree from the current [ViewModel] state.
  final Widget Function(BuildContext context, T viewModel, Widget? child)
      builder;

  /// An optional child that is independent of the [ViewModel] state.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final viewModel = ViewModelProvider.of<T>(context);
    return builder(context, viewModel, child);
  }
}
