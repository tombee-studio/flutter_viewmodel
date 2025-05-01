import 'package:flutter/widgets.dart';
import 'package:flutter_viewmodel/bases/crud_repository.dart';
import 'package:flutter_viewmodel/bases/model.dart';
import 'package:flutter_viewmodel/bases/notifier.dart';
import 'package:flutter_viewmodel/bases/repository_provider.dart';
import 'package:flutter_viewmodel/bases/view_model.dart';
import 'package:flutter_viewmodel/bases/view_model_state.dart';

abstract class CrudModelStatefulWidget<M> extends StatefulWidget {
  final M? data;
  const CrudModelStatefulWidget({super.key, this.data});
}

abstract class _CrudModelStatefulWidget<M>
    extends ViewModelState<CrudModelStatefulWidget<M>, _CrudModelViewModel<M>> {
  @override
  createViewModel() =>
      _CrudModelViewModel<M>(this, createRepository(), createModel(this));

  CrudModel<M> createModel(Notifier notifier);
  RepositoryProvider<CrudRepository<M>> createRepository();
}

class _CrudModelViewModel<M> extends ViewModel<CrudModel<M>> {
  final CrudModel<M> targetModel;
  RepositoryProvider<CrudRepository<M>> provider;

  CrudRepository<M> get repository => model.repository;

  _CrudModelViewModel(super.notifier, this.provider, this.targetModel);

  @override
  CrudModel<M> createModel(Notifier notifier) => targetModel;
}

class CrudModel<M> extends Model<CrudRepository<M>> {
  CrudModel(super.notifier, super.provider);
}
