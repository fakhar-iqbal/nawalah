

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nawalah/screens/home_restaurants_list.dart';
import 'package:nawalah/util/local_storage/shared_preferences_helper.dart';
import 'package:nawalah/widgets/home_chips_row.dart';

import '../repositories/customer_firebase_calls.dart';


class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final myHomeChipsController = Get.find<HomeChipsController>();

  @override
  void initState() {
    super.initState();
    // getItems(); // If you have any additional data fetching logic, include it here
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("customer home...");
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              const HomeChipsRow(),
              21.verticalSpace,
              Obx(
                    () => IndexedStack(
                  index: myHomeChipsController.activeChip.value,
                  children: const [
                    HomeRestaurantsList(),
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
