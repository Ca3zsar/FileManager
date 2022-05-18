import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../styles/text_styles.dart';

TextEditingController? _controller;

void saveModifications(BuildContext context) {
  String filePath = ModalRoute.of(context)!.settings.arguments as String;
  File file = File(filePath);
  file.writeAsStringSync(_controller!.text);
}

void askForPermission(BuildContext context) async {
  final confirmation = await showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 0, 0, 26),
            title: const Text('Save modifications?',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontFamily: "Gilroy")),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop("");
                },
                child: const Text("Cancel", style: DialogStyle()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop("no");
                },
                child: const Text("No", style: DialogStyle()),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("yes");
                  },
                  child: const Text(
                    "Yes",
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
  if (confirmation != '') {
    if (confirmation == 'yes') {
      saveModifications(context);
    }
    Navigator.pop(context);
  }
}

class EditArea extends StatefulWidget {
  const EditArea({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _EditAreaState();
  }
}

class _EditAreaState extends State<EditArea> {
  @override
  void initState() {
    _controller = TextEditingController();
    Future.delayed(Duration.zero, () {
      String filePath = ModalRoute.of(context)!.settings.arguments as String;
      final String fileContent =
          File(filePath).readAsStringSync(encoding: utf8);
      _controller!.text = fileContent;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      child: Material(
          child: SafeArea(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
            Align(alignment: Alignment.topLeft, child: UpBar(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottom),
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: size.width * 0.9,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null, //grow automatically
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
            )
          ]))),
      onWillPop: () {
        askForPermission(context);
        return Future<bool>.value(false);
      },
    );
  }
}

class UpBar extends StatefulWidget {
  const UpBar(this.context);

  final BuildContext context;

  @override
  State<UpBar> createState() => _UpBarState();
}

class _UpBarState extends State<UpBar> {
  String fileName = '';

  @override
  Widget build(BuildContext context) {
    fileName = ModalRoute.of(context)!.settings.arguments as String;
    fileName = fileName.split('/').last;
    final Size size = MediaQuery.of(context).size;
    return Container(
        height: size.height * 0.07,
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
                        askForPermission(context);
                      },
                    )),
                Text(fileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Gilroy",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ))
              ],
            ),
          ],
        ));
  }

  void goToStartScreen() {
    Navigator.pop(context);
  }
}
