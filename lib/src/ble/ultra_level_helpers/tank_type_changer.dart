import 'package:ultra_level_pro/src/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/src/ble/ultra_level_helpers/settings.dart';

class TankTypeParameter {
  WriteParameter parameter;
  String value;
  TankTypeParameter({required this.parameter, required this.value});
}

class TankTypeChanger extends BleWriter {
  final List<TankTypeParameter> _valuesToCommit = [];

  TankTypeChanger({required super.ble});

  TankTypeChanger set(
      {required WriteParameter parameter, required String value}) {
    final index =
        _valuesToCommit.indexWhere((element) => element.parameter == parameter);
    if (index != -1) {
      _valuesToCommit[index] =
          TankTypeParameter(parameter: parameter, value: value);
    } else {
      _valuesToCommit
          .add(TankTypeParameter(parameter: parameter, value: value));
    }
    return this;
  }

  String getValue(WriteParameter parameter) {
    final index =
        _valuesToCommit.indexWhere((element) => element.parameter == parameter);
    if (index != -1) {
      return _valuesToCommit[index].value;
    }
    return '';
  }

  String constructMultiPartWrite({
    required Settings settings,
    required String deviceId,
    required String slaveId,
  }) {
    final data = _valuesToCommit
        .map((item) {
          final writeAddress = ParameterToAddress[item.parameter];
          final data = constructData(
            value: item.value,
            parameter: item.parameter,
            settings: settings,
          );
          return '$writeAddress$data';
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
