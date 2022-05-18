import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:io/io.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tppm/Screens/FileScreen/fileCreateDialog.dart';
import 'package:tppm/Screens/FileScreen/renameDialog.dart';
import 'package:tppm/styles/text_styles.dart';
import 'package:tppm/utils/favorites_manager.dart';

import 'deleteDialog.dart';
import 'errorDialog.dart';
import 'utils/paths.dart';

List<int> selectedFiles = [];
List<String> currentPath = [];
List<FileSystemEntity> files = [];
List<FileSystemEntity> filesToMoveCopy = [];

bool filesLoaded = false;
bool notFinishedLoading = false;
bool copyMode = false;
bool moveMode = false;

void changeToEdit(BuildContext context) {
  Navigator.pushNamed(
    context,
    '/edit',
    arguments: files[selectedFiles[0]].path,
  );
}

void goBack(BuildContext context, Function callback) {
  print(currentPath);
  if (currentPath.length == 1) {
    Navigator.pop(context);
  } else {
    currentPath.removeLast();
    selectedFiles.clear();
    callback();
  }
}

void deleteFiles(BuildContext context) async {
  final confirmation = await DeleteDialog(context);
  if (confirmation) {
    List<String> favorites = await loadFavorites();
    for (int i = 0; i < selectedFiles.length; i++) {
      if (favorites.contains(files[selectedFiles[i]].path)) {
        favorites.remove(files[selectedFiles[i]].path);
      }
      files[selectedFiles[i]].delete(recursive: true);
      files.removeAt(selectedFiles[i]);
    }
    writeFavorites(favorites);
  }
  selectedFiles.clear();
}

void renameFile(BuildContext context) async {
  final textField = TextEditingController();
  textField.text = files[selectedFiles[0]].path.split('/').last;
  final newName = await RenameDialog(context, textField);
  if (newName != "") {
    final favorites = await loadFavorites();
    String oldPath = files[selectedFiles[0]].path;
    String newPath = files[selectedFiles[0]].parent.path + "/" + newName;
    if (files.any((element) => element.path == newPath)) {
      ErrorDialog(context, "There is already a file/directory with this name");
    } else {
      files[selectedFiles[0]].renameSync(newPath);
      files[selectedFiles[0]] = File(newPath);

      if (favorites.contains(oldPath)) {
        favorites.remove(oldPath);
        favorites.add(files[selectedFiles[0]].path);
        writeFavorites(favorites);
      }
    }
  }
}

void createTxtFile(BuildContext context, Function callback) async {
  final textField = TextEditingController();
  final fileName = await FileCreateDialog(context, textField);
  if (fileName != '') {
    final file = File(currentPath.join('/') + "/" + fileName + ".txt");
    file.createSync();
    files.add(file);
    callback();
  }
}

void createDirectory(BuildContext context, Function callback) async {
  final textField = TextEditingController();
  final directoryName = await showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 0, 0, 26),
            title: const Text('Create directory',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontFamily: "Gilroy")),
            content: TextField(
                controller: textField,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Directory name',
                ),
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontFamily: "Gilroy")),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop("");
                },
                child: const Text("Cancel", style: DialogStyle()),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(textField.text);
                  },
                  child: const Text(
                    "Create",
                    style: DialogStyle(),
                  ))
            ],
          ),
          onWillPop: () {
            Navigator.of(context).pop("");
            return Future.value(false);
          },
        );
      });
  if (directoryName != '') {
    final directory = Directory(currentPath.join('/') + "/" + directoryName);
    directory.createSync();
    files.add(directory);
    callback();
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
    if (newPath != filesToMoveCopy[i].path) {
      if (filesToMoveCopy[i].statSync().type ==
          FileSystemEntityType.directory) {
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
  String path = '';
  bool pathLoaded = false;
  late Timer timer;
  bool isLoading = true;

  Future<void> saveFavorites() async {
    final favorites = selectedFiles.map((e) => files[e].path).toList();
    addNewFavorites(favorites);
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

  void addToPath(String newPath) {
    currentPath.add(newPath);
    files.clear();
    filesLoaded = false;
    isLoading = true;
  }

  void updateFiles() {
    if (currentPath.isEmpty) {
      getInitialPath(currentPath, type);
    } else {
      try {
        final path = currentPath.join('/');
        files = Directory(path).listSync();
        files.sort((a, b) {
          if (a.statSync().type == FileSystemEntityType.directory &&
              b.statSync().type == FileSystemEntityType.file) {
            return -1;
          } else if (a.statSync().type == FileSystemEntityType.file &&
              b.statSync().type == FileSystemEntityType.directory) {
            return 1;
          } else {
            return a.path.compareTo(b.path);
          }
        });
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
    pathLoaded = false;
    super.initState();
    timer =
        Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      setState(() {
        final args = ModalRoute.of(context)!.settings.arguments as List<String>;
        type = args[0];
        if (!pathLoaded) path = args[1];
        pathLoaded = true;
        if (path == '') {
          if (files.isEmpty && !filesLoaded) {
            updateFiles();
          }

          if (files.isNotEmpty || filesLoaded) {
            isLoading = false;
          }
        } else {
          int startPoint = type == "Internal" ? 4 : 3;
          currentPath = [path.split('/').sublist(0, startPoint).join('/')]
            ..addAll(path.split('/').sublist(startPoint));
          updateFiles();
          path = '';
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

  Row getDownButtons(BuildContext context) {
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
            DownButton(callback: changeToEdit, size: size, text: "edit")
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

  Widget getDownBarWidget(BuildContext context) {
    return Container(
        height: size.height * 0.07,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 0, 0, 26),
        ),
        child: getDownButtons(context));
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: selectedFiles.isNotEmpty || filesToMoveCopy.isNotEmpty,
        child: getDownBarWidget(context));
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
    final args = ModalRoute.of(context)!.settings.arguments as List<String>;
    final type = args[0];
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
                  child: selectedFiles.isEmpty
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          onPressed: () {
                            goBack(context, widget.callback);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          onPressed: () {
                            selectedFiles.clear();
                          }),
                ),
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
                  visible: selectedFiles.isEmpty && filesToMoveCopy.isEmpty,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.only(top: 6)),
                    onPressed: () {
                      createTxtFile(context, widget.callback);
                    },
                    child: Image.asset('assets/images/new_file.png',
                        color: Colors.white, width: size.width * 0.06),
                  ),
                ),
                Visibility(
                    visible: selectedFiles.isEmpty && filesToMoveCopy.isEmpty,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.only(top: 6)),
                      onPressed: () {
                        createDirectory(context, widget.callback);
                      },
                      child: const Icon(
                        Icons.create_new_folder,
                        color: Colors.white,
                      ),
                    )),
                Visibility(
                    visible: selectedFiles.isNotEmpty,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.only(top: 6)),
                      onPressed: () {
                        widget.saveFavorites();
                      },
                      child: const Icon(
                        Icons.favorite_border_outlined,
                        color: Colors.white,
                      ),
                    ))
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
