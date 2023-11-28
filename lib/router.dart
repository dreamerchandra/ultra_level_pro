import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/components/screen/device_details_screen.dart';
import 'package:ultra_level_pro/components/screen/device_list_screen.dart';
import 'package:ultra_level_pro/constants/constants.dart';
import 'package:ultra_level_pro/error_widget.dart';

class AppRouter {
  static GoRouter returnRouter() {
    GoRouter router = GoRouter(
      routes: [
        GoRoute(
          name: AppRouteConstants.homeRoute.name,
          path: AppRouteConstants.homeRoute.path,
          builder: (context, state) {
            return const DeviceListScreen();
          },
        ),
        GoRoute(
          name: AppRouteConstants.detailsRoute.name,
          path: AppRouteConstants.detailsRoute.path,
          builder: (context, state) {
            return DeviceDetailWidget(
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
