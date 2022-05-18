import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:io/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tppm/utils/favorites_manager.dart';

List<int> selectedFiles = [];
List<String> currentPath = [];
List<FileSystemEntity> files = [];
List<FileSystemEntity> filesToMoveCopy = [];

bool filesLoaded = false;
bool notFinishedLoading = false;
bool copyMode = false;
bool moveMode = false;

void goBack(BuildContext context, Function callback) {
  if (currentPath.length == 1) {
    Navigator.pop(context);
  } else {
    currentPath.removeLast();
    selectedFiles.clear();
    callback();
  }
}

void deleteFiles(BuildContext context) async {
  List<String> favorites = await loadFavorites();
  for (int i = 0; i < selectedFiles.length; i++) {
    if (favorites.contains(files[selectedFiles[i]].path)) {
      favorites.remove(files[selectedFiles[i]].path);
    }
    files[selectedFiles[i]].delete(recursive: true);
    files.removeAt(selectedFiles[i]);
  }
  writeFavorites(favorites);
  selectedFiles.clear();
}

void renameFile(BuildContext context) async {
  final textField = TextEditingController();
  textField.text = files[selectedFiles[0]].path.split('/').last;
  final newName = await showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 0, 0, 26),
            title: const Text('Rename file',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontFamily: "Gilroy")),
            content: TextField(
                controller: textField,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'New name',
                ),
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontFamily: "Gilroy")),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop("");
                },
                child: const Text("Cancel",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Gilroy")),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(textField.text);
                  },
                  child: const Text(
                    "Rename",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Gilroy"),
                  ))
            ],
          ),
          onWillPop: () {
            Navigator.of(context).pop("");
            return Future.value(false);
          },
        );
      });
  if (newName != "") {
    final favorites = await loadFavorites();
    String oldPath = files[selectedFiles[0]].path;

    files[selectedFiles[0]]
        .renameSync(files[selectedFiles[0]].parent.path + "/" + newName);
    files[selectedFiles[0]] =
        File(files[selectedFiles[0]].parent.path + "/" + newName);
    if (favorites.contains(oldPath)) {
      favorites.remove(oldPath);
      favorites.add(files[selectedFiles[0]].path);
      writeFavorites(favorites);
    }
  }
}

void copyFiles() async {
  List<String> favorites = await loadFavorites();
  String currentPathString = currentPath.join('/');
  for (int i = 0; i < filesToMoveCopy.length; i++) {
    final newPath =
        currentPathString + "/" + filesToMoveCopy[i].path.split('/').last;
    if (filesToMoveCopy[i].statSync().type == FileSystemEntityType.directory) {
      copyPath(filesToMoveCopy[i].path, newPath);
    } else {
      File(filesToMoveCopy[i].path).copy(newPath);
    }
    if (favorites.contains(currentPathString)) {
      favorites.remove(currentPathString);
      favorites.add(newPath);
    }
  }
  writeFavorites(favorites);
  selectedFiles.clear();
  filesToMoveCopy.clear();
  copyMode = false;
  moveMode = false;
  filesLoaded = false;
  files.clear();
}

void moveFiles() async {
  List<String> favorites = await loadFavorites();
  String currentPathString = currentPath.join('/');
  for (int i = 0; i < filesToMoveCopy.length; i++) {
    final newPath =
        currentPathString + "/" + filesToMoveCopy[i].path.split('/').last;
    if (filesToMoveCopy[i].statSync().type == FileSystemEntityType.directory) {
      copyPath(filesToMoveCopy[i].path, newPath);
    } else {
      File(filesToMoveCopy[i].path).copySync(newPath);
    }
    filesToMoveCopy[i].delete(recursive: true);
    if (favorites.contains(currentPathString)) {
      favorites.remove(currentPathString);
      favorites.add(newPath);
    }
  }
  writeFavorites(favorites);
  selectedFiles.clear();
  filesToMoveCopy.clear();
  copyMode = false;
  moveMode = false;
  filesLoaded = false;
  files.clear();
}

