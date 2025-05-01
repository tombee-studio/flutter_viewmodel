import 'package:flutter_viewmodel/bases/crud_repository_factory.dart';
import 'package:flutter_viewmodel/bases/repository.dart';

abstract class CrudRepository<M, C> extends Repository {
  Future<List<M>> fetch(CrudRepositoryFactory<C> factory);
  Future<M> fetchItem(int id, CrudRepositoryFactory<C> factory);
  Future<M> create(CrudRepositoryFactory<C> factory);
  Future<M> update(int id, CrudRepositoryFactory<C> factory);
  Future<M> delete(int id, CrudRepositoryFactory<C> factory);
}
