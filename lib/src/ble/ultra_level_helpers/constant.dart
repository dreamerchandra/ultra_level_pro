// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

Uuid UART_UUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid UART_RX = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid UART_TX = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

final REQ_CODE = '0103000000204412'.codeUnits;
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
  TankOffset,
  TankType,
  TankHeight,
  TankWidth,
  TankLength,
  TankDiameter,
  SlaveId,
  BaudRate,
}

Map<WriteParameter, String> ParameterToAddress = {
  WriteParameter.Settings: '0F',
  WriteParameter.LowLevelRelayInMm: '10',
  WriteParameter.HighLevelRelayInPercent: '11',
  WriteParameter.Lph: '12',
  WriteParameter.ZeroPercentTrimmingPoint: '13',
  WriteParameter.HundredPercentTrimmingPoint: '14',
  WriteParameter.Damping: '15',
  WriteParameter.LevelCalibrationOffset: '16',
  WriteParameter.SensorOffset: '17',
  WriteParameter.TankOffset: '18',
  WriteParameter.TankType: '19',
  WriteParameter.TankHeight: '1A',
  WriteParameter.TankWidth: '1B',
  WriteParameter.TankLength: '1C',
  WriteParameter.TankDiameter: '1D',
  WriteParameter.SlaveId: '1E',
  WriteParameter.BaudRate: '1F',
};
