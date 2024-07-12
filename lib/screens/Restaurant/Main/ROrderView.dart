
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../util/local_storage/shared_preferences_helper.dart';
import '../../custom_drawer.dart';


class ROrderView extends StatefulWidget {
  const ROrderView({super.key});

  @override
  State<ROrderView> createState() => _ROrderViewState();
}

class _ROrderViewState extends State<ROrderView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<OrderModel> pendingOrders = [];
  List<OrderModel> completedOrders = [];
  bool showPending = true;
  String? logoUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchLogo();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    String? email = SharedPreferencesHelper.getResEmail();
    if (email != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String restaurantId = snapshot.docs.first.id;

        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('restaurantAdmins')
            .doc(restaurantId)
            .collection('orders')
            .get();

        List<OrderModel> fetchedPendingOrders = [];
        List<OrderModel> fetchedCompletedOrders = [];

        for (var doc in orderSnapshot.docs) {
          print(5544);

          try {

            OrderModel order = OrderModel.fromFirestore(doc);
            print(order);


            if (order.status == 'pending') {
              fetchedPendingOrders.add(order);
            } else if (order.status == 'completed') {
              fetchedCompletedOrders.add(order);
            }
          } catch (e) {
            print('Error parsing order: $e');
          }
        }

        setState(() {
          pendingOrders = fetchedPendingOrders;
          completedOrders = fetchedCompletedOrders;
        });
      }
    }
  }
  Future<void> fetchLogo() async {
    String? email = await SharedPreferencesHelper.getResEmail();
    if (email != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          logoUrl = snapshot.docs.first.get('logo');
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(scaffoldKey: _scaffoldKey),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
              ),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Column(
            children: [
              Container(
                color: const Color(0xFFD11559), // Background color for the top section
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 25.0), // Adjust top padding for safe area
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w), // Adjust the left padding as needed
                        child: Container(
                          height: 70.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 3.w),
                          ),
                          child: ClipOval(
                            child: logoUrl != null
                                ? Image.network(
                              logoUrl!,
                              height: 50.h, // Adjust the height of the image
                              width: 50.w, // Adjust the width of the image
                              fit: BoxFit.contain, // Optional: adjust the fit of the image within the container
                            )
                                : Container(
                              color: Colors.grey, // Placeholder color
                              child: Center(
                                child: Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showPending = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showPending ? Colors.red : Colors.grey,
                            ),
                            child: Text('Pending',style: TextStyle(
                              color: Colors.white, // Specify the desired color for the text
                              fontSize: 20.sp, // Optional: Adjust the font size
                              // Optional: Adjust the font weight
                            ), ),
                          ),
                          SizedBox(width: 10.w),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showPending = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showPending ? Colors.grey : Colors.green,
                            ),
                            child: Text('Completed',style: TextStyle(
                              color: Colors.white, // Specify the desired color for the text
                              fontSize: 20.sp, // Optional: Adjust the font size
                              // Optional: Adjust the font weight
                            ),),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: showPending ? buildOrderList(pendingOrders,Colors.white) : buildOrderList(completedOrders, Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOrderList(List<OrderModel> orders, Color backgroundColor) {
    return RefreshIndicator(
      onRefresh: fetchOrders,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return GestureDetector(
            onTap: () {
              // Add onTap functionality here
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.black,
                  width: 1.w,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.userName,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 17.sp,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Ordered at: ${order.orderedAt}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Phone: ${order.userPhoneNumber}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              'Location: [${order.userLocation.latitude}, ${order.userLocation.longitude}]',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showOrderDetails(order);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD11559),
                            ),
                            child: Text('View',style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),),
                          ),
                          if (showPending) // Only show the Complete button for pending orders
                            SizedBox(height: 5.h),
                          if (showPending) // Only show the Complete button for pending orders
                            ElevatedButton(
                              onPressed: () {
                                completeOrderDetails(order);
                                completeOrder(order);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5FBE48),
                              ),
                              child: Text('Complete',style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),),
                            ),
                        ],
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
  void showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text(
            'Order ID: ${order.orderId}',
            style: TextStyle(
              color: Colors.black, // Change text color to black
              fontSize: 16.sp,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...order.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  OrderItem item = entry.value;
                  return ListTile(
                    title: Text(
                      'Item ${index + 1}: ${item.name}',
                      style: TextStyle(
                        color: Colors.black, // Change text color to black
                        fontSize: 18.sp,
                      ),
                    ),
                    subtitle: Text(
                      'Quantity: ${item.quantity}, \nTotal Price: Pkr ${item.totalPrice}\n-----------------------------',
                      style: TextStyle(
                        color: Colors.black, // Change text color to black
                        fontSize: 18.sp,
                      ),
                    ),

                  );
                }),
                SizedBox(height: 10.h), // Add some spacing if necessary
                Text(
                  'Payment Mode: ${order.payment}',
                  style: TextStyle(
                    color: Colors.black, // Change text color to black
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center, // Center-align the text if needed
                ),
                Text(
                  'Collecting Mode: ${order.collect}',
                  style: TextStyle(
                    color: Colors.black, // Change text color to black
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center, // Center-align the text if needed
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey, // Set background color to grey
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.black, // Change text color to black
                  fontSize: 16.sp,
                ),
              ),
            ),

          ],
        );
      },
    );
  }

  void completeOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text(
            'Order ID: ${order.orderId}',
            style: TextStyle(
              color: Colors.black, // Change text color to black
              fontSize: 16.sp,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...order.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  OrderItem item = entry.value;
                  return ListTile(
                    title: Text(
                      'Item ${index + 1}: ${item.name}',
                      style: TextStyle(
                        color: Colors.black, // Change text color to black
                        fontSize: 18.sp,
                      ),
                    ),
                    subtitle: Text(
                      'Quantity: ${item.quantity}, Total Price: Pkr ${item.totalPrice}',
                      style: TextStyle(
                        color: Colors.black, // Change text color to black
                        fontSize: 18.sp,
                      ),
                    ),
                  );
                }),
                SizedBox(height: 10.h), // Add some spacing if necessary
                Text(
                  'Order completed\nThe customer will pay via ${order.payment}',
                  style: TextStyle(
                    color: Colors.black, // Change text color to black
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center, // Center-align the text if needed
                ),
                Text(
                  'Collecting Mode: ${order.collect}',
                  style: TextStyle(
                    color: Colors.black, // Change text color to black
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center, // Center-align the text if needed
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey, // Set background color to grey
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.black, // Change text color to black
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> completeOrder(OrderModel order) async {
    String? email = SharedPreferencesHelper.getResEmail();
    if (email != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String restaurantId = snapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('restaurantAdmins')
            .doc(restaurantId)
            .collection('orders')
            .doc(order.orderId)
            .update({'status': 'completed'});

        fetchOrders(); // Refresh the orders after updating the status
      }
    }
  }
}

class OrderModel {
  final String orderId;
  final String userName;
  final DateTime orderedAt;
  final String userPhoneNumber;
  final String status;
  final String collect;
  final String payment;
  final List<OrderItem> items;
  final GeoPoint userLocation;


  OrderModel({
    required this.orderId,
    required this.userName,
    required this.orderedAt,
    required this.userPhoneNumber,
    required this.status,
    required this.collect,
    required this.payment,
    required this.items,
    required this.userLocation,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {


    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<OrderItem> items = (data['orderItems'] as List)
        .map((item) => OrderItem.fromFirestore(item))
        .toList();



    return OrderModel(
      orderId: doc.id,
      userName: data['userName'] ?? 'Unknown',
      orderedAt: (data['orderedAt'] as Timestamp).toDate(),
      userPhoneNumber: data['userPhoneNumber'] ?? 'Unknown',
      status: data['status'] ?? 'Unknown',
      items: items,
      payment:data['paymentMode']??'not specified',
      collect: data['collectingMode']??"not specified",
      userLocation: data['userLocation'] ?? GeoPoint(0, 0), // Read userLocation

    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double totalPrice;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {

    double itemPrice = data['itemPrice'] ?? 0.0;
    int quantity = data['quantity'] ?? 0.0;
    double totalPrice = itemPrice * quantity;


    return OrderItem(
      name: data['itemName'] ?? 'Unknown',
      quantity: quantity,
      totalPrice: totalPrice,
    );
  }
}