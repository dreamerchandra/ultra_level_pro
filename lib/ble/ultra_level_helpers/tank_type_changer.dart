import 'dart:async';

import 'package:ultra_level_pro/ble/ultra_level_helpers/ble_writter.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/constant.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/helper.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/settings.dart';
import 'package:ultra_level_pro/ble/ultra_level_helpers/tank_type.dart';

class TankTypeParameter {
  WriteParameter parameter;
  String value;
  TankTypeParameter({required this.parameter, required this.value});
}

//slaveId(01)+funcode(10)+startAdd(4500)+len(number of point + 1)+byteCount(len*2)+data(eg len,point 1 in height, point 1 filled....poinnt n)+crc
//

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
    final values = _valuesToCommit
        .map((tank) {
          return tank
              .map((values) {
                final data = constructData(
                  value: values.value,
                  parameter: values.parameter,
                  settings: settings,
                );
                return data;
              })
              .toList()
              .join();
        })
        .toList()
        .join();
    String startAdd = '01f4'; // hex(500) -> 01f3;
    String len = ensure2Byte(intToHex(_valuesToCommit.length + 1));
    String byteCount = ensure1Byte('${(values.length) * 2}');
    String data = '$startAdd$len$byteCount$values';
    String header = '${slaveId}10'; // slaveId funCode writeAddress data crc

    final crc = calculateModbusCRC((header + data));
    final valueToWrite = header + data + crc;
    return valueToWrite;
  }

  Future<bool> commitTankType({
    required String deviceId,
    required Settings settings,
    required String slaveId,
  }) async {
    final nonLinearData = constructData(
      value: getTankTypeInHex(TankType.nonLinear),
      parameter: WriteParameter.TankType,
      settings: settings,
    );
    final data = constructWrite(
      deviceId: deviceId,
      slaveId: slaveId,
      parameter: WriteParameter.TankType,
      value: nonLinearData,
      settings: settings,
    );
    await super.commitHelper(data, deviceId);
    Completer<bool> completer = Completer<bool>();
    Future.delayed(Duration(milliseconds: 100), () async {
      final valueToWrite = constructMultiPartWrite(
        settings: settings,
        deviceId: deviceId,
        slaveId: slaveId,
      );
      var commitHelper = await super.commitHelper(valueToWrite, deviceId);
      completer.complete(commitHelper);
    });
    return completer.future;
  }
}
