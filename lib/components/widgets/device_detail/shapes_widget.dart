import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type.dart';

String getShapeAssert(TankType type) {
  String? asset_name = null;

  if (type == TankType.elliptical) {
    asset_name = 'horizontal_capsule';
  }
  if (type == TankType.rectangle) {
    asset_name = 'rectangle_tank';
  }
  if (type == TankType.horizontalCylinder) {
    asset_name = 'horizontal_cylinder';
  }
  if (type == TankType.horizontalOval) {
    asset_name = 'oval_tank';
  }
  if (type == TankType.verticalCylinder) {
    asset_name = 'vertical_cylinder';
  }
  if (type == TankType.verticalCapsule) {
    asset_name = 'vertical_capsule';
  }
  if (type == TankType.horizontalCapsule) {
    asset_name = 'horizontal_capsule';
  }
  if (type == TankType.verticalOval) {
    asset_name = 'vertical_oval';
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
