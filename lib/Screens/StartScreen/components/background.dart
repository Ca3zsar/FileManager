import 'dart:math';

import 'package:flutter/material.dart';
import 'package:storage_info/storage_info.dart';
import 'package:tppm/Screens/StartScreen/components/up_clipper.dart';
import 'package:tppm/Screens/StartScreen/components/favorites.dart';
import 'memory_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tppm/Screens/StartScreen/data/constants.dart';
import 'storage_type.dart';

int enabledButton = 0;

class Background extends StatefulWidget {
  const Background({Key? key}) : super(key: key);

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
        child: Column(
          children: <Widget>[
            Align(alignment: Alignment.topLeft, child: UpCard(size: size)),
            Expanded(
              child: StartBody(size: size),
            )
          ],
        ));
  }
}

class StartBody extends StatefulWidget {
  const StartBody({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  State<StartBody> createState() => _StartBodyState();
}

class _StartBodyState extends State<StartBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: widget.size.width * 0.08),
      child: Column(children: [
        Favorites(height: widget.size.height),
        MediaQuery.removeViewPadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
                itemCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return StorageTypeWidget(storageTypeList[index],
                      storagePaths[index], storageIcons[index]);
                }))
      ]),
    );
  }
}

class UpCard extends StatelessWidget {
  final double height;
  final double width;

  UpCard({
    Key? key,
    required this.size,
  })  : height = size.height * 0.32,
        width = size.width,
        super(key: key);

  final Size size;
  final GlobalKey<_CarouselInfoState> _carousel = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: ClipPath(
          clipper: HeaderClipper(45),
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
                                  letterSpacing: 0.42,
                                  fontSize: size.width * 0.065,
                                  color: Colors.white),
                              children: const <TextSpan>[
                            TextSpan(
                                text: "File ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "Manager",
                                style: TextStyle(letterSpacing: 0.42))
                          ]))),
                  Container(
                      margin: EdgeInsets.only(right: size.width * 0.04),
                      child: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        tooltip: "Settings",
                        icon: Transform.rotate(
                          angle: -pi / 2,
                          child: Image.asset(
                            "assets/images/settings.png",
                            width: size.width * 0.06,
                            isAntiAlias: true,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {},
                      ))
                ],
              ),
              SizedBox(
                width: width,
                height: height * 0.45,
                child: CarouselInfo(
                    key: _carousel, height: height, size: size, width: width),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        switchMemory(0);
                      },
                      child: Text("Internal",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold))),
                  Text("|",
                      style: TextStyle(
                          color: Colors.white, fontSize: size.width * 0.05)),
                  TextButton(
                      onPressed: () {
                        switchMemory(1);
                      },
                      child: Text("External",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold))),
                ],
              )
            ]),
            color: const Color.fromARGB(255, 0, 0, 26),
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(40))),
          ),
        ));
  }

  void switchMemory(int i) {
    _carousel.currentState?.buttonCarouselController.animateToPage(i);
  }
}

class CarouselInfo extends StatefulWidget {
  const CarouselInfo({
    Key? key,
    required this.height,
    required this.size,
    required this.width,
  }) : super(key: key);

  final double height;
  final Size size;
  final double width;

  @override
  State<CarouselInfo> createState() => _CarouselInfoState();
}

class _CarouselInfoState extends State<CarouselInfo> {
  final CarouselController buttonCarouselController = CarouselController();
  List<bool> visibilities = [true, false];

  dynamic changeVisibility(int index, CarouselPageChangedReason reason) {
    setState(() {
      for (int i = 0; i < visibilities.length; i++) {
        visibilities[i] = !visibilities[i];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        carouselController: buttonCarouselController,
        options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: changeVisibility,
            enlargeCenterPage: true,
            enableInfiniteScroll: false),
        items: [
          Visibility(
            visible: visibilities[0],
            child: MemoryArea(
                height: widget.height,
                size: widget.size,
                chart: const MemoryChart(type: "Internal"),
                width: widget.width,
                type: "Internal"),
          ),
          Visibility(
            visible: visibilities[1],
            child: MemoryArea(
                height: widget.height,
                size: widget.size,
                chart: const MemoryChart(type: "External"),
                width: widget.width,
                type: "External"),
          ),
        ]);
  }
}

class MemoryArea extends StatelessWidget {
  const MemoryArea(
      {Key? key,
      required this.height,
      required this.size,
      required this.chart,
      required this.width,
      required this.type})
      : super(key: key);

  final String type;
  final double height;
  final Size size;
  final MemoryChart chart;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: height * 0.5,
          margin: EdgeInsets.only(left: size.width * 0.05),
          child: chart,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child:
                UsedInfo(size: size, height: height, width: width, type: type),
          ),
        )
      ],
    );
  }
}

class UsedInfo extends StatefulWidget {
  const UsedInfo({
    Key? key,
    required this.size,
    required this.height,
    required this.width,
    required this.type,
  }) : super(key: key);

  final String type;
  final Size size;
  final double height;
  final double width;

  @override
  State<StatefulWidget> createState() => _UsedInfoState();
}

class _UsedInfoState extends State<UsedInfo> {
  double used = 0;
  double total = 0;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.type == "Internal") {
        used = await StorageInfo.getStorageUsedSpaceInGB;
        total = await StorageInfo.getStorageTotalSpaceInGB;
      } else {
        used = await StorageInfo.getExternalStorageUsedSpaceInGB;
        total = await StorageInfo.getExternalStorageTotalSpaceInGB;
      }
      setStateIfMounted(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height * 0.45,
      width: widget.width * 0.5,
      child: Column(
        children: [
          SizedBox(
            height: widget.height * 0.45 * 0.5,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text("Used Storage",
                  style: TextStyle(
                      fontSize: widget.size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.left),
            ),
          ),
          SizedBox(
            height: widget.height * 0.45 * 0.5,
            // width: widget.width * 0.5,
            child: Align(
              alignment: Alignment.topLeft,
              child: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontSize: widget.size.width * 0.05,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                    TextSpan(
                        text: used.toString() + "GB",
                        style: TextStyle(
                            color:
                                used < total / 2 ? Colors.green : Colors.red)),
                    const TextSpan(text: " / "),
                    TextSpan(
                      text: total.toString() + "GB",
                    )
                  ])),
            ),
          )
        ],
      ),
    );
  }
}
