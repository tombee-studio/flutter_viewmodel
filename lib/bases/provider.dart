class Provider<T> {
  T? _instance;

  late T Function() _generator;
  T get instance => _instance ??= _generator();

  Provider(this._generator);

  void overrideRepository(T Function() generator) {
    _generator = generator;
  }
}
