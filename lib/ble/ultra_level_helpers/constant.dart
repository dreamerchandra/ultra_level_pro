// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';

Uuid UART_UUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid UART_RX = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid UART_TX = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

List<int> getReqCode(String slaveId) {
  final data = '${slaveId}0300000020';
  final crc = calculateModbusCRC(data);
  return '$data$crc'.codeUnits;
}

List<int> getReqCodeForNonLinear(String slaveId) {
  final data = '${slaveId}0301f30020';
  final crc = calculateModbusCRC(data);
  return '$data$crc'.codeUnits;
}

// slaveId/funcode(03)/startAdd(0000)/len(0020)/crc(4412)
// non slaveId/funcode(03)/startAdd(01f3)/len(0020)/crc()
const POLLING_DURATION = Duration(seconds: 2);
const RESPONSE_WAIT_DURATION = Duration(seconds: 1);

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
  Temperature1,
  Temperature2,
  SensorHeight;
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
  WriteParameter.Temperature1: '000D',
  WriteParameter.Temperature2: '000E',
  WriteParameter.SensorHeight: '0383',
};

String TOTP_SECRET =
    'MFZWIYLTMZSDGMRUONSGMMZSGRSGG6DBNNVGG3J3NRVWUZTJEB2WQ5BZORVG62LVEB2DSODVORZWUZDHNRVSA2TWMRZW6ZTHHF2HK33FNJRSA3DLNJTGG3ZANEZW65BANBVDE33JNJZG62LXNIQHQZTMNNSGUZRAPAQDEYZAOJ2TSODV=';

String SUPER_ADMIN_CODE = '123456';
