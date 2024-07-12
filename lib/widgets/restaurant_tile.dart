

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RestaurantTile extends StatelessWidget {
  final String restaurantID;
  final String restaurantName;
  final String restaurantDescription;
  final String restaurantAddress;
  final String distance;
  final String image;
  final bool isOnlineImage;
  final String? email;
  final bool isAvailable;
  final bool isClosed;

  const RestaurantTile({
    super.key,
    required this.restaurantName,
    required this.restaurantDescription,
    required this.restaurantAddress,
    required this.distance,
    required this.image,
    this.isOnlineImage = false,
    this.restaurantID = "",
    this.email,
    this.isAvailable = true,
    this.isClosed = false,
  });

 @override
  Widget build(BuildContext context) {
   print(restaurantName);
   print(restaurantID);
   print(3534);
   print(email);
   print(restaurantAddress);
    if (restaurantName.isEmpty  ||
        distance.isEmpty ) {
      return const SizedBox(); // Return an empty SizedBox if any required data is empty
    }

    return GestureDetector(
      onTap: () {
        if (isClosed) {
          return;
        }

        GoRouter.of(context).push(Uri(
          path: '/restaurantDetails',
          queryParameters: {
            "email": email ?? "",
            "restaurantID": restaurantID ?? "",
            "restaurantName": restaurantName ?? "",
            "restaurantDescription": restaurantDescription ??"Buy the discounted items",
            "restaurantAddress": restaurantAddress??"",
            "distance": distance??"",
            "image": image?? "",
            "isAvailable": isAvailable.toString() ?? true,
            "isOnlineImage": isOnlineImage.toString() ?? true,
          },
        ).toString());
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 15.h),
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 27.w, 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFAFA),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: Colors.black,
            width: 1.w,
          ),
        ),
        width: 390.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isClosed)
              Container(
                width: 60.w,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.h),
                ),
                child: Center(
                  child: Text(
                    "Closed",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isOnlineImage
                    ? Container(
                  width: 73.w,
                  height: 73.h,
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.black38,
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                    : Image.asset(
                  "assets/images/$image",
                  width: 73.w,
                  height: 73.h,
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 190.w,
                      child: Text(
                        restaurantName,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 22.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: 190.w,
                      child: AutoSizeText(
                        restaurantDescription,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                ),
                const Spacer(),
                Text(
                  distance,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}




