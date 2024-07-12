import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/screens/myCart_Screen.dart';
import 'package:velocity_x/velocity_x.dart';


class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  final scaffoldKey;
  final String photo;
  const AppBarCustom({super.key, this.scaffoldKey, required this.photo});

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => Size.fromHeight(78.h);
}

class _AppBarCustomState extends State<AppBarCustom> {


  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:  const Color(0xFFD11559),
        // elevation: 0.0,
        leadingWidth: 100.w,
          leading: Padding(
            padding: EdgeInsets.only(top: 5.h), // Add padding from the top
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: const Color(0xFFFFE5E5),
              backgroundImage: widget.photo != ""
                  ? const NetworkImage(
                  "https://th.bing.com/th/id/R.a6e328f484dfaee5cff22431f5c61cab?rik=QtxCe0VZ6bQvjQ&pid=ImgRaw&r=0")
                  : null,
            ),
          ).onTap(
          () {
            //user_profile
            Scaffold.of(context).openDrawer();
          },
        ),
        centerTitle: true,

        actions: [
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart,color: Colors.white,size: 30,),

                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()));
                  },
                ).wh(63.w, 63.h),
                //! A RED DOT ON TOP OF NOTIFICATION ICON
                Positioned(
                  top: 10.h,
                  right: 18.h,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ).box.color(const Color(0xFFD11559)).roundedFull.make(),
          ),
        ],
      ),
    );
  }
}
