import 'dart:math';
import 'package:flutter/material.dart';

const double _doublePi = 2 * pi;

const double _piDiv180 = pi / 180;
double _degToRad(double degree) {
  return degree * _piDiv180;
}

typedef OnGetCenterText = Text Function(double);

class UltraProgressIndicatorWidget extends StatefulWidget {
  final double size;
  final double maxValue;

  final double startAngle;

  final double progressStrokeWidth;

  /// Background circle line thickness.
  final double backStrokeWidth;

  /// The list of colors of the main line (one and more).
  final Color progressColors;

  /// The color of the circle at 100% value.
  /// It only works when [mergeMode] equal to true.
  final Color? fullProgressColor;

  /// The color of the background circle.
  final Color backColor;

  /// Animation speed.
  final int animationDuration;

  /// When this mode is enabled the progress bar with a 100% value forms a full
  /// circle.
  final bool mergeMode;

  /// The object designed to update the value of the progress bar.
  final ValueNotifier<double>? valueNotifier;

  /// Callback to generate a new Text widget located in the center of the
  /// progress bar. The callback input is the current value of the bar progress.
  final OnGetCenterText? onGetText;

  const UltraProgressIndicatorWidget({
    Key? key,
    this.size = 100,
    this.maxValue = 100,
    this.startAngle = 0,
    this.progressStrokeWidth = 15,
    this.backStrokeWidth = 15,
    this.progressColors = Colors.blueAccent,
    this.fullProgressColor,
    this.backColor = const Color(0xFF16262D),
    this.animationDuration = 6,
    this.mergeMode = false,
    this.valueNotifier,
    this.onGetText,
  }) : super(key: key);

  @override
  _SimpleCircularProgressBarState createState() =>
      _SimpleCircularProgressBarState();
}

