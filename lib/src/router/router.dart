import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/error_widget.dart';
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
        GoRoute(
          name: AppRouteConstants.getRouteDetails(RouterName.home).name,
          path: AppRouteConstants.getRouteDetails(RouterName.home).path,
          builder: (context, state) {
            return const HomeWidget();
          },
        ),
        GoRoute(
          name: AppRouteConstants.getRouteDetails(RouterName.details).name,
          path: AppRouteConstants.getRouteDetails(RouterName.details).path,
          builder: (context, state) {
            return DetailWidget(
              deviceId: state.pathParameters['deviceId'] ?? '',
            );
          },
        ),
      ],
      errorBuilder: (context, state) => CustomError(
        errorDetails: FlutterErrorDetails(exception: state.error!),
      ),
    );
    return router;
  }
}
