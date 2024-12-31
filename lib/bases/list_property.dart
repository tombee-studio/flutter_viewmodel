import 'package:flutter_viewmodel/bases/property.dart';

class ListProperty<T> extends Property<List<T>> {
  ListProperty(super.initial, super.onNotified);

  void add(T item) {
    value.add(item);
    onNotified.notify();
  }

  void remove(T item) {
    value.remove(item);
    onNotified.notify();
  }
}
