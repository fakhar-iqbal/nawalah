import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {

  // Rx<User?> isLoggedIn = FirebaseAuth.instance.currentUser.obs;
  RxBool isLoggedIn = true.obs; //TODO: make it false

  bool get getIsLoggedIn => isLoggedIn.value;

  // subscribe to auth changes from firebase
  void subscribeToFirebase() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // AppRouter.shellNavigatorKey.currentState!.pushReplacementNamed(AppRouteConstants.loginRoute);

        isLoggedIn.value = false;
      } else {
        // AppRouter.shellNavigatorKey.currentState!.pushReplacementNamed(AppRouteConstants.homeRoute);
        isLoggedIn.value = true;
      }
    });
  }

  void login() {
    isLoggedIn.value = true;
    // print("log in");
  }

  // must redirect to home page afterwards
  void logOut() {
    isLoggedIn.value = false;
  }
}
