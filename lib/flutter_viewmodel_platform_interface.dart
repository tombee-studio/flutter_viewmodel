import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_viewmodel_method_channel.dart';

abstract class FlutterViewmodelPlatform extends PlatformInterface {
  /// Constructs a FlutterViewmodelPlatform.
  FlutterViewmodelPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterViewmodelPlatform _instance = MethodChannelFlutterViewmodel();

  /// The default instance of [FlutterViewmodelPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterViewmodel].
  static FlutterViewmodelPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterViewmodelPlatform] when
  /// they register themselves.
  static set instance(FlutterViewmodelPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
