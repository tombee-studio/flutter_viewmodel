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

abstract class CrudModelStatefulWidgetState<M, C> extends ViewModelState<
    CrudModelStatefulWidget<M>, _CrudModelViewModel<M, C>> {
  @override
  createViewModel() =>
      _CrudModelViewModel<M, C>(this, createRepository(), createModel(this));

  CrudModel<M, C> createModel(Notifier notifier);
  RepositoryProvider<CrudRepository<M, C>> createRepository();
}

class _CrudModelViewModel<M, C> extends ViewModel<CrudModel<M, C>> {
  final CrudModel<M, C> targetModel;
  RepositoryProvider<CrudRepository<M, C>> provider;

  CrudRepository<M, C> get repository => model.repository;

  _CrudModelViewModel(super.notifier, this.provider, this.targetModel);

  @override
  CrudModel<M, C> createModel(Notifier notifier) => targetModel;

  Future<M> create() {
    return model.create();
  }

  Future<M> update() {
    return model.update();
  }
}

abstract class CrudModel<M, C> extends Model<CrudRepository<M, C>> {
  CrudModel(super.notifier, super.provider);

  Future<M> create();
  Future<M> update();
}
