import 'dart:math';

import 'package:flutter/material.dart';

class FileList extends StatefulWidget {
  const FileList();

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
            child: Column(
      children: <Widget>[
        Align(alignment: Alignment.topLeft, child: UpBar(context)),
        Expanded(
            child: ListView.builder(
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(title: Text(index.toString()));
                }))
      ],
    )));
  }
}

class UpBar extends StatefulWidget {
  const UpBar(this.context);

  final BuildContext context;

  @override
  State<UpBar> createState() => _UpBarState();
}

class _UpBarState extends State<UpBar> {
  List<String> folders = [
    'Folder 1',
    'Folder 2',
    'Folder 3',
    "Folder 4",
    "Folder 5"
  ];

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
    allFolders.addAll(folders);

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
                        Navigator.pop(context);
                      }),
                ),
                const Spacer(),
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
