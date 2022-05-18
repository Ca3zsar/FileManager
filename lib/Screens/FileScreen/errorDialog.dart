import 'package:flutter/material.dart';
import 'package:tppm/styles/text_styles.dart';

Future<dynamic> ErrorDialog(BuildContext context, String error) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 0, 26),
          content: Text(error, style: const DialogStyle()),
        );
      });
}
