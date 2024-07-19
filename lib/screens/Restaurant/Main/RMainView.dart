import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nawalah/screens/Restaurant/Main/RAnalysisView.dart';
import 'package:nawalah/screens/Restaurant/Main/RHomeView.dart';
import 'package:nawalah/screens/Restaurant/Main/RLiveView.dart';
import 'package:nawalah/screens/Restaurant/Main/ROrderView.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Restaurants/nearby_restaurants_controller.dart';
import '../../../controllers/Restaurants/res_auth_controller.dart';
import '../../ngos_screen.dart';

class RMainView extends StatefulWidget {
  const RMainView({super.key});

  @override
  State<RMainView> createState() => _RMainViewState();
}

class _RMainViewState extends State<RMainView> {
  int _index = 0;
  final views = [const ROrderView(), const RHomeView(), const RLiveView(), const NGOScreen()];


  late AuthController _authController;


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _authController = Provider.of<AuthController>(context, listen: false);


    if (_authController.user != null) {

    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFA9F9),

      body: views[_index],
      bottomNavigationBar: Container(

        margin: EdgeInsets.only(bottom: 15.h, left: 30.w, right: 30.w),
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 25.h),
        decoration: BoxDecoration(
          color: const Color(0xFFD11559),
          borderRadius: BorderRadius.circular(40.r),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigateToPage(0);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.list_alt, // Orders icon
                      color: _index == 0 ? Colors.grey : Colors.white,
                      size: 24, // Adjust size as needed
                    ),
                    Text(
                      'Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: 12, // Adjust size as needed
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigateToPage(2);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.volunteer_activism, // Donate icon
                      color: _index == 2 ? Colors.grey : Colors.white,
                      size: 24, // Adjust size as needed
                    ),
                    Text(
                      'Donate',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: 12, // Adjust size as needed
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigateToPage(3);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.groups, // NGOs icon
                      color: _index == 3 ? Colors.grey : Colors.white,
                      size: 24, // Adjust size as needed
                    ),
                    Text(
                      'NGOs',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: 12, // Adjust size as needed
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }
}
