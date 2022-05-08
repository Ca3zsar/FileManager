import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget chart;
  const Background({Key? key, required this.chart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            UpCard(size: size, chart: chart),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text("salutare"),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text("salutare2"),
                      ]),
                ])
          ],
        ));
  }
}

class UpCard extends StatelessWidget {
  const UpCard({
    Key? key,
    required this.size,
    required this.chart,
  }) : super(key: key);

  final Size size;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
          width: size.width * 0.95,
          height: size.height * 0.25,
          child: Card(
            margin: EdgeInsets.zero,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          margin: EdgeInsets.only(left: size.width * 0.05),
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontSize: size.width * 0.06,
                                      color: Colors.white),
                                  children: const <TextSpan>[
                                TextSpan(
                                    text: "File ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: "Manager")
                              ]))),
                      Container(
                          margin: EdgeInsets.only(right: size.width * 0.04),
                          child: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            tooltip: "Settings",
                            icon: Image.asset(
                              "assets/images/settings.png",
                              width: size.width * 0.07,
                              isAntiAlias: true,
                            ),
                            onPressed: () {},
                          ))
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: size.width * 0.05),
                        child: chart,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                      )
                    ],
                  ),
                ]),
            color: const Color.fromARGB(255, 0, 0, 26),
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(40))),
          )),
    );
  }
}
