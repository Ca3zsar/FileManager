import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
        color: const Color(0xf7f7f7f7),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
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
    );
  }
}
