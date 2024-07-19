import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/routes/routes_constants.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/bottom_navbar_controller.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

// class _BottomNavBarState extends State<BottomNavBar> implements PreferredSizeWidget {
class _BottomNavBarState extends State<BottomNavBar> {

  // @override
  // Size get preferredSize => Size.fromHeight(60.h);
  @override
  Widget build(BuildContext context) {
    final bottomNavBarNotifier = Provider.of<BottomNavBarNotifier>(context);
    return Row(

      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,

      children: <Widget>[
        32.horizontalSpace,
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                bottomNavBarNotifier.updateSelectedIndex(0);
                context.go(AppRouteConstants.homeRoute);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 25.w,
                    color: bottomNavBarNotifier.selectedIndex == 0 ? Colors.white : Colors.grey,
                  ),
                  SizedBox(height: 4.h), // Add some space between icon and text
                  Text('Restaurants', style: TextStyle(fontSize: 11.sp, color: Colors.white)), // Adjust the font size as needed
                ],

              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                bottomNavBarNotifier.updateSelectedIndex(1);
                context.go(AppRouteConstants.restaurantsRoute);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_grocery_store_outlined,
                    size: 27.w,
                    color: bottomNavBarNotifier.selectedIndex == 1 ? Colors.white : Colors.grey,
                  ),
                  SizedBox(height: 4.h), // Add some space between icon and text
                  Text('Groceries', style: TextStyle(fontSize: 11.sp, color: Colors.white)), // Adjust the font size as needed
                ],

              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                bottomNavBarNotifier.updateSelectedIndex(2);
                context.go(AppRouteConstants.profileRoute);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 25.w,
                    color: bottomNavBarNotifier.selectedIndex == 2 ? Colors.white : Colors.grey,
                  ),
                  SizedBox(height: 4.h), // Add some space between icon and text
                  Text('NGOs', style: TextStyle(fontSize: 11.sp, color: Colors.white)), // Adjust the font size as needed
                ],

              ),
            ),
          ),
        ),
        32.horizontalSpace,
      ],

    )
        .box
        .color(const Color(0xFFD11559))
        .customRounded(const BorderRadius.all(Radius.circular(50)))
        .make()
        .wh(385.w, 80.h)
        // .pSymmetric(h: 20.w, v: 10.h)
        .marginSymmetric(
          horizontal: 25.w,
          vertical: 25.h,
        );
  }



  Widget customIcon({required String icon, required int activeIndex, required currentIndex, double? size}) {
    return SvgPicture.asset(
      icon,
      color: activeIndex == currentIndex ? const Color(0xFF800000) : Colors.white,
      width: size ?? 28.w,
    );
  }
}
