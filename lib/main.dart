import 'package:flutter/material.dart';
import 'Screens/StartScreen/start_screen.dart';

void main() async {
  runApp(const MainApplication());
}

class MainApplication extends StatelessWidget {
  const MainApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Manager',
      home: SafeArea(child: HomePage(title: 'File Manager')),
    );
  }
}
