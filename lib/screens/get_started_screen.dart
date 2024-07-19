
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/routes/routes_constants.dart';
import 'package:nawalah/util/local_storage/shared_preferences_helper.dart';
import 'package:nawalah/widgets/primary_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Position? currentPosition;
  String? _currentAddress;

  void _getCurrentLocation() async {
    try {
      currentPosition = await getCurrentLocation();
      _currentAddress = await getAddressFromCoordinates(currentPosition!);
      print('currentPosition.latitude');
      print(currentPosition!.latitude);
      SharedPreferencesHelper.saveUserLocation(
          currentPosition!.latitude, currentPosition!.longitude);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      SharedPreferencesHelper.saveUserLocation(
          position.latitude, position.latitude);
      print('user location get');
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Address not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)])),

      child:Scaffold(
      backgroundColor: const Color(0x00ffa9f9), // Even lighter maroon shade
      body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/paraiso_logo.png',
                  height: 240.h, // Further increased size
                  width: 240.w, // Further increased size
                ),
                93.5.verticalSpace,
                Text(
                  "",
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.w600, // Made bolder
                    color: Colors.black,
                  ),
                ),
                37.verticalSpace,
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .1,
                ),

                20.verticalSpace,
                PrimaryButton(
                  onPressed: () async {
                    context.push(AppRouteConstants.loginRoute);
                    SharedPreferencesHelper.saveCustomerType("user");
                  },
                  icon: Icons.arrow_forward_ios_outlined,
                  enabled: true,
                  color: const Color(0xFFD11559), // Maroon color
                  child: AutoSizeText(
                    "User",
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontSize: 18.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .15,
                ),
                GestureDetector(
                  onTap: () async {
                    context.push(AppRouteConstants.restaurantLogin);
                    SharedPreferencesHelper.saveUserSignupChoice("restaurant");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        "Business ",
                        style: TextStyle(
                          color: const Color(0xFFD11559), // Maroon color
                          fontSize: 15.sp,
                          fontFamily: 'Recoleta',
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 15.h,
                        color: const Color(0xFF800000), // Maroon color
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    ),);
  }
}
