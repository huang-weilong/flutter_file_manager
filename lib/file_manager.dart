import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_file_manager/common.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

/// 点击一个文件夹，传入文件夹的路径，显示该文件夹下的文件和文件夹
/// 点击一个文件，打开
/// 返回上一层，返回上一层目录路径 [dir.parent.path]
class FileManager extends StatefulWidget {
  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<FileSystemEntity> files = [];
  Directory parentDir;
  ScrollController controller = ScrollController();
  List<double> position = [];

  @override
  void initState() {
    super.initState();
    parentDir = Directory(Common().sDCardDir);
    initPathFiles(Common().sDCardDir);
  }

  Future<bool> onWillPop() async {
    if (parentDir.path != Common().sDCardDir) {
      initPathFiles(parentDir.parent.path);
      jumpToPosition(false);
    } else {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            parentDir?.path == Common().sDCardDir ? 'SD Card' : p.basename(parentDir.path),
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Color(0xffeeeeee),
          elevation: 0.0,
          leading: parentDir?.path == Common().sDCardDir
              ? Container()
              : IconButton(icon: Icon(Icons.chevron_left, color: Colors.black), onPressed: onWillPop),
        ),
        body: files.length == 0
            ? Center(child: Text('The folder is empty'))
            : Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: controller,
                  itemCount: files.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (FileSystemEntity.isFileSync(files[index].path))
                      return _buildFileItem(files[index]);
                    else
                      return _buildFolderItem(files[index]);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildFileItem(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN').format(file.statSync().modified.toLocal());

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset(Common().selectIcon(p.extension(file.path))),
          title: Text(file.path.substring(file.parent.path.length + 1)),
          subtitle: Text('$modifiedTime  ${Common().getFileSize(file.statSync().size)}', style: TextStyle(fontSize: 12.0)),
        ),
      ),
      onTap: () {
        OpenFile.open(file.path);
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child: Text('重命名', style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    renameFile(file);
                  },
                ),
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child: Text('删除', style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    deleteFile(file);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFolderItem(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN').format(file.statSync().modified.toLocal());

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset('assets/images/folder.png'),
          title: Row(
            children: <Widget>[
              Expanded(child: Text(file.path.substring(file.parent.path.length + 1))),
              Text(
                '${_calculateFilesCountByFolder(file)}项',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          subtitle: Text(modifiedTime, style: TextStyle(fontSize: 12.0)),
          trailing: Icon(Icons.chevron_right),
        ),
      ),
      onTap: () {
        // 点进一个文件夹，记录进去之前的offset
        // 返回上一层跳回这个offset，再清除该offset
        position.add(controller.offset);
        initPathFiles(file.path);
        jumpToPosition(true);
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child: Text('重命名', style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    renameFile(file);
                  },
                ),
                CupertinoButton(
                  pressedOpacity: 0.6,
                  child: Text('删除', style: TextStyle(color: Color(0xff333333))),
                  onPressed: () {
                    Navigator.pop(context);
                    deleteFile(file);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 计算以 . 开头的文件、文件夹总数
  int _calculatePointBegin(List<FileSystemEntity> fileList) {
    int count = 0;
    for (var v in fileList) {
      if (p.basename(v.path).substring(0, 1) == '.') count++;
    }

    return count;
  }

  // 计算文件夹内 文件、文件夹的数量，以 . 开头的除外
  int _calculateFilesCountByFolder(Directory path) {
    var dir = path.listSync();
    int count = dir.length - _calculatePointBegin(dir);

    return count;
  }

  void jumpToPosition(bool isEnter) async {
    if (isEnter)
      controller.jumpTo(0.0);
    else {
      try {
        await Future.delayed(Duration(milliseconds: 1));
        controller?.jumpTo(position[position.length - 1]);
      } catch (e) {}
      position.removeLast();
    }
  }

  // 初始化该路径下的文件、文件夹
  void initPathFiles(String path) {
    try {
      setState(() {
        parentDir = Directory(path);
        sortFiles();
      });
    } catch (e) {
      print(e);
      print("Directory does not exist！");
    }
  }

  void deleteFile(FileSystemEntity file) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('重命名'),
          content: Text('删除后不可恢复'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('取消', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('确定', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                if (file.statSync().type == FileSystemEntityType.directory) {
                  Directory directory = Directory(file.path);
                  directory.deleteSync(recursive: true);
                } else if (file.statSync().type == FileSystemEntityType.file) {
                  file.deleteSync();
                }

                initPathFiles(file.parent.path);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // 重命名
  void renameFile(FileSystemEntity file) {
    TextEditingController _controller = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CupertinoAlertDialog(
              title: Text('重命名'),
              content: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
                    hintText: '请输入新名称',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('取消', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('确定', style: TextStyle(color: Colors.blue)),
                  onPressed: () async {
                    String newName = _controller.text;
                    if (newName.trim().length == 0) {
                      Fluttertoast.showToast(msg: '名字不能为空', gravity: ToastGravity.CENTER);
                      return;
                    }

                    String newPath = file.parent.path + '/' + newName + p.extension(file.path);
                    file.renameSync(newPath);
                    initPathFiles(file.parent.path);

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 排序
  void sortFiles() {
    List<FileSystemEntity> _files = [];
    List<FileSystemEntity> _folder = [];

    for (var v in parentDir.listSync()) {
      // 去除以 .开头的文件/文件夹
      if (p.basename(v.path).substring(0, 1) == '.') {
        continue;
      }
      if (FileSystemEntity.isFileSync(v.path))
        _files.add(v);
      else
        _folder.add(v);
    }

    _files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    _folder.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.clear();
    files.addAll(_folder);
    files.addAll(_files);
  }
}