class _SimpleCircularProgressBarState
    extends State<UltraProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  final double minSweepAngle = 0.015;

  late double circleLength;
  late double maxValue;
  late double widgetSize;

  late double startAngle;
  late double correctAngle;
  late SweepGradient sweepGradient;

  late AnimationController animationController;

  late Color fullProgressColor;

  late ValueNotifier<double> valueNotifier;
  late ValueNotifier<double>? defaultValueNotifier;

  @override
  void initState() {
    super.initState();

    // Check zero size.
    widgetSize = (widget.size <= 0) ? 100.0 : widget.size;
    maxValue = (widget.maxValue <= 0) ? 100.0 : widget.maxValue;

    // Check value notifier
    if (widget.valueNotifier != null) {
      defaultValueNotifier = null;
      valueNotifier = widget.valueNotifier!;
    } else {
      defaultValueNotifier = ValueNotifier(widget.maxValue);
      valueNotifier = defaultValueNotifier!;
    }

    // Calculate the real starting angle and correction angle.
    // Correction angle - the angle to which the main line should be
    // shifted in order for the SweepGradient to be displayed correctly.
    circleLength = pi * widgetSize;
    final k = _doublePi / circleLength;

    correctAngle = widget.progressStrokeWidth * k;
    startAngle = (correctAngle / 2);

    // Adjusting the colors.
    final Color progressColors = widget.progressColors;

    sweepGradient = SweepGradient(
      tileMode: TileMode.decal,
      colors: [progressColors, progressColors],
    );

    fullProgressColor = (widget.fullProgressColor == null)
        ? progressColors
        : widget.fullProgressColor!;

    // Create animation.
    final animationDuration =
        (widget.animationDuration < 0) ? 0 : widget.animationDuration;

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: animationDuration),
      value: 0.0,
      upperBound: maxValue,
    );
  }

  @override
  void didUpdateWidget(UltraProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Respond to changes in properties.
    if (oldWidget.progressColors == widget.progressColors) {
      sweepGradient = SweepGradient(
        tileMode: TileMode.decal,
        colors: [widget.progressColors, widget.progressColors],
      );

      fullProgressColor = (widget.fullProgressColor == null)
          ? widget.progressColors
          : widget.fullProgressColor!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      builder: (BuildContext context, double value, Widget? child) {
        // If the set value is greater than the maximum value, we must set the
        // maximum value. Otherwise the animation will loop.
        if (value > maxValue) {
          value = maxValue;
        } else if (value < 0) {
          value = 0;
        }

        // Read [MAIN LOGIC]
        if (value < animationController.value) {
          animationController.forward();
        } else {
          animationController.animateTo(value);
        }

        return AnimatedBuilder(
          animation: animationController,
          builder: (context, snapshot) {
            // [MAIN LOGIC]
            //
            // If [value] >= [animation.value]:
            // Moving from the current value to the new value.
            //
            // If [value] <  [animation.value]:
            // Move to the end of the circle and from there to a new value.
            //
            // [MAIN LOGIC]

            if ((value != animationController.upperBound) &&
                (animationController.value >= animationController.upperBound)) {
              animationController.reset();
              animationController.animateTo(value);
            }

            double sweepAngle;

            // Reduce the value to a range of 0.0 to 1.0.
            final reducedValue = animationController.value / maxValue;

            if (animationController.value == 0) {
              sweepAngle = 0;
            } else {
              sweepAngle = (_doublePi * reducedValue) - correctAngle;

              if (sweepAngle <= 0) {
                sweepAngle = minSweepAngle;
              }
            }

            final currentLength = reducedValue * circleLength;

            // If mergeMode is on and the current value is equal to the maximum
            // value, we should draw a full circle with the specified color.
            final isFullProgress = widget.mergeMode &
                (animationController.value == animationController.upperBound);

            // Create center text widget.
            // If no callback is defined, create an empty widget.
            Widget centerTextWidget;
            if (widget.onGetText != null) {
              centerTextWidget = widget.onGetText!(animationController.value);
            } else {
              centerTextWidget = const SizedBox.shrink();
            }

            // Repaint progress bar.
            return Stack(
              alignment: Alignment.center,
              children: [
                centerTextWidget,
                Transform.rotate(
                  angle: _degToRad(widget.startAngle - 90),
                  child: CustomPaint(
                    size: Size(widgetSize, widgetSize),
                    painter: _UltraProgressIndicatorWidgetPainter(
                      progressStrokeWidth: widget.progressStrokeWidth,
                      backStrokeWidth: widget.backStrokeWidth,
                      startAngle: startAngle,
                      sweepAngle: sweepAngle,
                      currentLength: currentLength,
                      frontGradient: sweepGradient,
                      backColor: widget.backColor,
                      fullProgressColor: fullProgressColor,
                      isFullProgress: isFullProgress,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();

    if (defaultValueNotifier != null) {
      defaultValueNotifier!.dispose();
    }

    super.dispose();
  }
}

/// Painter to draw the progress bar.
class _UltraProgressIndicatorWidgetPainter extends CustomPainter {
  final double progressStrokeWidth;
  final double backStrokeWidth;
  final double startAngle;
  final double sweepAngle;
  final double currentLength;
  final SweepGradient frontGradient;
  final Color backColor;
  final Color fullProgressColor;
  final bool isFullProgress;

  _UltraProgressIndicatorWidgetPainter({
    required this.progressStrokeWidth,
    required this.backStrokeWidth,
    required this.startAngle,
    required this.sweepAngle,
    required this.currentLength,
    required this.frontGradient,
    required this.backColor,
    required this.fullProgressColor,
    required this.isFullProgress,
  });

  /// Draw background circle for progress bar
  void _drawBack(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = backStrokeWidth;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  /// Draw the initial part of the arc (~ 0% - 1%).
  /// (The part that is less than the [progressStrokeWidth])
  void _drawLessArcPart(Canvas canvas, Size size) {
    // [MAIN LOGIC]
    //
    // Copies 'phases of the Moon' while drawing (Last Quarter -> Full Moon).
    // Draw two arcs. One static and one moving, and combine them using XOR.
    //
    // [MAIN LOGIC]

    double angle = 0;
    double height = 0;

    if (currentLength < progressStrokeWidth / 2) {
      angle = 180;
      height = progressStrokeWidth - currentLength * 2;
    } else if (currentLength < progressStrokeWidth) {
      angle = 0;
      height = currentLength * 2 - progressStrokeWidth;
    } else {
      return;
    }

    final Paint pathPaint = Paint()
      ..shader = frontGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final Offset circleOffset = Offset(
      (size.width / 2) * cos(startAngle) + size.center(Offset.zero).dx,
      (size.width / 2) * sin(startAngle) + size.center(Offset.zero).dy,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.xor,
        Path()
          ..addArc(
            Rect.fromLTWH(
              circleOffset.dx - progressStrokeWidth / 2,
              circleOffset.dy - progressStrokeWidth / 2,
              progressStrokeWidth,
              progressStrokeWidth,
            ),
            _degToRad(180),
            _degToRad(180),
          ),
        Path()
          ..addArc(
            Rect.fromCenter(
              center: circleOffset,
              width: progressStrokeWidth,
              height: height,
            ),
            _degToRad(angle),
            _degToRad(180),
          ),
      ),
      pathPaint,
    );
  }

  /// Draw main arc (~ 1% - 100%).
  void _drawArcPart(Canvas canvas, Size size) {
    final Rect arcRect = Offset.zero & size;

    final Paint arcPaint = Paint()
      ..shader = frontGradient.createShader(arcRect)
      ..strokeWidth = progressStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
  }

  void _drawFullProgress(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = fullProgressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = progressStrokeWidth;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isFullProgress && (progressStrokeWidth > 0)) {
      _drawFullProgress(canvas, size);
      return;
    }

    if (backStrokeWidth > 0) {
      _drawBack(canvas, size);
    }

    if (progressStrokeWidth <= 0) {
      return;
    } else if (progressStrokeWidth >= currentLength) {
      _drawLessArcPart(canvas, size);
    } else {
      _drawArcPart(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_UltraProgressIndicatorWidgetPainter oldDelegate) {
    return oldDelegate.currentLength != currentLength;
  }
}
