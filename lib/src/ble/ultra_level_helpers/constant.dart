// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

Uuid UART_UUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid UART_RX = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid UART_TX = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

List<int> getReqCode(String slaveId) => '${slaveId}03000000204412'.codeUnits;
const POLLING_DURATION = Duration(seconds: 5);

enum WriteParameter {
  Settings,
  LowLevelRelayInMm,
  HighLevelRelayInPercent,
  Lph,
  ZeroPercentTrimmingPoint,
  HundredPercentTrimmingPoint,
  Damping,
  LevelCalibrationOffset,
  SensorOffset,
  TankType,
  TankOffset,
  TankHeight,
  TankWidth,
  TankLength,
  TankDiameter,
  SlaveId,
  BaudRate,
}

Map<WriteParameter, String> ParameterToAddress = {
  WriteParameter.Settings: '000F',
  WriteParameter.LowLevelRelayInMm: '0010',
  WriteParameter.HighLevelRelayInPercent: '0011',
  WriteParameter.Lph: '0012',
  WriteParameter.ZeroPercentTrimmingPoint: '0013',
  WriteParameter.HundredPercentTrimmingPoint: '0014',
  WriteParameter.Damping: '0015',
  WriteParameter.LevelCalibrationOffset: '0016',
  WriteParameter.SensorOffset: '0017',
  WriteParameter.TankOffset: '0018',
  WriteParameter.TankType: '0019',
  WriteParameter.TankHeight: '001A',
  WriteParameter.TankWidth: '001B',
  WriteParameter.TankLength: '001C',
  WriteParameter.TankDiameter: '001D',
  WriteParameter.SlaveId: '001E',
  WriteParameter.BaudRate: '001F',
};
