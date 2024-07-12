
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paraiso/routes/router.dart';
import 'package:paraiso/screens/invite_screen.dart';



class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Set scaffold background to transparent
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              // Image box in the middle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20.h),
                  width: 300.w,
                  height: 300.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.network(
                    'https://th.bing.com/th/id/OIP.BOEvWmNe_POZzt44n02sSwHaHa?rs=1&pid=ImgDetMain', // Placeholder URL (replace with your image URL)
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Invite friends box
              Container(
                margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 0.h),
                padding: EdgeInsets.symmetric(horizontal: 33.w, vertical: 25.h),
                width: 380.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBFC),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      "assets/images/Friends_Users_280_6467.svg",
                      fit: BoxFit.contain,
                      width: 45.5.w,
                      color: Colors.black,
                    ),
                    GestureDetector(
                      onTap: () {
                        // push a material page route
                        AppRouter.rootNavigatorKey.currentState!.push(
                          MaterialPageRoute(
                            builder: (context) => const InviteScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.inviteFriends,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 23.sp,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          14.horizontalSpace,
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 25.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}