
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../util/local_storage/shared_preferences_helper.dart';
import '../../custom_drawer.dart';

class RAnalysisView extends StatefulWidget {
  const RAnalysisView({super.key});

  @override
  State<RAnalysisView> createState() => _RAnalysisViewState();
}

class _RAnalysisViewState extends State<RAnalysisView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String inProgress = "Tout";

  int pendingOrders = 0;
  int completedOrders = 0;
  double totalRevenue = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchOrdersData();
  }

  Future<void> fetchOrdersData() async {
    print(1);
    String? email = SharedPreferencesHelper.getResEmail();
    print(email);
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .where('email', isEqualTo: email)
        .get();

    int pendingCount = 0;
    int completedCount = 0;
    double revenue = 0.0;

    if (ordersSnapshot.docs.isNotEmpty) {
      final restaurantAdminDoc = ordersSnapshot.docs.first;

      final ordersCollection = restaurantAdminDoc.reference.collection('orders');
      final ordersQuerySnapshot = await ordersCollection.get();

      for (var doc in ordersQuerySnapshot.docs) {
        var data = doc.data();
        if (data['status'] == 'pending') {
          pendingCount++;
        } else if (data['status'] == 'completed') {
          completedCount++;
          revenue += data['totalPrice'] ?? 0.0;
        }
      }
      print(pendingCount);
    }

    setState(() {
      pendingOrders = pendingCount;
      completedOrders = completedCount;
      totalRevenue = revenue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: _scaffoldKey,
      drawer: CustomDrawer(scaffoldKey: _scaffoldKey),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 40.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 80.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.transparent,
                            width: 2.w,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black, // You can change the color if needed
                          size: 25, // Adjust the size of the icon
                        ),
                      ),
                    ),


                    Container(
                      height: 40.h,
                      width: 60.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Color.fromRGBO(53, 53, 53, 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications,
                          color: Colors.black54,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.analysisTitle,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 23.sp),
                  ),

                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  Expanded(
                    child: _analysisBox(
                        "Pending orders",
                        pendingOrders.toString()),
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  Expanded(
                    child: _analysisBox(
                        "Completed Orders",
                        completedOrders.toString()),
                  ),
                ],
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                children: [
                  Expanded(
                    child: _analysisBox(
                        "Total Revenue",
                        'Pkr ${totalRevenue.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _analysisBox(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFFD11559),
          width: 2.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15.sp,
                color: Colors.black),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 25.sp,
                          color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
