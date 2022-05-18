import 'package:flutter/material.dart';
import 'package:tppm/styles/text_styles.dart';

Future<dynamic> DeleteDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 0, 0, 26),
            title: const Text('Delete file(s) ?',
                style: TextStyle(
                    color: Colors.white, fontSize: 20, fontFamily: "Gilroy")),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel", style: DialogStyle()),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text(
                    "Confirm",
                    style: DialogStyle(),
                  ))
            ],
          ),
          onWillPop: () {
            Navigator.of(context).pop(false);
            return Future.value(false);
          },
        );
      });
}
