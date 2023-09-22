enum TankType {
  lookup,
  rectangle,
  horizontalOval,
  horizontalCylinder,
  verticalCylinder,
  verticalCapsule,
  horizontalCapsule,
  elliptical,
  nonLinear,
}

TankType getTankType(String hex) {
  TankType tankType = TankType.lookup;
  final binary =
      int.parse(hex, radix: 16).toRadixString(2).split('').reversed.join();
  try {
    if (binary[0] == '1') tankType = TankType.lookup;
    if (binary[1] == '1') tankType = TankType.rectangle;
    if (binary[2] == '1') tankType = TankType.horizontalOval;
    if (binary[3] == '1') tankType = TankType.horizontalCylinder;
    if (binary[4] == '1') tankType = TankType.verticalCylinder;
    if (binary[5] == '1') tankType = TankType.verticalCapsule;
    if (binary[6] == '1') tankType = TankType.horizontalCapsule;
    if (binary[7] == '1') tankType = TankType.elliptical;
    if (binary[8] == '1') tankType = TankType.nonLinear;
    return tankType;
  } catch (e) {
    return tankType;
  }
}

String getTankTypeInHex(TankType tankType) {
  String binary = '';
  switch (tankType) {
    case TankType.lookup:
      binary = '0000000001';
      break;
    case TankType.rectangle:
      binary = '0000000010';
      break;
    case TankType.horizontalOval:
      binary = '0000000100';
      break;
    case TankType.horizontalCylinder:
      binary = '0000001000';
      break;
    case TankType.verticalCylinder:
      binary = '0000010000';
      break;
    case TankType.verticalCapsule:
      binary = '0000100000';
      break;
    case TankType.horizontalCapsule:
      binary = '0001000000';
      break;
    case TankType.elliptical:
      binary = '0010000000';
      break;
    case TankType.nonLinear:
      binary = '0100000000';
      break;
  }
  final hex = int.parse(binary, radix: 2).toRadixString(16);
  return hex;
}
