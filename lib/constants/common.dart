import 'package:flutter/material.dart';

enum DeviceType {
  phone,
  tablet,
}

DeviceType getDeviceType() {
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
  return data.size.shortestSide < 600 ? DeviceType.phone : DeviceType.tablet;
}
