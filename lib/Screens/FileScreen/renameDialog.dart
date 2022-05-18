import 'package:flutter/material.dart';
import 'package:tppm/styles/text_styles.dart';

Future<dynamic> RenameDialog(
    BuildContext context, TextEditingController textField) {
  return showDialog(
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
                child: const Text("Cancel", style: DialogStyle()),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(textField.text);
                  },
                  child: const Text(
                    "Rename",
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
}
