import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';

class TankTypeParameter {
  WriteParameter parameter;
  String value;
  TankTypeParameter({required this.parameter, required this.value});
}

class NonLinearTankTypeChanger extends BleWriter {
  List<List<TankTypeParameter>> _valuesToCommit = [];

  NonLinearTankTypeChanger({required super.ble});

  void update(List<List<TankTypeParameter>> val) {
    _valuesToCommit = val;
  }

  String constructMultiPartWrite({
    required Settings settings,
    required String deviceId,
    required String slaveId,
  }) {
    final data = _valuesToCommit
        .map((tank) {
          return tank
              .map((values) {
                final writeAddress = ParameterToAddress[values.parameter];
                final data = constructData(
                  value: values.value,
                  parameter: values.parameter,
                  settings: settings,
                );
                return '$writeAddress$data';
              })
              .toList()
              .join();
        })
        .toList()
        .join();
    String header = '${slaveId}10'; // slaveId funCode writeAddress data crc
    final crc = calculateModbusCRC((header + data));
    final valueToWrite = header + data + crc;
    return valueToWrite;
  }

  Future<bool> commitTankType({
    required String deviceId,
    required Settings settings,
    required String slaveId,
  }) {
    final valueToWrite = constructMultiPartWrite(
      settings: settings,
      deviceId: deviceId,
      slaveId: slaveId,
    );
    return super.commitHelper(valueToWrite, deviceId);
  }
}
