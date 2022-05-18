import 'package:flutter/material.dart';
import 'Screens/EditScreen/edit_screen.dart';
import 'Screens/FileScreen/files_list.dart';
import 'Screens/StartScreen/start_screen.dart';

void main() async {
  runApp(const MainApplication());
}

class MainApplication extends StatelessWidget {
  const MainApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) =>
              const SafeArea(child: HomePage(title: 'File Manager')),
          '/filelist': (context) => const SafeArea(child: FileList()),
          '/edit': (context) => const SafeArea(child: EditArea())
        },
        title: 'File Manager');
  }
}
