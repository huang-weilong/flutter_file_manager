import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_manager/common.dart';
import 'package:flutter_file_manager/file_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  Future<void> getSDCardDir() async {
    Common().sDCardDir = (await getExternalStorageDirectory()).path;
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

  Future.wait([initializeDateFormatting("zh_CN", null), getPermission()]).then((result) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter File Manager',
      theme: ThemeData(
//        platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      home: FileManager(),
    );
  }
}
