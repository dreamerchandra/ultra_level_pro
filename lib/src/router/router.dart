import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/src/Pages/Detail/detail_widget.dart';
import 'package:ultra_level_pro/src/Pages/Home/home_wdiget.dart';
import 'package:ultra_level_pro/src/Pages/Login/login_widget.dart';
import 'package:ultra_level_pro/src/login/login_notifier.dart';
import 'package:ultra_level_pro/src/router/AppRouteConstants.dart';

class AppRouter {
  static GoRouter returnRouter(AuthService appService) {
    GoRouter router = GoRouter(
      refreshListenable: appService,
      routes: [
        GoRoute(
          name: AppRouteConstants.getRouteDetails(RouterName.login).name,
          path: AppRouteConstants.getRouteDetails(RouterName.login).path,
          builder: (context, state) {
            return const LoginWidget();
          },
        ),
        // GoRoute(
        //   name: AppRouteConstants.getRouteDetails(RouterName.home).name,
        //   path: AppRouteConstants.getRouteDetails(RouterName.home).path,
        //   builder: (context, state) {
        //     return const HomeWidget();
        //   },
        // ),
        GoRoute(
          name: AppRouteConstants.getRouteDetails(RouterName.home).name,
          path: AppRouteConstants.getRouteDetails(RouterName.home).path,
          builder: (context, state) {
            return DetailWidget(
              deviceId: state.pathParameters['deviceId'] ?? '',
            );
          },
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = appService.loginState;
        if (!isLoggedIn) {
          return '/login';
          // If not onboard and not going to onboard redirect to OnBoarding
        } else {
          // Else Don't do anything
          return null;
        }
      },
    );
    return router;
  }
}
