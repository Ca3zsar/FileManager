import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory> getExternalSdCardPath() async {
  List<Directory>? extDirectories = await getExternalStorageDirectories();
  List<String>? dirs = extDirectories![1].toString().split('/');

  String rebuiltPath = '/' + dirs[1] + '/' + dirs[2] + '/';

  return Directory(rebuiltPath);
}

Future<Directory> getInternalStoragePath() async {
  final directory = await getExternalStorageDirectory();
  List<String>? dirs = directory?.path.split('/');
  String rebuiltPath = '/' + dirs![1] + '/' + dirs[2] + '/' + dirs[3];
  return Directory(rebuiltPath);
}

void getInitialPath(List<String> currentPath, String type) async {
  Future<Directory> Function() function;
  if (currentPath.isEmpty) {
    if (type == 'Internal') {
      function = getInternalStoragePath;
    } else {
      function = getExternalSdCardPath;
    }
    final newPathPart = await function();
    currentPath.add(newPathPart.path);
  }
}
