import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultra_level_pro/firebase_options.dart';
import 'package:ultra_level_pro/src/login/login_notifier.dart';
import 'package:ultra_level_pro/src/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
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

final helloWorldProvider = Provider((_) => 'Hello world');

class MyApp1 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(helloWorldProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(name),
      ),
      body: Center(child: null),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
