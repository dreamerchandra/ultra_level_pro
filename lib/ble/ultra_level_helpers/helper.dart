import 'package:ultra_level_pro/ble/ultra_level_helpers/baud_rate.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';

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

String ensure2Byte(String data) {
  if (data.length == 1) {
    return '000$data';
  }
  if (data.length == 2) {
    return '00$data';
  }
  if (data.length == 3) {
    return '0$data';
  }
  return data;
}

String ensure1Byte(String data) {
  if (data.length == 1) {
    return '0$data';
  }
  return data;
}

String constructData({
  required String value,
  required WriteParameter parameter,
  SettingsValueToChange? settingsValueToChange,
  required Settings settings,
}) {
  String _value = value.toUpperCase();
  String data = '';
  switch (parameter) {
    case WriteParameter.BaudRate:
      data = getBitByBaudRate(int.parse(_value));
      break;
    case WriteParameter.Damping:
      data = intToHex(int.parse(_value));
      break;
    case WriteParameter.Settings:
      if (settingsValueToChange == null) {
        break;
      }
      data = Settings.settingsToHexString(
          Settings.updateNewSettings(settings, settingsValueToChange));
      break;
    case WriteParameter.LowLevelRelayInMm:
      data = intToHex(int.parse(_value));
      break;
    case WriteParameter.HighLevelRelayInPercent:
      data = intToHex(int.parse(_value) * 100);
      break;
    case WriteParameter.Lph:
      data = intToHex(int.parse(_value));
    case WriteParameter.ZeroPercentTrimmingPoint:
      data = intToHex((double.parse(_value) * 1000).round());
    case WriteParameter.HundredPercentTrimmingPoint:
      data = intToHex((double.parse(_value) * 1000).round());
    case WriteParameter.LevelCalibrationOffset:
      data = intToHex(int.parse(_value));
    case WriteParameter.SensorOffset:
      data = intToHex(int.parse(_value));
    case WriteParameter.TankOffset:
      data = intToHex(int.parse(_value));
    case WriteParameter.TankType:
      data = _value;
    case WriteParameter.TankHeight:
      data = intToHex(int.parse(_value));
    case WriteParameter.TankWidth:
      data = intToHex(int.parse(_value));
    case WriteParameter.TankLength:
      data = intToHex(int.parse(_value));
    case WriteParameter.SlaveId:
      break;
    case WriteParameter.TankDiameter:
      data = intToHex(int.parse(_value));
      break;
    case WriteParameter.Temperature1:
      data = intToHex(int.parse(_value));
      break;
    case WriteParameter.Temperature2:
      data = intToHex(int.parse(_value));
      break;
  }

  return ensure2Byte(data).toUpperCase();
}
