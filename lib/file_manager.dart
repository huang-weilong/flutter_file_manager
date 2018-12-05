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
  List<double> position = [];

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
          jumpToPosition(false);
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
                        jumpToPosition(false);
                      } else {
                        Navigator.pop(context);
                      }
                    }),
          ),
          backgroundColor: Color(0xfff3f3f3),
          body: Scrollbar(
            child: ListView.builder(
              controller: controller,
              itemCount: files.length != 0 ? files.length : 1,
              itemBuilder: (BuildContext context, int index) {
                if (files.length != 0)
                  return buildListViewItem(files[index]);
                else
                  return Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2 - MediaQuery.of(context).padding.top - 56.0),
                    child: Center(
                      child: Text('The folder is empty'),
                    ),
                  );
              },
            ),
          )),
    );
  }

  // 计算文件夹内 文件、文件夹的数量，以 . 开头的除外
  removePointBegin(Directory path) {
    var dir = Directory(path.path).listSync();
    int num = dir.length;

    for (int i = 0; i < dir.length; i++) {
      if (dir[i].path.substring(dir[i].parent.path.length + 1).substring(0, 1) == '.') num--;
    }
    return num;
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

    int length = 0;
    if (!isFile) length = removePointBegin(file);

    return ClickEffect(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Image.asset(selectIcon(isFile, file)),
            title: Row(
              children: <Widget>[
                Expanded(child: Text(file.path.substring(file.parent.path.length + 1))),
                isFile
                    ? Container()
                    : Text(
                        '$length项',
                        style: TextStyle(color: Colors.grey),
                      )
              ],
            ),
            subtitle: isFile ? Text(getFileSize(file)) : null,
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
        if (!isFile) {
          position.insert(position.length, controller.offset);
          initDirectory(file.path);
          jumpToPosition(true);
        } else
          openFile(file.path);
      },
    );
  }

  void jumpToPosition(bool isEnter) {
    if (isEnter)
      controller.jumpTo(0.0);
    else {
      controller.jumpTo(position[position.length - 1]);
      position.removeLast();
    }
  }

  Future<void> initDirectory(String path) async {
    try {
      setState(() {
        var directory = Directory(path);
        count = 0;
        parentDir = directory;
        files.clear();
        files = directory.listSync();
      });
    } catch (e) {
      print(e);
      print("Directory does not exist！");
    }
  }

  getFileSize(FileSystemEntity file) {
    int fileSize = File(file.resolveSymbolicLinksSync()).lengthSync();
    if (fileSize < 1024) {
      // b
      return '${fileSize.toStringAsFixed(2)}B';
    } else if (1024 <= fileSize && fileSize < 1048576) {
      // kb
      return '${(fileSize / 1024).toStringAsFixed(2)}KB';
    } else if (1048576 <= fileSize && fileSize < 1073741824) {
      // mb
      return '${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB';
    }
  }

  openFile(String path) {
    final Map<String, dynamic> args = <String, dynamic>{'path': path};
    _channel.invokeMethod('openFile', args);
  }
}