void triggerCopy(BuildContext context) {
  copyMode = true;
  filesToMoveCopy.clear();
  for (int i = 0; i < selectedFiles.length; i++) {
    filesToMoveCopy.add(files[selectedFiles[i]]);
  }
  selectedFiles.clear();
}

void triggerMove(BuildContext context) {
  moveMode = true;
  filesToMoveCopy.clear();
  for (int i = 0; i < selectedFiles.length; i++) {
    filesToMoveCopy.add(files[selectedFiles[i]]);
  }
  selectedFiles.clear();
}

class FileList extends StatefulWidget {
  const FileList();

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  String type = '';
  late Timer timer;
  bool isLoading = true;

  Future<void> saveFavorites() async {
    final favorites = selectedFiles.map((e) => files[e].path).toList();
    addNewFavorites(favorites);
  }

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

  ListTile generateFileTile(int index) {
    final icon = files[index].statSync().type == FileSystemEntityType.directory
        ? Image.asset('assets/images/folder.png')
        : Image.asset('assets/images/file.png');

    return ListTile(
      selected: selectedFiles.contains(index),
      leading: icon,
      selectedColor: Colors.black,
      selectedTileColor: Colors.amber,
      title: Text(
        files[index].path.split('/').last,
        style: const TextStyle(
            color: Colors.black,
            fontFamily: "Gilroy",
            fontWeight: FontWeight.w500),
      ),
      onLongPress: () {
        setState(() {
          if (selectedFiles.contains(index)) {
            selectedFiles.remove(index);
          } else {
            selectedFiles.add(index);
          }
        });
      },
      onTap: () {
        setState(() {
          if (selectedFiles.contains(index)) {
            selectedFiles.remove(index);
          } else {
            if (selectedFiles.isNotEmpty && !selectedFiles.contains(index)) {
              selectedFiles.add(index);
            }

            if (files[index].statSync().type ==
                    FileSystemEntityType.directory &&
                selectedFiles.isEmpty) {
              addToPath(files[index].path.split('/').last);
            }
          }
        });
      },
    );
  }

  void getInitialPath() async {
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

  void addToPath(String newPath) {
    currentPath.add(newPath);
    files.clear();
    filesLoaded = false;
    isLoading = true;
  }

  void updateFiles() {
    if (currentPath.isEmpty) {
      getInitialPath();
    } else {
      try {
        final path = currentPath.join('/');
        files = Directory(path).listSync();
        filesLoaded = true;
      } catch (e) {
        filesLoaded = true;
      }
    }
  }

  Widget getFileBody(Size size) {
    if (isLoading) {
      return LoadingAnimationWidget.waveDots(
        color: const Color.fromARGB(255, 0, 0, 26),
        size: 150,
      );
    } else {
      if (files.isNotEmpty) {
        ListView childToReturn = ListView.builder(
            itemCount: files.length,
            itemBuilder: (BuildContext context, int index) {
              return generateFileTile(index);
            });

        return Column(
          children: [Expanded(child: childToReturn), DownBar(size: size)],
        );
      } else {
        return Column(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'No files found',
                  style: TextStyle(
                      fontSize: 40, color: Colors.black, fontFamily: "Gilroy"),
                ),
              ),
            ),
            DownBar(size: size)
          ],
        );
      }
    }
  }

  @override
  void initState() {
    selectedFiles.clear();
    currentPath.clear();
    files.clear();
    filesToMoveCopy.clear();
    copyMode = false;
    moveMode = false;
    filesLoaded = false;

    super.initState();
    timer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      setState(() {
        if (files.isEmpty && !filesLoaded) {
          type = ModalRoute.of(context)!.settings.arguments as String;
          updateFiles();
        }

        if (files.isNotEmpty || filesLoaded) {
          isLoading = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    filesToMoveCopy.clear();
    currentPath.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        goBack(context, updateFiles);
        return Future.value(false);
      },
      child: Material(
          child: SafeArea(
              child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: UpBar(context, updateFiles, saveFavorites)),
          Expanded(child: getFileBody(size))
        ],
      ))),
    );
  }
}

