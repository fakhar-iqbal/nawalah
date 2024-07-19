import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/routes/routes_constants.dart';
import 'package:nawalah/screens/create_profile_email.dart';
import 'package:nawalah/screens/create_profile_name.dart';
import 'package:nawalah/screens/create_profile_password.dart';
import 'package:nawalah/screens/create_profile_phone.dart';
import 'package:nawalah/screens/food_restaurants_tab.dart';
import 'package:nawalah/screens/friends_tab.dart';
import 'package:nawalah/screens/get_started_screen.dart';
import 'package:nawalah/screens/home_tab_view.dart';
import 'package:nawalah/screens/login_screen.dart';
import 'package:nawalah/screens/restaurant_details_screen.dart';
import 'package:nawalah/screens/scaffold_with_nav.dart';
import 'package:nawalah/util/local_storage/shared_preferences_helper.dart';

import '../screens/Restaurant/Main/RMainView.dart';
import '../screens/Restaurant/RSignInView.dart';
import '../screens/ngos_screen.dart';

String getInitialLocation() {
  SharedPreferencesHelper.deleteUserSignupChoice();
  return SharedPreferencesHelper.getUserSignupChoice() == "restaurant"
      ? AppRouteConstants.restaurantLogin
      : (SharedPreferencesHelper.getUserSignupChoice() == "customer" ? AppRouteConstants.loginRoute : AppRouteConstants.getStartedRoute);
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> thirdNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: getInitialLocation(),

    routes: [

      GoRoute(
          path: "/",
          redirect: (BuildContext context, GoRouterState state) {
            return AppRouteConstants.homeRoute;
          }),

      ShellRoute(
        //subroute's navigator key must be same as the subroute's parent navigator
        //key or null
        navigatorKey: shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldWithNav(
            //   can use ProtectedRoute.checkAuth(child: child) instead of the below
            //   if with Bloc where the current context less method won't work
            child: child,

          );


        },
        routes: <RouteBase>[
          //   for home screen
          // "/home"
          GoRoute(path: "/home", builder: (context, state) => const HomeTabView(), routes: <RouteBase>[
            GoRoute(path: "0", pageBuilder: (context, state) => const NoTransitionPage(child: HomeTabView()), routes: const <RouteBase>[

            ]),
            GoRoute(path: "1", pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const FoodRestaurantsTab())),
            GoRoute(
              path: "2",
              pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const NGOScreen()),
            ),
            //GoRoute(path: "3", pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const SettingsTab())),
          ]),

        ],
      ),
      //Displayed on the Root navigator
      // "/get_started"
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRouteConstants.getStartedRoute,
        // we need to wrap with material page if we don't want the appbar and btm bar from home
        //
        pageBuilder: (context, state) => const MaterialPage(
          child: GetStartedScreen(),
        ),
      ),

      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfileName, pageBuilder: (context, state) => const MaterialPage(child: CreateProfileName())),

      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfileEmail, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfileEmail())),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfilePassword, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfilePassword())),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfilePhone, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfilePhone())),
      //GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfileSchoolName, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfileSchoolName())),


      // RESTAURANT ROUTES
      GoRoute(

        parentNavigatorKey: rootNavigatorKey,
        path: AppRouteConstants.restaurantDetails,
        pageBuilder: (context, state) {
          print(3);
          var restaurantId = state.uri.queryParameters['restaurantID']!;
          print(restaurantId);
          var restaurantName = state.uri.queryParameters['restaurantName']!;
          print(restaurantName);
          var restaurantAddress = state.uri.queryParameters['restaurantAddress']!;
          print(restaurantAddress);
          var restaurantEmail = state.uri.queryParameters['email']!;
          print(restaurantEmail);
          var image = state.uri.queryParameters['image']!;
          print(image);
          var isAvailable = state.uri.queryParameters['isAvailable']!;
          print(isAvailable);
          // var foodName = state.uri.queryParameters['foodName']!;
          // print(foodName);
          var itemData = 'check';
          print(itemData);


          var foodItem = {'name':'pizza',};
          print(foodItem);

          return NoTransitionPage(
            child: RestaurantDetailsScreen(
              //key: UniqueKey(), // Example of using a unique key
              //foodName: 'check2',
              image: image,
              price: 2.0, // Extract price from foodItem
              isOnlineImage: true, // Example of setting isOnlineImage to true
              restaurantId: restaurantId,
              isAvailable: isAvailable == "true",
              restaurantName: restaurantName,
              restaurantImage: '', // Example of restaurantImage being an empty string
              foodItem: foodItem,
              //restaurantEmail: restaurantEmail,
              restaurantAddress: restaurantAddress,
              //restaurantID: restaurantId,
            ),
          );
        },
      ),


      // RESTAURANT LOGIN
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.restaurantLogin, pageBuilder: (context, state) => const MaterialPage(child: RSignInView())),

      // RESTAURANT HOME
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.restaurantHome, pageBuilder: (context, state) => const MaterialPage(child: RMainView())),

      // LOGIN
      GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: AppRouteConstants.loginRoute,
          pageBuilder: (context, state) {
            // if user accidentally goes to login page and already logged in, redirect to home page
            return const MaterialPage(child: LoginScreen()); // TODO: comment this line
            // TODO: RE IMPLEMENT THIS

          }),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      if (kDebugMode) print("ROUTER URI: ${state.uri}");
      return null;
      // redirect automatically to login if not logged in
      //TODO: uncomment the redirect line and remove the print
      // return redirectBasedOnLogin(state);
    },
  );

  static get foodName => null;
}

String? redirectBasedOnLogin(GoRouterState state) {
  return null;

  // if not logged in and not on login page, redirect to login page
  // if user accidentally is able to access a route not supposed to access without login
  // can be a check implemented if a paid user tried to access a paid feature or not
  // Get.find<AuthController>().isLoggedIn.value == true && Get.find<AuthController>().isPremiumUser.value == false
  // TODO: RE IMPLEMENT THIS
  // if (!Get.find<AuthController>().getIsLoggedIn &&
  //     state.path != AppRouteConstants.loginRoute) {
  //   print("ROUTER: NOT LOGGED IN");
  //   // print("redirect to login");

  //   return AppRouteConstants.loginRoute;
  // }
}
