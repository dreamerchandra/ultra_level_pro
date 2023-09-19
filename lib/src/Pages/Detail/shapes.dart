import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget rectangle() {
  return SvgPicture.asset(
    'asserts/shape/rect.svg',
    semanticsLabel: 'Rectangle',
    width: 100,
    height: 100,
    placeholderBuilder: (BuildContext context) => Container(
      padding: const EdgeInsets.all(30.0),
      child: const CircularProgressIndicator(),
    ),
  );
}

Widget horizontalCylinder() {
  return Image.asset(
    'asserts/shape/horizontal_cylinder.png',
    height: 100,
  );
}
