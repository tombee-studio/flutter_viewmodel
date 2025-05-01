import 'package:flutter/widgets.dart';
import 'package:flutter_viewmodel/bases/crud_repository.dart';
import 'package:flutter_viewmodel/bases/model.dart';
import 'package:flutter_viewmodel/bases/notifier.dart';
import 'package:flutter_viewmodel/bases/repository_provider.dart';
import 'package:flutter_viewmodel/bases/view_model.dart';
import 'package:flutter_viewmodel/bases/view_model_state.dart';

abstract class CrudModelStatefulWidget<M> extends StatefulWidget {
  final M? data;
  final RepositoryProvider<CrudRepository<M>> provider;
  const CrudModelStatefulWidget(this.provider, {super.key, this.data});

  @override
  State<StatefulWidget> createState() => _CrudModelStatefulWidget();

  Widget build(BuildContext context);
}

class _CrudModelStatefulWidget<M>
    extends ViewModelState<CrudModelStatefulWidget<M>, _CrudModelViewModel<M>> {
  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  createViewModel() => _CrudModelViewModel<M>(this, widget.provider);
}

class _CrudModelViewModel<M> extends ViewModel<_CrudModel<M>> {
  RepositoryProvider<CrudRepository<M>> provider;

  _CrudModelViewModel(super.notifier, this.provider);

  @override
  _CrudModel<M> createModel(Notifier notifier) =>
      _CrudModel(notifier, provider);
}

class _CrudModel<M> extends Model<CrudRepository<M>> {
  _CrudModel(super.notifier, super.provider);
}
