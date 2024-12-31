import 'package:flutter_viewmodel/bases/notifier.dart';

class Property<T> {
  T _value;
  final Notifier _onNotified;

  Notifier get onNotified => _onNotified;

  set value(T value) {
    this._value = value;
    _onNotified.notify();
  }

  T get value => _value;

  Property(T initial, this._onNotified) : _value = initial;
}
