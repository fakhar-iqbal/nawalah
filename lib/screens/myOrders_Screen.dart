
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../util/local_storage/shared_preferences_helper.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
    });

    String? email = await getCustomerEmail();
    if (email != null) {
      final QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .get();

      for (var restaurantDoc in restaurantSnapshot.docs) {
        final String restaurantName = restaurantDoc['username'];
        final QuerySnapshot orderSnapshot = await restaurantDoc.reference
            .collection('orders')
            .where('userEmail', isEqualTo: email)
            .get();

        for (var orderDoc in orderSnapshot.docs) {
          final data = orderDoc.data() as Map<String, dynamic>;
          data['restaurantName'] = restaurantName;  // Add restaurant name to each order
          orders.add(data);
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String?> getCustomerEmail() async {
    String? email = SharedPreferencesHelper.getCustomerEmail();
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFDF6F7),
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.myOrders,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25.sp,
              fontFamily: 'Calibri',
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFD11559),
        ),
        body: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)]
                )
            ),
            child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final restaurantName = order['restaurantName'];
              final orderItems = List<Map<String, dynamic>>.from(order['orderItems']);
              final totalPrice = order['totalPrice'];
              final orderedAt = (order['orderedAt'] as Timestamp).toDate();
              final status = order['status'];

              return Container(
                margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      tileColor: Colors.white,
                      title: Text(
                        restaurantName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...orderItems.map((item) {

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                          tileColor: const Color(0xFFD11559),
                          title: Text(
                            item['itemName'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Quantity: ${item['quantity']}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            'Status: $status',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      tileColor: Colors.white,
                      title: Text(
                        'Total: PKR ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Ordered at: ${DateFormat('yyyy-MM-dd – kk:mm').format(orderedAt)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )));
  }
}
