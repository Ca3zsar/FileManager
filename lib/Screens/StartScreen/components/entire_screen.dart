import 'package:flutter/material.dart';
import 'package:tppm/Screens/StartScreen/components/background.dart';

class MainBody extends StatelessWidget {
  const MainBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Background());
  }
}
