import 'package:flutter_viewmodel/bases/crud_repository_factory.dart';
import 'package:flutter_viewmodel/bases/repository.dart';

abstract class CrudRepository<M> extends Repository {
  Future<List<M>> fetch(CrudRepositoryFactory<M> factory);
  Future<M> fetchItem(CrudRepositoryFactory<M> factory);
  Future<M> create(CrudRepositoryFactory<M> factory);
  Future<M> update(CrudRepositoryFactory<M> factory);
  Future<M> delete(CrudRepositoryFactory<M> factory);
}
