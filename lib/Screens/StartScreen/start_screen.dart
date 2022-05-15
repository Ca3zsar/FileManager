import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:tppm/Screens/StartScreen/components/entire_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void requestPermission() async {
    var statusInternal = await Permission.storage.status;
    if (!statusInternal.isGranted) {
      await Permission.storage.request();
    }

    var statusExternal = await Permission.manageExternalStorage.status;
    if (!statusExternal.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body:
            MainBody() // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
