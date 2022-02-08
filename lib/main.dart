import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

// Initialized two global keys for first chart and second chart wrapped inside statefull widget classes.
final chart1Key = GlobalKey<_InfiniteScrolling1State>();
final chart2Key = GlobalKey<_InfiniteScrolling2State>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfiniteScrolling1(
                  // Set the global key for the first chart
                  key: chart1Key,
                ),
                InfiniteScrolling2(
                  // Set the global key for the second chart
                  key: chart2Key,
                ),
              ],
            ),
          )),
    );
  }
}

// Initialize two global variables for zoom factor and zoom position with default values.
double zoomP = 0;
double zoomF = 1;

/// Renders the first chart with load more builder.
class InfiniteScrolling1 extends StatefulWidget {
  const InfiniteScrolling1({Key? key}) : super(key: key);

  @override
  _InfiniteScrolling1State createState() => _InfiniteScrolling1State();
}

/// State class of the first chart.
class _InfiniteScrolling1State extends State {
  _InfiniteScrolling1State();

  ChartSeriesController? seriesController;
  late List<ChartSampleData> chartData;
  late bool isLoadMoreView, isNeedToUpdateView, isDataUpdated;
  double? oldAxisVisibleMin, oldAxisVisibleMax;
  late ZoomPanBehavior _zoomPanBehavior;
  late GlobalKey<State> globalKey;
  late GlobalKey<State> globalKey1;
  bool isRendered = false;

  @override
  void initState() {
    _initializeVariables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildInfiniteScrollingChart();
  }

  void _initializeVariables() {
    chartData = <ChartSampleData>[
      ChartSampleData(xValue: 0, y: 326),
      ChartSampleData(xValue: 1, y: 416),
      ChartSampleData(xValue: 2, y: 290),
      ChartSampleData(xValue: 3, y: 70),
      ChartSampleData(xValue: 4, y: 500),
      ChartSampleData(xValue: 5, y: 416),
      ChartSampleData(xValue: 6, y: 290),
      ChartSampleData(xValue: 7, y: 120),
      ChartSampleData(xValue: 8, y: 500),
    ];

    isLoadMoreView = false;
    isNeedToUpdateView = false;
    isDataUpdated = true;
    globalKey = GlobalKey<State>();
    globalKey1 = GlobalKey<State>();
    _zoomPanBehavior = ZoomPanBehavior(
        enablePanning: true,
        zoomMode: ZoomMode.x,
        enableDoubleTapZooming: true);
  }

