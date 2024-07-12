
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:paraiso/controllers/categories_controller.dart';

import '../widgets/restaurant_tile.dart';

import 'grocery_provider.dart';

class FoodRestaurantsTab extends StatefulWidget {
  const FoodRestaurantsTab({Key? key}) : super(key: key);

  @override
  State<FoodRestaurantsTab> createState() => _FoodRestaurantsTabState();
}

class _FoodRestaurantsTabState extends State<FoodRestaurantsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().fetchGroceries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFD11559),
        title: Text(
          'Browse your grocery items',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Recoleta',
            fontWeight: FontWeight.w500,
            fontSize: 30.sp,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<GroceryProvider>(
                builder: (context, groceryProvider, child) {
                  if (groceryProvider.isLoading && groceryProvider.groceries.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (groceryProvider.groceries.isEmpty) {
                    return const Center(child: Text('No grocery stores found!'));
                  } else {
                    return RefreshIndicator(
                      onRefresh: () => groceryProvider.fetchGroceries(force: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10.0),
                        itemCount: groceryProvider.groceries.length,
                        itemBuilder: (context, index) {
                          final grocery = groceryProvider.groceries[index];
                          final bool isClosed = false;
                          final bool isAvailable = grocery['availability'] ?? true;
                          final String restaurantID = grocery['restaurantId'] ?? "";
                          final String email = grocery['email'] ?? "";
                          final String restaurantName = grocery['username'] ?? "";
                          final String restaurantAddress = grocery['address'] ?? "Unknown";
                          final String restaurantDescription = 'Buy groceries 🛒';
                          final String distance = 'now';
                          final String image = grocery['logo'] ?? "";
                          final bool isOnlineImage = true;

                          if (restaurantName.isEmpty || distance.isEmpty) {
                            return const SizedBox();
                          }

                          return GestureDetector(
                            onTap: () {
                              if (isClosed) {
                                return;
                              }

                              GoRouter.of(context).push(Uri(
                                path: '/restaurantDetails',
                                queryParameters: {
                                  "email": email,
                                  "restaurantID": restaurantID,
                                  "restaurantName": restaurantName,
                                  "restaurantDescription": restaurantDescription,
                                  "restaurantAddress": restaurantAddress,
                                  "distance": distance,
                                  "image": image,
                                  "isAvailable": isAvailable.toString(),
                                  "isOnlineImage": isOnlineImage.toString(),
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
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}