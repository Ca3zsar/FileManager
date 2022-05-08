import 'package:flutter/material.dart';
import 'package:storage_info/storage_info.dart';
import 'memory_chart.dart';

class Background extends StatefulWidget {
  final MemoryChart chart;
  const Background({Key? key, required this.chart}) : super(key: key);

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            UpCard(size: size, chart: widget.chart),
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
  final double height;
  final double width;

  UpCard({
    Key? key,
    required this.size,
    required this.chart,
  })  : height = size.height * 0.25,
        width = size.width * 0.95,
        super(key: key);

  final Size size;
  final MemoryChart chart;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
          width: width,
          height: height,
          child: Card(
            margin: EdgeInsets.zero,
            child: Column(children: <Widget>[
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
                                  letterSpacing: 1.1,
                                  fontSize: size.width * 0.065,
                                  color: Colors.white),
                              children: const <TextSpan>[
                            TextSpan(
                                text: "File ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                    height: height * 0.5,
                    margin: EdgeInsets.only(left: size.width * 0.05),
                    child: chart,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                  ),
                  UsedInfo(size: size, height: height, width: width)
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

class UsedInfo extends StatefulWidget {
  const UsedInfo({
    Key? key,
    required this.size,
    required this.height,
    required this.width,
  }) : super(key: key);

  final Size size;
  final double height;
  final double width;

  @override
  State<StatefulWidget> createState() => _UsedInfoState();
}

class _UsedInfoState extends State<UsedInfo> {
  double used = 0;
  double total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      used = await StorageInfo.getStorageUsedSpaceInGB;
      total = await StorageInfo.getStorageTotalSpaceInGB;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: widget.size.width * 0.05),
      child: SizedBox(
        height: widget.height * 0.45,
        child: Column(
          children: [
            SizedBox(
              height: widget.height * 0.45 * 0.5,
              width: widget.width * 0.5,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text("Used Storage",
                    style: TextStyle(
                        fontSize: widget.size.width * 0.045,
                        color: Colors.white),
                    textAlign: TextAlign.left),
              ),
            ),
            SizedBox(
              height: widget.height * 0.45 * 0.5,
              width: widget.width * 0.5,
              child: Align(
                alignment: Alignment.topLeft,
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            letterSpacing: 1.1,
                            fontSize: widget.size.width * 0.05,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                      TextSpan(
                          text: used.toString() + "GB",
                          style: TextStyle(
                              color: used < total / 2
                                  ? Colors.green
                                  : Colors.red)),
                      const TextSpan(text: " / "),
                      TextSpan(
                        text: total.toString() + "GB",
                      )
                    ])),
              ),
            )
          ],
        ),
      ),
    );
  }
}
