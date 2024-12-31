import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_viewmodel_platform_interface.dart';

/// An implementation of [FlutterViewmodelPlatform] that uses method channels.
class MethodChannelFlutterViewmodel extends FlutterViewmodelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_viewmodel');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
