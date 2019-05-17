import 'dart:io';
import 'package:path/path.dart';

selectIcon(bool type, FileSystemEntity file) {
  try {
    String iconImg;
    if (type) {
      String str = extension(file.path);
      switch (str) {
        case '.ppt':
        case '.pptx':
          iconImg = 'assets/images/ppt.png';
          break;
        case '.doc':
        case '.docx':
          iconImg = 'assets/images/word.png';
          break;
        case '.xls':
        case '.xlsx':
          iconImg = 'assets/images/excel.png';
          break;
        case '.jpg':
        case '.jpeg':
        case '.png':
          iconImg = 'assets/images/image.png';
          break;
        case '.txt':
          iconImg = 'assets/images/txt.png';
          break;
        case '.mp3':
          iconImg = 'assets/images/mp3.png';
          break;
        case '.mp4':
          iconImg = 'assets/images/video.png';
          break;
        case '.rar':
        case '.zip':
          iconImg = 'assets/images/zip.png';
          break;
        case '.psd':
          iconImg = 'assets/images/psd.png';
          break;
        default:
          iconImg = 'assets/images/file.png';
          break;
      }
    } else {
      iconImg = 'assets/images/folder.png';
    }
    return iconImg;
  } catch (e) {
    print(e);
    return 'assets/images/unknown.png';
  }
}
