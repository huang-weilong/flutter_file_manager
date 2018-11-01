import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class FileManager extends StatefulWidget {
  FileManager({@required this.dir});

  final String dir;

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<FileSystemEntity> files = [];
  MethodChannel _channel = MethodChannel('openFileChannel');

  @override
  void initState() {
    super.initState();
    initDirectory(widget.dir);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dir),
        elevation: 0.0,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
        ),
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          return buildItem(files[index]);
        },
      ),
    );
  }

  buildItem(FileSystemEntity file) {
    var bool = FileSystemEntity.isFileSync(file.path);

    return GestureDetector(
      child: Column(
        children: <Widget>[Icon(bool ? Icons.insert_drive_file : Icons.folder), Text(file.path.substring(file.parent.path.length + 1))],
      ),
      onTap: () {
        if (!bool)
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FileManager(
                        dir: file.path,
                      )));
        else
          openFile(file.path);
      },
    );
  }

  Future<void> initDirectory(String path) async {
    try {
      var directory = new Directory(path);
      files = directory.listSync();
    } catch (e) {
      print("目录不存在！");
    }
  }

  openFile(String path) {
    final Map<String, dynamic> args = <String, dynamic>{'path': path};
    _channel.invokeMethod('openFile', args);
  }
}
