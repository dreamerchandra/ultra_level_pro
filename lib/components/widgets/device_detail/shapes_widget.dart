import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type.dart';

String getShapeAssert(TankType type) {
  String? asset_name = null;

  switch (type) {
    case TankType.elliptical:
      asset_name = 'horizontal_capsule';
      break;
    case TankType.rectangle:
      asset_name = 'rectangle_tank';
      break;
    case TankType.horizontalCylinder:
      asset_name = 'horizontal_cylinder';
      break;
    case TankType.horizontalOval:
      asset_name = 'oval_tank';
      break;
    case TankType.verticalCylinder:
      asset_name = 'vertical_cylinder';
      break;
    case TankType.verticalCapsule:
      asset_name = 'vertical_capsule';
      break;
    case TankType.horizontalCapsule:
      asset_name = 'horizontal_capsule';
      break;
    case TankType.verticalOval:
      asset_name = 'vertical_oval';
      break;
    default:
      asset_name = type.name;
  }

  return 'asserts/shape/$asset_name.png';
}

Widget shape(TankType? type) {
  if (type == TankType.nonLinear) {
    return Container();
  }
  if (type == null) {
    return Container();
  }
  final shapeAssert = getShapeAssert(type);
  if (shapeAssert == '') {
    return Container();
  }
  return Image.asset(
    shapeAssert,
    height: 200,
  );
}
