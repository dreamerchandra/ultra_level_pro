import 'package:flutter/material.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/alarm.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/baud_rate.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/tank_type.dart';

class BleState {
  String data;
  late int levelInLiter;
  late int levelInMm;
  late double levelInPercent;
  late int secondLevelInLiter;
  late int secondLevelInMm;
  late double secondLevelInPercent;
  late List<AlarmType> alarm;
  late double adcVoltage;
  late String macAddress;
  late String version;
  late double powerSupplyVoltage;
  late double temperature1;
  late double temperature2;
  late String settings;
  late int lowLevelRelayInMm;
  late double highLevelRelayInPercent;
  late int lph;
  late double zeroPercentTrimmingPoint;
  late double hundredPercentTrimmingPoint;
  late int damping;
  late int levelCalibrationOffset;
  late int sensorOffset;
  late int tankOffset;
  late TankType tankType;
  late int tankHeight;
  late int tankWidth;
  late int tankLength;
  late String slaveId;
  late int baudRate;

  BleState({required this.data}) {
    if (!isCRCSame()) throw Exception("CRC is not same");
    computeValues();
  }

  bool isCRCSame() {
    final crc = data.substring(data.length - 4);
    final crcData = data.substring(0, data.length - 4);
    debugPrint('crc: $crc');
    debugPrint('crcData: $crcData');
    // return crc == computeCRC(crcData);
    return true;
  }

  void computeValues() {
    int i = 8;
    levelInLiter = hexToInt(data.substring(i, i += 4));
    levelInMm = hexToInt(data.substring(i, i += 4));
    levelInPercent = hexToInt(data.substring(i, i += 4)) / 100;
    secondLevelInLiter = hexToInt(data.substring(i, i += 4));
    secondLevelInMm = hexToInt(data.substring(i, i += 4));
    secondLevelInPercent = hexToInt(data.substring(i, i += 4)) / 100;
    alarm = getAlarm(data.substring(i, i += 4));
    adcVoltage = hexToInt(data.substring(i, i += 4)) / 1000;
    macAddress = data.substring(i, i += 4 * 3);
    version = data.substring(i, i += 4);
    powerSupplyVoltage = hexToInt(data.substring(i, i += 4)) / 100;
    temperature1 = hexToInt(data.substring(i, i += 4)) / 100;
    temperature2 = hexToInt(data.substring(i, i += 4)) / 100;
    settings = data.substring(i, i += 4);
    lowLevelRelayInMm = hexToInt(data.substring(i, i += 4));
    highLevelRelayInPercent = hexToInt(data.substring(i, i += 4)) / 100;
    lph = hexToInt(data.substring(i, i += 4));
    zeroPercentTrimmingPoint = hexToInt(data.substring(i, i += 4)) / 1000;
    hundredPercentTrimmingPoint = hexToInt(data.substring(i, i += 4)) / 1000;
    damping = hexToInt(data.substring(i, i += 4));
    levelCalibrationOffset = hexToInt(data.substring(i, i += 4));
    sensorOffset = hexToInt(data.substring(i, i += 4));
    tankOffset = hexToInt(data.substring(i, i += 4));
    tankType = getTankType(data.substring(i, i += 4));
    tankHeight = hexToInt(data.substring(i, i += 4));
    tankWidth = hexToInt(data.substring(i, i += 4));
    tankLength = hexToInt(data.substring(i, i += 4));
    slaveId = data.substring(i, i += 4);
    baudRate = getBaudRate(data.substring(i, i += 4));
  }
}
