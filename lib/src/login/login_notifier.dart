// ignore: non_constant_identifier_names
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

String LOGIN_KEY = "5FD6G46SDF4GD64F1VG9SD68";
// ignore: non_constant_identifier_names
String ONBOARD_KEY = "GD2G82CG9G82VDFGVD22DVG";

class AuthService with ChangeNotifier {
  final StreamController<bool> _loginStateChange =
      StreamController<bool>.broadcast();
  bool _loginState = false;
  bool _initialized = false;
  bool _onboarding = false;
  User? _user;

  bool get loginState => _loginState;
  bool get initialized => _initialized;
  bool get onboarding => _onboarding;
  User? get user => _user;
  Stream<bool> get loginStateChange => _loginStateChange.stream;

  set loginState(bool state) {
    _loginState = state;
    _loginStateChange.add(state);
    notifyListeners();
  }

  set initialized(bool value) {
    _initialized = value;
    notifyListeners();
  }

  set onboarding(bool value) {
    _onboarding = value;
    notifyListeners();
  }

  Future<void> onAppStart() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      debugPrint("logged as ${user?.displayName ?? 'null'}");
      if (user == null) {
        _loginState = false;
        _user = user;
        notifyListeners();
      } else {
        debugPrint('user is ${user.displayName}');
        _loginState = true;
        _user = user;
        notifyListeners();
      }
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kDebugMode) {
      return FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'chandru.ck58@gmail.com', password: 'Test123@');
    }
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

final authServiceProvider =
    ChangeNotifierProvider<AuthService>((ref) => AuthService());