  SfCartesianChart _buildInfiniteScrollingChart() {
    return SfCartesianChart(
      key: GlobalKey<State>(),
      onActualRangeChanged: (ActualRangeChangedArgs args) {
        if (args.orientation == AxisOrientation.horizontal) {
          if (isLoadMoreView) {
            args.visibleMin = oldAxisVisibleMin;
            args.visibleMax = oldAxisVisibleMax;
          }
          oldAxisVisibleMin = args.visibleMin as double;
          oldAxisVisibleMax = args.visibleMax as double;
        }
        isLoadMoreView = false;
      },
      // Used the onZooming event to retrieve the zoom factor and zoom position changed on panning from the first chart to use for the second chart.
      onZooming: (ZoomPanArgs args) {
        if (args.axis!.name == 'XAxis') {
          zoomP = args.currentZoomPosition;
          zoomF = args.currentZoomFactor;
          // Refreshed the second chart using its key.
          chart2Key.currentState!.setState(() {});
        }
      },
      zoomPanBehavior: _zoomPanBehavior,
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
          name: 'XAxis',
          interval: 2,
          enableAutoIntervalOnZooming: false,
          // Set the zoomfactor and zoom position values in the x-axis.
          zoomFactor: zoomF,
          zoomPosition: zoomP),
      primaryYAxis: NumericAxis(),
      series: getSeries(),
      loadMoreIndicatorBuilder:
          (BuildContext context, ChartSwipeDirection direction) =>
              getloadMoreIndicatorBuilder(context, direction),
    );
  }

  List<ChartSeries<ChartSampleData, num>> getSeries() {
    return <ChartSeries<ChartSampleData, num>>[
      SplineAreaSeries<ChartSampleData, num>(
        dataSource: chartData,
        color: const Color.fromRGBO(75, 135, 185, 0.6),
        borderColor: const Color.fromRGBO(75, 135, 185, 1),
        borderWidth: 2,
        animationDuration: 0,
        xValueMapper: (ChartSampleData sales, _) => sales.xValue as num,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        onRendererCreated: (ChartSeriesController controller) {
          seriesController = controller;
        },
      ),
    ];
  }

  Widget getloadMoreIndicatorBuilder(
      BuildContext context, ChartSwipeDirection direction) {
    if (direction == ChartSwipeDirection.end) {
      isNeedToUpdateView = true;
      globalKey = GlobalKey<State>();
      return StatefulBuilder(
          key: globalKey,
          builder: (BuildContext context, StateSetter stateSetter) {
            Widget widget;
            if (isNeedToUpdateView) {
              widget = getProgressIndicator();
              _updateView();
              isDataUpdated = true;
              // When updating the view of teh first chart call the corresponding updateView method of second chart for
              // synchronization to take place when load more is performed.
              chart2Key.currentState?._updateView();
              chart2Key.currentState?.isDataUpdated = true;
            } else {
              widget = Container();
            }
            return widget;
          });
    } else {
      return SizedBox.fromSize(size: Size.zero);
    }
  }

  Widget getProgressIndicator() {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Container(
                width: 50,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.74)
                  ], stops: const <double>[
                    0.0,
                    1
                  ]),
                ),
                child: const SizedBox(
                    height: 35,
                    width: 35,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      backgroundColor: Colors.transparent,
                      strokeWidth: 3,
                    )))));
  }

  void _updateData() {
    for (int i = 0; i < 4; i++) {
      chartData.add(ChartSampleData(
          xValue: chartData[chartData.length - 1].xValue! + 1,
          y: getRandomInt(0, 600)));
    }
    isLoadMoreView = true;
    seriesController?.updateDataSource(addedDataIndexes: getIndexes(4));
  }

  Future<void> _updateView() async {
    await Future<void>.delayed(const Duration(seconds: 1), () {
      isNeedToUpdateView = false;
      if (isDataUpdated) {
        _updateData();
        isDataUpdated = false;
      }
      if (globalKey.currentState != null) {
        (globalKey.currentState as dynamic).setState(() {});
      }
    });
  }

  List<int> getIndexes(int length) {
    final List<int> indexes = <int>[];
    for (int i = length - 1; i >= 0; i--) {
      indexes.add(chartData.length - 1 - i);
    }
    return indexes;
  }

  int getRandomInt(int min, int max) {
    final Random random = Random();
    final int result = min + random.nextInt(max - min);
    return result < 50 ? 95 : result;
  }

  void chartRefresh() {
    setState(() {});
  }

  @override
  void dispose() {
    seriesController = null;
    super.dispose();
  }
}

/// Renders the second chart with load more builder.
class InfiniteScrolling2 extends StatefulWidget {
  const InfiniteScrolling2({Key? key}) : super(key: key);

  @override
  _InfiniteScrolling2State createState() => _InfiniteScrolling2State();
}

/// State class of the second chart
class _InfiniteScrolling2State extends State {
  _InfiniteScrolling2State();

  ChartSeriesController? seriesController;
  late List<ChartSampleData> chartData;

  late bool isLoadMoreView, isNeedToUpdateView, isDataUpdated;

  double? oldAxisVisibleMin, oldAxisVisibleMax;

  late ZoomPanBehavior _zoomPanBehavior;

  late GlobalKey<State> globalKey;

  late GlobalKey<State> globalKey1;

  @override
  void initState() {
    _initializeVariables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildInfiniteScrollingChart();
  }

  void _initializeVariables() {
    chartData = <ChartSampleData>[
      ChartSampleData(xValue: 0, y: 326),
      ChartSampleData(xValue: 1, y: 416),
      ChartSampleData(xValue: 2, y: 290),
      ChartSampleData(xValue: 3, y: 70),
      ChartSampleData(xValue: 4, y: 500),
      ChartSampleData(xValue: 5, y: 416),
      ChartSampleData(xValue: 6, y: 290),
      ChartSampleData(xValue: 7, y: 120),
      ChartSampleData(xValue: 8, y: 500),
    ];
    isLoadMoreView = false;
    isNeedToUpdateView = false;
    isDataUpdated = true;
    globalKey = GlobalKey<State>();
    globalKey1 = GlobalKey<State>();
    _zoomPanBehavior =
        ZoomPanBehavior(enablePanning: true, zoomMode: ZoomMode.x);
  }

