// ignore_for_file: constant_identifier_names

enum AlarmType {
  LOW_LEVEL,
  LOW_LOW_LEVEL,
  HIGH_LEVEL,
  HIGH_HIGH_LEVEL,
  FUEL_FILLING,
  FUEL_THEFT,
  FUEL_ABNORMAL,
  POWER_FAIL,
  DAC_COMM_ERROR,
  RADAR_COMM_ERROR,
  RS485_COMM_ERROR,
  BLE_ERROR,
  LOW_LEVEL_RELAY_ACTIVATED,
  HIGH_LEVEL_RELAY_ACTIVATED,
}

List<AlarmType> getAlarm(String hex) {
  final alarms = <AlarmType>[];
  final binary =
      int.parse(hex, radix: 16).toRadixString(2).split('').reversed.join();
  try {
    if (binary[0] == '1') alarms.add(AlarmType.LOW_LEVEL);
    if (binary[1] == '1') alarms.add(AlarmType.LOW_LOW_LEVEL);
    if (binary[2] == '1') alarms.add(AlarmType.HIGH_LEVEL);
    if (binary[3] == '1') alarms.add(AlarmType.HIGH_HIGH_LEVEL);
    if (binary[4] == '1') alarms.add(AlarmType.FUEL_FILLING);
    if (binary[5] == '1') alarms.add(AlarmType.FUEL_THEFT);
    if (binary[6] == '1') alarms.add(AlarmType.FUEL_ABNORMAL);
    if (binary[7] == '1') alarms.add(AlarmType.POWER_FAIL);
    if (binary[8] == '1') alarms.add(AlarmType.DAC_COMM_ERROR);
    if (binary[9] == '1') alarms.add(AlarmType.RADAR_COMM_ERROR);
    if (binary[10] == '1') alarms.add(AlarmType.RS485_COMM_ERROR);
    if (binary[11] == '1') alarms.add(AlarmType.BLE_ERROR);
    if (binary[12] == '1') alarms.add(AlarmType.LOW_LEVEL_RELAY_ACTIVATED);
    if (binary[13] == '1') alarms.add(AlarmType.HIGH_LEVEL_RELAY_ACTIVATED);
    return alarms;
  } catch (e) {
    return alarms;
  }
}
