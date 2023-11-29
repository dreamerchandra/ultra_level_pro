import 'package:flutter/material.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/alarm.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/baud_rate.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type.dart';

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
  late Settings settings;
  late int lowLevelRelayInMm;
  late double highLevelRelayInPercent;
  late int lph;
  late double zeroPercentTrimmingPoint;
  late double hundredPercentTrimmingPoint;
  late int damping;
  late double levelCalibrationOffset;
  late int sensorOffset;
  late int tankOffset;
  late TankType tankType;
  late int tankHeight;
  late int tankWidth;
  late int tankLength;
  late int tankDiameter;
  late String slaveId;
  late int baudRate;

  BleState({required this.data}) {
    if (!isCRCSame()) throw Exception("CRC is not same");
    computeValues();
  }

  dynamic getValueByWrite(WriteParameter parameter) {
    switch (parameter) {
      case WriteParameter.BaudRate:
        return baudRate;
      case WriteParameter.Damping:
        return damping;
      case WriteParameter.HighLevelRelayInPercent:
        return highLevelRelayInPercent;
      case WriteParameter.LevelCalibrationOffset:
        return levelCalibrationOffset;
      case WriteParameter.LowLevelRelayInMm:
        return lowLevelRelayInMm;
      case WriteParameter.Lph:
        return lph;
      case WriteParameter.SensorOffset:
        return sensorOffset;
      case WriteParameter.TankOffset:
        return tankOffset;
      case WriteParameter.TankType:
        return tankType;
      case WriteParameter.TankHeight:
        return tankHeight;
      case WriteParameter.TankWidth:
        return tankWidth;
      case WriteParameter.TankLength:
        return tankLength;
      case WriteParameter.TankDiameter:
        return tankDiameter;
      case WriteParameter.ZeroPercentTrimmingPoint:
        return zeroPercentTrimmingPoint;
      case WriteParameter.HundredPercentTrimmingPoint:
        return hundredPercentTrimmingPoint;
      case WriteParameter.Settings:
        return settings;
      case WriteParameter.SlaveId:
        return slaveId;
    }
  }

  bool isCRCSame() {
    final crcFromDevice = data.substring(data.length - 4);
    final dataToBeComputed = data.substring(0, data.length - 4);
    if (crcFromDevice == calculateModbusCRC(dataToBeComputed)) return true;
    debugPrint('crc from device: $crcFromDevice');
    debugPrint('our crc: ${calculateModbusCRC(dataToBeComputed)}');
    return false;
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
    settings = Settings.getSettings(data.substring(i, i += 4));
    lowLevelRelayInMm = hexToInt(data.substring(i, i += 4));
    highLevelRelayInPercent = hexToInt(data.substring(i, i += 4)) / 100;
    lph = hexToInt(data.substring(i, i += 4));
    zeroPercentTrimmingPoint = hexToInt(data.substring(i, i += 4)) / 1000;
    hundredPercentTrimmingPoint = hexToInt(data.substring(i, i += 4)) / 1000;
    damping = hexToInt(data.substring(i, i += 4));
    levelCalibrationOffset = hexToInt(data.substring(i, i += 4)) / 1000;
    sensorOffset = hexToInt(data.substring(i, i += 4));
    tankOffset = hexToInt(data.substring(i, i += 4));
    tankType = getTankType(data.substring(i, i += 4));
    tankHeight = hexToInt(data.substring(i, i += 4));
    tankWidth = hexToInt(data.substring(i, i += 4));
    tankLength = hexToInt(data.substring(i, i += 4));
    tankDiameter = hexToInt(data.substring(i, i += 4));
    slaveId = data.substring(i, i += 4).substring(2, 4);
    baudRate = getBaudRate(data.substring(i, i += 4));
  }
}