  SfCartesianChart _buildInfiniteScrollingChart() {
    return SfCartesianChart(
      key: GlobalKey<State>(),
      onActualRangeChanged: (ActualRangeChangedArgs args) {
        if (args.orientation == AxisOrientation.horizontal) {
          if (isLoadMoreView) {
            args.visibleMin = oldAxisVisibleMin;
            args.visibleMax = oldAxisVisibleMax;
          }
          oldAxisVisibleMin = args.visibleMin as double;
          oldAxisVisibleMax = args.visibleMax as double;
        }
        isLoadMoreView = false;
      },
      // Used the onZooming event to retrieve the zoom factor and zoom position changed on panning from the second chart to use for the first chart.
      onZooming: (ZoomPanArgs args) {
        if (args.axis!.name == 'XAxis') {
          zoomP = args.currentZoomPosition;
          zoomF = args.currentZoomFactor;
          // Refreshed the first chart using its key.
          chart1Key.currentState!.setState(() {});
        }
      },
      zoomPanBehavior: _zoomPanBehavior,
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
          name: 'XAxis',
          interval: 2,
          enableAutoIntervalOnZooming: false,
          // Set the zoomfactor and zoom position values in the x-axis.
          zoomFactor: zoomF,
          zoomPosition: zoomP),
      primaryYAxis: NumericAxis(),
      series: getSeries(),
      loadMoreIndicatorBuilder:
          (BuildContext context, ChartSwipeDirection direction) =>
              getloadMoreIndicatorBuilder(context, direction),
    );
  }

  List<ChartSeries<ChartSampleData, num>> getSeries() {
    return <ChartSeries<ChartSampleData, num>>[
      SplineAreaSeries<ChartSampleData, num>(
        dataSource: chartData,
        color: const Color.fromRGBO(75, 135, 185, 0.6),
        borderColor: const Color.fromRGBO(75, 135, 185, 1),
        borderWidth: 2,
        animationDuration: 0,
        xValueMapper: (ChartSampleData sales, _) => sales.xValue as num,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        onRendererCreated: (ChartSeriesController controller) {
          seriesController = controller;
        },
      ),
    ];
  }

  Widget getloadMoreIndicatorBuilder(
      BuildContext context, ChartSwipeDirection direction) {
    if (direction == ChartSwipeDirection.end) {
      isNeedToUpdateView = true;
      globalKey = GlobalKey<State>();
      return StatefulBuilder(
          key: globalKey,
          builder: (BuildContext context, StateSetter stateSetter) {
            Widget widget;
            if (isNeedToUpdateView) {
              widget = getProgressIndicator();
              _updateView();
              isDataUpdated = true;
              // When updating the view of the seconf chart call the corresponding updateView method of first chart for
              // synchronization to take place when load more is performed.
              chart1Key.currentState?._updateView();
              chart1Key.currentState?.isDataUpdated = true;
            } else {
              widget = Container();
            }
            return widget;
          });
    } else {
      return SizedBox.fromSize(size: Size.zero);
    }
  }

  // In second chart
  Widget getProgressIndicator() {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Container(
                width: 50,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.74)
                  ], stops: const <double>[
                    0.0,
                    1
                  ]),
                ),
                child: const SizedBox(
                    height: 35,
                    width: 35,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      backgroundColor: Colors.transparent,
                      strokeWidth: 3,
                    )))));
  }

  void _updateData() {
    for (int i = 0; i < 4; i++) {
      chartData.add(ChartSampleData(
          xValue: chartData[chartData.length - 1].xValue! + 1,
          y: getRandomInt(0, 600)));
    }
    isLoadMoreView = true;
    seriesController?.updateDataSource(addedDataIndexes: getIndexes(4));
  }

  Future<void> _updateView() async {
    await Future<void>.delayed(const Duration(seconds: 1), () {
      isNeedToUpdateView = false;
      if (isDataUpdated) {
        _updateData();
        isDataUpdated = false;
      }
      if (globalKey.currentState != null) {
        (globalKey.currentState as dynamic).setState(() {});
      }
    });
  }

  List<int> getIndexes(int length) {
    final List<int> indexes = <int>[];
    for (int i = length - 1; i >= 0; i--) {
      indexes.add(chartData.length - 1 - i);
    }
    return indexes;
  }

  int getRandomInt(int min, int max) {
    final Random random = Random();
    final int result = min + random.nextInt(max - min);
    return result < 50 ? 95 : result;
  }

  void chartRefresh() {
    setState(() {});
  }

  @override
  void dispose() {
    seriesController = null;
    super.dispose();
  }
}

// In first chart
class ChartSampleData {
  ChartSampleData({this.xValue, this.y});
  final int? xValue;
  final int? y;
}
