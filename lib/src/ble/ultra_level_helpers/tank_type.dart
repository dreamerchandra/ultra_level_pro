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
  switch (hex) {
    case '01':
      return TankType.lookup;
    case '02':
      return TankType.rectangle;
    case '04':
      return TankType.horizontalOval;
    case '06':
      return TankType.horizontalCylinder;
    case '08':
      return TankType.verticalCylinder;
    case '0A':
      return TankType.verticalCapsule;
    case '0C':
      return TankType.horizontalCapsule;
    case '0E':
      return TankType.elliptical;
    case '10':
      return TankType.nonLinear;
    default:
      return TankType.rectangle;

    // throw Exception('Invalid tank type');
  }
}
