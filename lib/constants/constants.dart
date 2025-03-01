class RouterDetails {
  final String path;
  final String name;
  RouterDetails({required this.path, required this.name});
}

String getDeviceDetailsRoute(String deviceId) {
  return '/details/$deviceId';
}

class AppRouteConstants {
  static RouterDetails homeRoute = RouterDetails(path: '/', name: 'Home');
  static RouterDetails detailsRoute =
      RouterDetails(path: '/details/:deviceId', name: 'Device Details');
}
