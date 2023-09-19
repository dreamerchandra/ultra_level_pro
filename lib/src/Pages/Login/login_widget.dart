import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultra_level_pro/src/login/login_notifier.dart';

class LoginWidget extends ConsumerWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthService service = ref.read(authServiceProvider);
    return Scaffold(
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            service.signInWithGoogle();
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('asserts/image/google.png'),
                width: 16,
              ),
              SizedBox(
                width: 16,
              ),
              Text("Login with Google"),
            ],
          ),
        ),
      ),
    );
  }
}
