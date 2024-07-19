
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nawalah/screens/grocery_provider.dart';
import 'package:nawalah/screens/logo_provider.dart';
import 'package:nawalah/screens/ngo_cache_provider.dart';
import 'package:nawalah/screens/restaurant_cache_provider.dart';
import 'package:nawalah/screens/restaurant_provider.dart';
import 'package:nawalah/util/local_storage/shared_preferences_helper.dart';
import 'package:provider/provider.dart';

import 'package:nawalah/controllers/user_profile_provider.dart';
import 'package:nawalah/routes/router.dart';
import 'package:nawalah/setup.dart';
import 'package:nawalah/util/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'controllers/Restaurants/image_provider.dart';
import 'controllers/Restaurants/orders_controller.dart';
import 'controllers/Restaurants/res_auth_controller.dart';
import 'controllers/bottom_navbar_controller.dart';
import 'controllers/categories_controller.dart';
import 'controllers/customer_controller.dart';
import 'controllers/location_controller.dart';
import 'controllers/profile_pic_controller.dart';
import 'controllers/sort_by_distance_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final FirebaseOptions options = FirebaseOptions(
      apiKey: "AIzaSyCF3ylklngWHnj0p901dx3CmZgykGt5CJU",
      appId: "1:903437557620:web:a661136b6adfb8d9dc5621",
      projectId: "fypparaiso",
      messagingSenderId: "903437557620",

    );

    await Firebase.initializeApp(options: options);
  } catch (e) {
    print('hellooo Error initializing Firebase: $e');
  }
  await SharedPreferencesHelper.init(); // Initialize SharedPreferences
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => RestaurantCacheProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ChangeNotifierProvider(create: (context) => LogoProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),


        ChangeNotifierProvider(create: (_) => BottomNavBarNotifier()),
        //ChangeNotifierProvider(create: (_) => OrdersController()),

        //ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        //ChangeNotifierProvider(create: (_) => TopSellersController()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => NGOCacheProvider()),

        ChangeNotifierProvider(create: (_) => ProfilePicController()),
        ChangeNotifierProvider(create: (_) => CustomerController()),
        //ChangeNotifierProvider(create: (_) => SortByDistanceController()),
        ChangeNotifierProvider(create: (context) => GroceryProvider()),
        //ChangeNotifierProvider(create: (_) => CategoriesProvider()),

        //ChangeNotifierProvider(create: (_) => RestaurantsWithDiscountController()),
      ],
      child: MaterialApp.router(
        title: 'Nawalah',
        locale: const Locale("en"),
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("en"),
          // Locale("fr"),
        ],
        builder: (ctx, child) {
          ScreenUtil.init(
            ctx,
            designSize: const Size(430, 932),
            minTextAdapt: true,
            splitScreenMode: true,
          );
          return Theme(
            data: darkTheme,
            child: child!,
          );
        },
      ),
    );
  }
}
