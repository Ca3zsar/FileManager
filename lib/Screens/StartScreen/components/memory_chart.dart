import 'package:pie_chart/pie_chart.dart';
import 'package:storage_info/storage_info.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MemoryChart extends StatefulWidget {
  const MemoryChart({Key? key, required this.type}) : super(key: key);
  final String type;

  @override
  _MemoryChartState createState() => _MemoryChartState();
}

class _MemoryChartState extends State<MemoryChart> {
  dynamic dataMap = {
    'Used': 0.0,
    'Free': 0.0,
  };

  final legendLabels = <String, String>{
    'Used': 'Used',
    'Free': 'Free',
  };

  final colors = <Color>[
    const Color.fromARGB(239, 219, 20, 20),
    const Color.fromARGB(255, 255, 255, 255)
  ];

  final ChartType _chartType = ChartType.ring;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.type == "Internal") {
        dataMap = <String, double>{
          'Used': await StorageInfo.getStorageUsedSpaceInGB,
          'Free': await StorageInfo.getStorageFreeSpaceInGB,
        };
      } else {
        dataMap = <String, double>{
          'Used': await StorageInfo.getExternalStorageUsedSpaceInGB,
          'Free': await StorageInfo.getExternalStorageFreeSpaceInGB,
        };
      }
      setStateIfMounted(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 500),
      chartLegendSpacing: 16.0,
      chartRadius: min(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height) /
          5,
      ringStrokeWidth: 10,
      colorList: colors,
      chartType: _chartType,
      chartValuesOptions: const ChartValuesOptions(showChartValues: false),
      legendOptions: const LegendOptions(showLegends: false),
    );
  }
}
