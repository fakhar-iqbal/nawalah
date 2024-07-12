import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Restaurants/nearby_restaurants_controller.dart';
import '../../../controllers/Restaurants/res_auth_controller.dart';
import '../../../controllers/location_controller.dart';
import '../../custom_drawer.dart';

class RHomeView extends StatefulWidget {
  const RHomeView({super.key});

  @override
  State<RHomeView> createState() => _RHomeViewState();
}

class _RHomeViewState extends State<RHomeView> {
  bool isClients = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final locationController =
         Provider.of<LocationProvider>(context, listen: false);



    final authController = Provider.of<AuthController>(context, listen: false);
    print(_scaffoldKey);
    print(78);
    return Scaffold(

      key: _scaffoldKey,
      drawer: CustomDrawer(
        scaffoldKey: _scaffoldKey,
      ),
      body: Consumer<NearbyRestaurantsController>(
        builder: (context, value, child) {
          final nearbyRestaurants = value.restaurantsWithDiscount;

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 40.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        child: Container(
                          height: 80.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color.fromRGBO(53, 53, 53, 1),
                                  width: 2.w)),
                          child: ClipOval(
                              child: Image.network(
                            authController.user!.logo,
                            fit: BoxFit.cover,
                          )),
                        ),
                      ),
                      Expanded(
                        child: SvgPicture.asset(
                          'assets/images/paraiso_logo.svg',
                          width: 40.w,
                          height: 40.h,
                        ),
                      ),
                      Row(
                        children: [

                          Container(
                            height: 60.h,
                            width: 60.w,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(53, 53, 53, 1),
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/icons/notification.png'))),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30.h),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 53, 53, 1),
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  isClients = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.w, vertical: 15.h),
                                decoration: BoxDecoration(
                                  color: isClients == false
                                      ? const Color(0xFF2F58CD)
                                      : const Color.fromRGBO(53, 53, 53, 1),
                                  borderRadius: BorderRadius.circular(40.r),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.restaurants,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Recoleta",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp),
                                ),
                              )),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  isClients = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.w, vertical: 15.h),
                                decoration: BoxDecoration(
                                  color: isClients == true
                                      ? const Color(0xFF2F58CD)
                                      : const Color.fromRGBO(53, 53, 53, 1),
                                  borderRadius: BorderRadius.circular(40.r),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.clients,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Recoleta",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp),
                                ),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}

String formatTimeDifference(DateTime lastUpdated) {
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(lastUpdated);

  if (difference.inMinutes < 1) {
    return 'just now';
  } else if (difference.inHours < 1) {
    final minutes = difference.inMinutes;
    return '$minutes m';
  } else if (difference.inDays < 1) {
    final hours = difference.inHours;
    return '$hours h';
  } else {
    final days = difference.inDays;
    return '$days d';
  }
}
