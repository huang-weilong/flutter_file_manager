import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'selection_icon.dart';
import 'click_effect.dart';

class FileManager extends StatefulWidget {
  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<FileSystemEntity> files = [];
  MethodChannel _channel = MethodChannel('openFileChannel');
  Directory parentDir;
  ScrollController controller = ScrollController();
  int count = 0; // 记录当前文件夹中以 . 开头的文件和文件夹
  String sDCardDir;

  @override
  void initState() {
    super.initState();
    getSDCardDir();
  }

  Future<void> getSDCardDir() async {
    sDCardDir = (await getExternalStorageDirectory()).path;
    parentDir = Directory(sDCardDir);
    initDirectory(sDCardDir);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (parentDir.path != sDCardDir) {
          initDirectory(parentDir.parent.path);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              parentDir?.path == sDCardDir ? 'SD Card' : parentDir.path.substring(parentDir.parent.path.length + 1),
              style: TextStyle(color: Colors.black),
            ),
            elevation: 0.4,
            centerTitle: true,
            backgroundColor: Color(0xffeeeeee),
            leading: parentDir?.path == sDCardDir
                ? Container()
                : IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (parentDir.path != sDCardDir) {
                        initDirectory(parentDir.parent.path);
                      } else {
                        Navigator.pop(context);
                      }
                    }),
          ),
          backgroundColor: Color(0xfff3f3f3),
          body: files.length != 0
              ? Scrollbar(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildListViewItem(files[index]);
                    },
                  ),
                )
              : ListView(
                  controller: controller,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - MediaQuery.of(context).padding.top - 56.0),
                      child: Center(
                        child: Text('The folderddd is empty'),
                      ),
                    )
                  ],
                )),
    );
  }

  buildListViewItem(FileSystemEntity file) {
    var isFile = FileSystemEntity.isFileSync(file.path);
    // 去除以 . 开头的文件和文件夹
    if (file.path.substring(file.parent.path.length + 1).substring(0, 1) == '.') {
      count++;
      if (count != files.length) {
        return Container();
      } else {
        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - MediaQuery.of(context).padding.top - 56.0),
          child: Center(
            child: Text('The folder is empty'),
          ),
        );
      }
    }

    return ClickEffect(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Image.asset(selectIcon(isFile, file)),
            title: Text(file.path.substring(file.parent.path.length + 1)),
            trailing: isFile ? null : Icon(Icons.chevron_right),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Divider(
              height: 1.0,
            ),
          )
        ],
      ),
      onTap: () {
        if (!isFile)
          initDirectory(file.path);
        else
          openFile(file.path);
      },
    );
  }

  Future<void> initDirectory(String path) async {
    try {
      setState(() {
        var directory = Directory(path);
        count = 0;
        parentDir = directory;
        files.clear();
        files = directory.listSync();
        controller.jumpTo(0.0);
      });
    } catch (e) {
      print("Directory does not exist！");
    }
  }

  openFile(String path) {
    final Map<String, dynamic> args = <String, dynamic>{'path': path};
    _channel.invokeMethod('openFile', args);
  }
}
