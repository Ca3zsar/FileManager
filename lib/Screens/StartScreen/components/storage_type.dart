// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class StorageTypeWidget extends StatelessWidget {
  final String type, path, iconPath;
  const StorageTypeWidget(this.type, this.path, this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 7.5,
        bottom: 7.5,
      ),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color(0x476b7d94),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 10), // changes position of shadow
          ),
        ],
        color: const Color(0xf7f7f7f7),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/filelist', arguments: [type, ""]);
        },
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 25,
              ),
              child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Image(image: AssetImage("assets/images/$iconPath"))),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  type,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xff26262e),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
