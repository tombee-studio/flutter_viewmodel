import 'package:flutter_viewmodel/bases/provider.dart';
import 'package:flutter_viewmodel/bases/repository.dart';

class RepositoryProvider<T extends Repository> extends Provider<T> {
  T get repository => instance;

  RepositoryProvider(super.generator);
}
