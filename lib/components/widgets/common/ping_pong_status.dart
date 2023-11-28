import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_ping_pong.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/components/widgets/common/ultra_progress_indicator_widget.dart';

class PingPongStatusWidget extends StatefulWidget {
  const PingPongStatusWidget({
    super.key,
    required this.timer,
    required this.lastNPingPong,
  });

  final Timer? timer;
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
    ourTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (oldTick != widget.timer?.tick) {
        oldTick = widget.timer?.tick ?? 0;
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
    ourTimer.cancel();
  }

  Color getColor() {
    if (widget.lastNPingPong.isDeviceFailedToRespond()) {
      return Color(Colors.red.value);
    }
    if (widget.lastNPingPong.isDeviceShowingStale()) {
      return Color(Colors.yellow.value);
    }
    return Color(Colors.purple.value);
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
              maxValue: 9.0,
              backStrokeWidth: 0,
              animationDuration: 6,
              progressStrokeWidth: 4,
              backColor: Colors.black,
              progressColors: getColor(),
            ),
          ),
        )
      ],
    );
  }
}
