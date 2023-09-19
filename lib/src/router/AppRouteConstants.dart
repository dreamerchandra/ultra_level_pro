class RouterDetails {
  final String path;
  final String name;
  RouterDetails({required this.path, required this.name});
}

enum RouterName {
  login,
  home,
  details,
}

String getDeviceDetailsRoute(String deviceId) {
  return '/details/$deviceId';
}

class AppRouteConstants {
  static RouterDetails getRouteDetails(RouterName name) {
    switch (name) {
      case RouterName.login:
        {
          return RouterDetails(name: 'login', path: '/login');
        }
      case RouterName.home:
        {
          return RouterDetails(name: 'home', path: '/');
        }
      case RouterName.details:
        {
          return RouterDetails(name: 'details', path: '/details/:deviceId');
        }
    }
  }
}
