import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'file_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dir;

  @override
  void initState() {
    super.initState();
    getDir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: RaisedButton(
          child: Text('打开文件管理器'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => FileManager(dir: dir,)));
          },
        ),
      ),
    );
  }

  Future<void> getDir() async {
    dir = (await getExternalStorageDirectory()).path;
  }
}
