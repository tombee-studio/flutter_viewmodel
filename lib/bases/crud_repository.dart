import 'package:flutter_viewmodel/bases/crud_repository_factory.dart';
import 'package:flutter_viewmodel/bases/repository.dart';

abstract class CrudRepository<M> extends Repository {
  List<M> fetch(CrudRepositoryFactory<M> factory);
  List<M> fetchItem(CrudRepositoryFactory<M> factory);
  M create(CrudRepositoryFactory<M> factory);
  M update(CrudRepositoryFactory<M> factory);
  M delete(CrudRepositoryFactory<M> factory);
}
