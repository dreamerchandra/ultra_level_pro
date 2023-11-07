import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/helper/lru_array.dart';

class PingPongStatusWidget extends StatefulWidget {
  const PingPongStatusWidget({
    super.key,
    required this.timer,
    required this.lastNPingPong,
  });

  final Timer timer;
  final LastNPingPong lastNPingPong;

  @override
  State<PingPongStatusWidget> createState() => _PingPongStatusStateWidget();
}

class _PingPongStatusStateWidget extends State<PingPongStatusWidget> {
  ValueNotifier<double> time = ValueNotifier<double>(0);
  int oldTick = 0;
  late Timer outTimer;
  @override
  void initState() {
    super.initState();
    outTimer = Timer.periodic(Duration(seconds: 1), (t) {
      debugPrint('$oldTick ${widget.timer.tick} ${time}');
      if (oldTick != widget.timer.tick) {
        oldTick = widget.timer.tick;
        setState(() {
          time.value = 0;
        });
      } else {
        setState(() {
          time.value = time.value + 1;
        });
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
    outTimer.cancel();
  }

  Color getColor() {
    if (widget.lastNPingPong.isDeviceFailedToRespond()) {
      return Color(Colors.red.value);
    }
    if (widget.lastNPingPong.isDeviceShowingStale()) {
      return Color(Colors.yellow.value);
    }
    return Color(Colors.transparent.value);
  }

  final size = 25.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: ValueListenableBuilder(
              builder: (context, value, child) {
                return Text(
                  '${value.round()}',
                  style: TextStyle(backgroundColor: getColor()),
                );
              },
              valueListenable: time,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SimpleCircularProgressBar(
              size: size,
              valueNotifier: time,
              maxValue: 9.0,
              backStrokeWidth: 0,
              animationDuration: 6,
              progressStrokeWidth: 4,
              backColor: Colors.black,
              progressColors: const [Colors.purple],
            ),
          ),
        )
      ],
    );
  }
}
