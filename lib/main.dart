import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/firebase_options.dart';
import 'package:ultra_level_pro/src/login/login_notifier.dart';
import 'package:ultra_level_pro/src/router/router.dart';

void main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // await myErrorsHandler.initialize();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stackTrace) {
    print("Error FROM OUT_SIDE FRAMEWORK ");
    print("--------------------------------");
    print("Error :  $error");
    print("StackTrace :  $stackTrace");
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AuthService appService;
  late GoRouter _router;

  @override
  void initState() {
    appService = ref.read(authServiceProvider);
    _router = AppRouter.returnRouter(appService);
    appService.onAppStart();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
