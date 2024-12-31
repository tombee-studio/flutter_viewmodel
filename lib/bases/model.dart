import 'package:flutter_viewmodel/bases/list_property.dart';
import 'package:flutter_viewmodel/bases/notifier.dart';
import 'package:flutter_viewmodel/bases/property.dart';
import 'package:flutter_viewmodel/bases/repository.dart';
import 'package:flutter_viewmodel/bases/repository_provider.dart';

abstract class Model<T extends Repository> {
  final RepositoryProvider<T> _provider;
  final Notifier _notifier;

  Model(this._notifier, this._provider);

  T get repository => _provider.repository;

  Property<T> propertyOf(T initial) {
    return Property(initial, _notifier);
  }

  ListProperty<T> listPropertyOf(List<T> initial) {
    return ListProperty(initial, _notifier);
  }
}
