import 'package:flutter_viewmodel/bases/crud_repository_factory.dart';
import 'package:flutter_viewmodel/bases/repository.dart';

abstract class CrudRepository<M, C> extends Repository {
  Future<List<M>> fetch(CrudRepositoryFactory<C> factory);
  Future<M> fetchItem(CrudRepositoryFactory<C> factory);
  Future<M> create(CrudRepositoryFactory<C> factory);
  Future<M> update(CrudRepositoryFactory<C> factory);
  Future<M> delete(CrudRepositoryFactory<C> factory);
}