class DownBar extends StatelessWidget {
  const DownBar({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  void cancelOperation() {
    copyMode = false;
    moveMode = false;
    filesToMoveCopy.clear();
  }

  Row getDownButtons() {
    if (!copyMode && !moveMode) {
      return Row(
        children: [
          DownButton(callback: triggerMove, size: size, text: "move"),
          DownButton(callback: triggerCopy, size: size, text: "copy"),
          DownButton(callback: deleteFiles, size: size, text: "delete"),
          if (selectedFiles.length == 1)
            DownButton(callback: renameFile, size: size, text: "rename"),
          if (selectedFiles.length == 1 &&
              files[selectedFiles[0]].path.split('/').last.endsWith(".txt"))
            DownButton(callback: null, size: size, text: "edit")
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      );
    } else {
      return Row(
        children: [
          Text("${filesToMoveCopy.length} selected",
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
          TextButton(
              onPressed: () {
                cancelOperation();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              )),
          TextButton(
              onPressed: copyMode ? copyFiles : moveFiles,
              child: Text(
                copyMode ? "Copy here" : "Move here",
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ))
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      );
    }
  }

  Widget getDownBarWidget() {
    return Container(
        height: size.height * 0.07,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 0, 0, 26),
        ),
        child: getDownButtons());
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: selectedFiles.isNotEmpty || filesToMoveCopy.isNotEmpty,
        child: getDownBarWidget());
  }
}

class DownButton extends StatelessWidget {
  const DownButton(
      {Key? key, required this.size, required this.text, this.callback})
      : super(key: key);

  final Function? callback;
  final Size size;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.only(top: 6)),
      onPressed: () {
        callback!(context);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$text.png',
            width: size.width * 0.075,
            color: Colors.white,
          ),
          Text("${text[0].toUpperCase()}${text.substring(1)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Gilroy",
                  fontSize: 12,
                  fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}

class UpBar extends StatefulWidget {
  final Function callback, saveFavorites;
  const UpBar(this.context, this.callback, this.saveFavorites);

  final BuildContext context;

  @override
  State<UpBar> createState() => _UpBarState();
}

class _UpBarState extends State<UpBar> {
  List<String> folders = [];

  List<Widget> _createPath() {
    final Size size = MediaQuery.of(context).size;
    final type = ModalRoute.of(context)!.settings.arguments as String;
    List<Widget> path = [
      Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          onPressed: () {
            goToStartScreen();
          },
          icon: Image.asset(
            "assets/images/home.png",
            width: size.width * 0.06,
            isAntiAlias: true,
            color: Colors.white,
          ),
        ),
      ),
    ];

    List<dynamic> allFolders = [type];
    if (currentPath.length > 1) {
      allFolders.addAll(currentPath.sublist(1));
    }

    path.add(Expanded(
        child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: allFolders.length * 2,
      itemBuilder: (BuildContext context, int index) {
        if (index % 2 == 0) {
          return const Icon(
            Icons.arrow_right,
            color: Colors.white,
          );
        }
        return Center(
          child: Text(
            allFolders[index ~/ 2],
            style: const TextStyle(
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
              fontFamily: "Gilroy",
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    )));

    return path;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
        height: size.height * 0.12,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 0, 0, 26),
          boxShadow: [
            BoxShadow(
              color: Color(0x476b7d94),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 10), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () {
                        goBack(context, widget.callback);
                      },
                    )),
                Visibility(
                  visible: selectedFiles.isNotEmpty,
                  child: Text("${selectedFiles.length} Selected file(s)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Gilroy",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                const Spacer(),
                Visibility(
                    visible: selectedFiles.isNotEmpty,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.only(top: 6)),
                      onPressed: () {
                        widget.saveFavorites(context);
                      },
                      child: Icon(
                        Icons.favorite_border_outlined,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _createPath()))
          ],
        ));
  }

  void goToStartScreen() {
    Navigator.pop(context);
  }
}
