import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_viewmodel/bases/crud_repository.dart';
import 'package:flutter_viewmodel/bases/crud_repository_factory.dart';
import 'package:flutter_viewmodel/flutter_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterViewmodelPlugin = FlutterViewmodel();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _flutterViewmodelPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}

final class TestData {
  final int id;
  final String name;

  TestData({required this.id, required this.name});
}

class TestDataCrudAppRepository extends CrudRepository<TestData> {
  @override
  TestData create(CrudRepositoryFactory<TestData> factory) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  TestData delete(CrudRepositoryFactory<TestData> factory) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  List<TestData> fetch(CrudRepositoryFactory<TestData> factory) {
    // TODO: implement fetch
    throw UnimplementedError();
  }

  @override
  List<TestData> fetchItem(CrudRepositoryFactory<TestData> factory) {
    // TODO: implement fetchItem
    throw UnimplementedError();
  }

  @override
  TestData update(CrudRepositoryFactory<TestData> factory) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
