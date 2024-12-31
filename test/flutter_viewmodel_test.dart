import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_viewmodel/flutter_viewmodel.dart';
import 'package:flutter_viewmodel/flutter_viewmodel_platform_interface.dart';
import 'package:flutter_viewmodel/flutter_viewmodel_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterViewmodelPlatform
    with MockPlatformInterfaceMixin
    implements FlutterViewmodelPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterViewmodelPlatform initialPlatform = FlutterViewmodelPlatform.instance;

  test('$MethodChannelFlutterViewmodel is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterViewmodel>());
  });

  test('getPlatformVersion', () async {
    FlutterViewmodel flutterViewmodelPlugin = FlutterViewmodel();
    MockFlutterViewmodelPlatform fakePlatform = MockFlutterViewmodelPlatform();
    FlutterViewmodelPlatform.instance = fakePlatform;

    expect(await flutterViewmodelPlugin.getPlatformVersion(), '42');
  });
}
