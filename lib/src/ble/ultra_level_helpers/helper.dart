import 'package:ultra_level_pro/src/ble/ultra_level_helpers/baud_rate.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/settings.dart';

int calculateCRC(List<int> data) {
  int crc = 0xFFFF; // Initialize CRC to 0xFFFF

  for (int byte in data) {
    crc ^= byte;
    for (int i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xA001;
      } else {
        crc >>= 1;
      }
    }
  }

  // The result is a 16-bit integer
  return crc & 0xFFFF;
}

List<int> hexStringToHexArray(String hexString) {
  List<int> hexArray = [];
  for (int i = 0; i < hexString.length - 1; i += 2) {
    String hexByte = hexString.substring(i, i + 2);
    int intValue = int.parse(hexByte, radix: 16);
    hexArray.add(intValue);
  }
  return hexArray;
}

String calculateModbusCRC(String hexString) {
  final data = hexStringToHexArray(hexString);
  int crcResult = calculateCRC(data);

  // Convert the result to a hexadecimal string
  String crcHex = crcResult.toRadixString(16).toUpperCase().padLeft(4, '0');
  String firstByte = crcHex.substring(0, 2);
  String secondByte = crcHex.substring(2, 4);
  crcHex = secondByte + firstByte;
  return crcHex;
}

int hexToInt(String hex) {
  return int.parse(hex, radix: 16);
}

String intToHex(int value) {
  final res = value.toRadixString(16).toUpperCase();
  return res.padLeft(4, '0');
}

String constructData({
  required String value,
  required WriteParameter parameter,
  SettingsValueToChange? settingsValueToChange,
  required Settings settings,
}) {
  String data = '';
  switch (parameter) {
    case WriteParameter.BaudRate:
      data = getBitByBaudRate(int.parse(value));
      break;
    case WriteParameter.Damping:
      data = intToHex(int.parse(value));
      break;
    case WriteParameter.Settings:
      if (settingsValueToChange == null) {
        break;
      }
      data = Settings.settingsToHexString(
          Settings.updateNewSettings(settings, settingsValueToChange));
      break;
    case WriteParameter.LowLevelRelayInMm:
      data = intToHex(int.parse(value));
      break;
    case WriteParameter.HighLevelRelayInPercent:
      data = intToHex(int.parse(value) * 100);
      break;
    case WriteParameter.Lph:
      data = intToHex(int.parse(value));
    case WriteParameter.ZeroPercentTrimmingPoint:
      data = intToHex((double.parse(value) * 1000).round());
    case WriteParameter.HundredPercentTrimmingPoint:
      data = intToHex((double.parse(value) * 1000).round());
    case WriteParameter.LevelCalibrationOffset:
      data = intToHex(int.parse(value));
    case WriteParameter.SensorOffset:
      data = intToHex(int.parse(value));
    case WriteParameter.TankOffset:
      data = intToHex(int.parse(value));
    case WriteParameter.TankType:
      data = value;
    case WriteParameter.TankHeight:
      data = intToHex(int.parse(value));
    case WriteParameter.TankWidth:
      data = intToHex(int.parse(value));
    case WriteParameter.TankLength:
      data = intToHex(int.parse(value));
    case WriteParameter.SlaveId:
      break;
    case WriteParameter.TankDiameter:
      data = intToHex(int.parse(value));
  }
  return data;
}
