import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'file_manager.dart';

void main() {
  String sDCardDir;

  Future<void> getSDCardDir() async {
    sDCardDir = (await getExternalStorageDirectory()).path;
  }

  // Permission check
  Future<void> getPermission() async {
    if (Platform.isAndroid) {
      bool permission1 = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
      bool permission2 = await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
      if (!permission1) {
        await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
      }
      if (!permission2) {
        await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
      }
      await getSDCardDir();
    } else if (Platform.isIOS) {
      await getSDCardDir();
    }
  }

  Future.wait([getPermission()]).then((result) {
    runApp(MyApp(sDCardDir: sDCardDir));
  });
}

class MyApp extends StatelessWidget {
  MyApp({@required this.sDCardDir});

  final String sDCardDir;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter File Manager',
      theme: ThemeData(
//        platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      home: FileManager(sDCardDir: sDCardDir),
    );
  }
}
