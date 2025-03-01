import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_ping_pong.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/components/widgets/common/ultra_progress_indicator_widget.dart';

class PingPongStatusWidget extends StatefulWidget {
  const PingPongStatusWidget({
    super.key,
    required this.isPaused,
    required this.lastNPingPong,
  });

  final bool isPaused;
  final LastNPingPongMeta lastNPingPong;

  @override
  State<PingPongStatusWidget> createState() => _PingPongStatusStateWidget();
}

class _PingPongStatusStateWidget extends State<PingPongStatusWidget> {
  ValueNotifier<double> time = ValueNotifier<double>(0);
  int oldTick = 0;
  late Timer ourTimer;
  @override
  void initState() {
    super.initState();
    ourTimer = Timer.periodic(const Duration(seconds: 1), timerCallback);
  }

  void timerCallback(t) {
    setState(() {
      time.value = (time.value + 1) % POLLING_DURATION.inSeconds;
    });
  }

  @override
  void didUpdateWidget(covariant PingPongStatusWidget oldWidget) {
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        ourTimer.cancel();
      } else {
        setState(() {
          time.value = 0;
        });
        ourTimer = Timer.periodic(const Duration(seconds: 1), timerCallback);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() async {
    super.dispose();
    ourTimer.cancel();
  }

  Color getColor() {
    if (widget.lastNPingPong.isDeviceFailedToRespond()) {
      return Color(Colors.red.value);
    }
    if (widget.lastNPingPong.isDeviceShowingStale()) {
      return Color(Colors.yellow.value);
    }
    return Color(Color.fromRGBO(99, 48, 169, 1).value);
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
                  '${(POLLING_DURATION.inSeconds.toDouble() - value).round()}',
                );
              },
              valueListenable: time,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: UltraProgressIndicatorWidget(
              size: size,
              valueNotifier: time,
              maxValue: POLLING_DURATION.inSeconds.toDouble(),
              backStrokeWidth: 0,
              animationDuration: 3,
              progressStrokeWidth: 4,
              backColor: Colors.black,
              progressColors: getColor(),
            ),
          ),
        ),
      ],
    );
  }
}
