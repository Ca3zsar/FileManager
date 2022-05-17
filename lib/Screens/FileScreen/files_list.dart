import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tppm/utils/favorites_manager.dart';

List<int> selectedFiles = [];
List<String> currentPath = [];
List<FileSystemEntity> files = [];
bool filesLoaded = false;
bool notFinishedLoading = false;

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

        return Stack(
          children: [childToReturn, DownBar(size: size)],
        );
      } else {
        return const Center(
          child: Text(
            'No files found',
            style: TextStyle(
                fontSize: 40, color: Colors.black, fontFamily: "Gilroy"),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    selectedFiles.clear();
    currentPath.clear();
    files.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Material(
        child: SafeArea(
            child: Column(
      children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: UpBar(context, updateFiles, saveFavorites)),
        Expanded(child: getFileBody(size))
      ],
    )));
  }
}

class DownBar extends StatelessWidget {
  const DownBar({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: selectedFiles.isNotEmpty,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: size.height * 0.07,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 0, 0, 26),
          ),
        ),
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

  void goBack(BuildContext context) {
    if (currentPath.length == 1) {
      Navigator.pop(context);
    } else {
      currentPath.removeLast();
      widget.callback();
    }
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
                        goBack(context);
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
                  child: IconButton(
                      onPressed: () {
                        widget.saveFavorites();
                      },
                      icon: const Icon(Icons.favorite_outline_sharp,
                          color: Colors.white)),
                ),
                IconButton(
                    icon: Transform.rotate(
                      angle: -pi / 2,
                      child: Image.asset(
                        "assets/images/settings.png",
                        width: size.width * 0.05,
                        isAntiAlias: true,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      //
                    }),
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
