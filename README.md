# flutter_file_manager

一个flutter版本的文件管理器，查看SD卡内的文件（android）

### 列出当前文件夹下所有的文件、文件夹
``` dart
Directory currentDir = Directory(path);
List<FileSystemEntity> _files = [];
List<FileSystemEntity> _folder = [];
// 遍历所有文件/文件夹
for (var v in currentDir.listSync()) {
 // 去除以 .开头的文件/文件夹
 if (p.basename(v.path).substring(0, 1) == '.') {
   continue;
 }
 if (FileSystemEntity.isFileSync(v.path))
   _files.add(v);
 else
   _folder.add(v);
}
```

### 打开文件
使用`open_file: 3.2.1`插件
``` dart
OpenFile.open(file.path);
```

### 效果图
<img src="assets/images/image.jpg" width="360" height="640"/>

##### 简书 [flutter版的文件管理器](https://www.jianshu.com/p/a332a20c4ddf)
##### 掘金 [flutter版的文件管理器](https://juejin.im/post/5be3df59e51d4537fc7ad814)