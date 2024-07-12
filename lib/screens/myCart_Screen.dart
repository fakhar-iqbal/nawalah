// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
//
//
//
//
// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});
//
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   List<Map<String, dynamic>> cartItems = [];
//   bool isLoading = true;
//   String? currentUserEmail;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchCartItems();
//     _loadCurrentUserEmail();
//   }
//
//   Future<void> _loadCurrentUserEmail() async {
//     String? email = SharedPreferencesHelper.getCustomerEmail();
//     setState(() {
//       currentUserEmail = email ?? 'unknownUser';
//     });
//   }
//
//   Future<void> fetchCartItems() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     String? email = await getCustomerEmail();
//     if (email != null) {
//       try {
//         final QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
//             .collection('clients')
//             .doc(email)
//             .collection('cart')
//             .get();
//
//         if (cartSnapshot.docs.isNotEmpty) {
//           cartItems = cartSnapshot.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             return {
//               'itemName': data['itemName'],
//               'itemPrice': data['itemPrice'],
//               'restaurantName': data['restaurantName'],
//               'quantity': data['quantity'],
//               'itemId': doc.id,
//               'itemImage': data['itemImage'], // Ensure you have this field
//             };
//           }).toList();
//         } else {
//           cartItems = [];
//         }
//       } catch (e) {
//         print('Error fetching cart items: $e');
//       }
//     }
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   Future<String?> getCustomerEmail() async {
//     String? email = SharedPreferencesHelper.getCustomerEmail();
//     return email;
//   }
//
//   void handleDelete(String itemId) async {
//     String? email = await getCustomerEmail();
//     if (email != null) {
//       await FirebaseFirestore.instance
//           .collection('clients')
//           .doc(email)
//           .collection('cart')
//           .doc(itemId)
//           .delete();
//     }
//     fetchCartItems();
//   }
//
//   double calculateTotalPrice() {
//     double total = 0;
//     for (var item in cartItems) {
//       total += item['itemPrice'] * item['quantity'];
//     }
//     return total;
//   }
//
//   void showCollectingModeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title:  const Text('What would you prefer?',style: TextStyle(
//             color: Colors.black,
//             fontSize: 15, // Adjust the font size as needed
//           ),),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 showPaymentModeDialog(context, 'pickup');
//               },
//               child: const Text('Pickup'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 showPaymentModeDialog(context, 'delivery');
//               },
//               child: const Text('Delivery'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void showPaymentModeDialog(BuildContext context, String collectingMode) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: const Text('Choose Payment Mode',style: TextStyle(
//             color: Colors.black,
//             fontSize: 15, // Adjust the font size as needed
//           ),),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 placeOrder(false, 'online', collectingMode);
//               },
//               child: const Text('Online'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 placeOrder(false, 'on cash', collectingMode);
//               },
//               child: const Text('On Cash'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void showDonationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: const Text('Proceed to Online Payment',style: TextStyle(
//             color: Colors.black,
//             fontSize: 15, // Adjust the font size as needed
//           ),),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 placeOrder(true, 'online', 'donation');
//               },
//               child: const Text('Pay with jazzcash'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> placeOrder(bool isDonation, String paymentMode, String collectingMode) async {
//     if (currentUserEmail == null) return;
//
//     // Fetch current user data
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('clients')
//         .doc(currentUserEmail)
//         .get();
//
//     String userName = userDoc['userName'] ?? 'unknownUser';
//     GeoPoint userLocation = userDoc['location'] ?? const GeoPoint(0, 0);
//     String userPhoneNumber = userDoc['phoneNumber'] ?? 'unknown';
//
//     // Prepare order details
//     List<Map<String, dynamic>> orderItems = cartItems.map((item) {
//       return {
//         'itemName': item['itemName'],
//         'quantity': item['quantity'],
//         'price': item['itemPrice'],
//       };
//     }).toList();
//
//     double totalPrice = orderItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
//
//     // Group cart items by restaurant
//     var restaurantOrders = <String, List<Map<String, dynamic>>>{};
//
//     for (var item in cartItems) {
//       var restaurantName = item['restaurantName'];
//       if (!restaurantOrders.containsKey(restaurantName)) {
//         restaurantOrders[restaurantName] = [];
//       }
//       restaurantOrders[restaurantName]!.add(item);
//     }
//
//     for (var entry in restaurantOrders.entries) {
//       var restaurantName = entry.key;
//       var items = entry.value;
//
//       // Find restaurantId based on restaurantName
//       QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
//           .collection('restaurantAdmins')
//           .where('username', isEqualTo: restaurantName)
//           .limit(1)
//           .get();
//
//       if (restaurantSnapshot.docs.isNotEmpty) {
//         var restaurantId = restaurantSnapshot.docs.first.id;
//
//         // Send order details to the restaurant's orders subcollection
//         await FirebaseFirestore.instance
//             .collection('restaurantAdmins')
//             .doc(restaurantId)
//             .collection('orders')
//             .add({
//           'userName': userName,
//           'userEmail': currentUserEmail,
//           'userLocation': userLocation,
//           'userPhoneNumber': userPhoneNumber,
//           'orderItems': items,
//           'totalPrice': totalPrice,
//           'isDonation': isDonation,
//           'paymentMode': paymentMode,
//           'collectingMode': collectingMode,
//           'orderedAt': Timestamp.now(),
//           'status': 'pending',
//         });
//       }
//     }
//
//     // Clear the cart
//     String? email = await getCustomerEmail();
//     if (email != null) {
//       final cartCollection = FirebaseFirestore.instance
//           .collection('clients')
//           .doc(email)
//           .collection('cart');
//
//       final cartDocs = await cartCollection.get();
//       for (var doc in cartDocs.docs) {
//         await doc.reference.delete();
//       }
//
//       fetchCartItems();
//     }
//
//     // Show confirmation
//     showOrderDialog(context, isDonation);
//   }
//
//   void showOrderDialog(BuildContext context, bool isDonation) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           content: Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   isDonation ? 'Donation placed successfully!' : 'Order placed successfully!',
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFD11559),
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text(
//                     'OK',
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFD11559),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Center(
//           child: Text(
//             'Cart',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 25,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Recoleta',
//             ),
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     backgroundColor: const Color(0xFFF6BFBF),
//                     title: const Text(
//                       'Clear Cart',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontFamily: 'Recoleta',
//                       ),
//                     ),
//                     content: const Text(
//                       'Are you sure you want to clear your cart?',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontFamily: 'Recoleta',
//                       ),
//                     ),
//                     actions: [
//                       TextButton(
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontFamily: 'Recoleta',
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                       TextButton(
//                         child: const Text(
//                           'Clear',
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontFamily: 'Recoleta',
//                           ),
//                         ),
//                         onPressed: () async {
//                           String? email = await getCustomerEmail();
//                           if (email != null) {
//                             await FirebaseFirestore.instance
//                                 .collection('clients')
//                                 .doc(email)
//                                 .collection('cart')
//                                 .get()
//                                 .then((snapshot) {
//                               for (DocumentSnapshot ds in snapshot.docs) {
//                                 ds.reference.delete();
//                               }
//                             });
//                             fetchCartItems();
//                           }
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             icon: const Icon(Icons.delete_forever, color: Colors.white),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
//           ),
//         ),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = cartItems[index];
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: Colors.black, // Set the border color here
//                         width: 1.0, // Set the border width here
//                       ),
//
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Image.network(
//                               //item['itemImage'], // Display item image
//                               "https://th.bing.com/th/id/R.92662f4b75252a8511be070906bd8fef?rik=AihxnhgAvhZiPQ&riu=http%3a%2f%2fcdn.onlinewebfonts.com%2fsvg%2fimg_255516.png&ehk=GW7xObVdfr7cFJU6tWSbD7Iu7QjUza%2fjLeHjtR5QNU4%3d&risl=&pid=ImgRaw&r=0",
//                               width: 50,
//                               height: 50,
//                             ),
//                             const SizedBox(width: 16),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item['restaurantName'],
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 Text(
//                                   item['itemName'],
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color:Colors.black,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Price: Rs. ${item['itemPrice']*item['quantity']}',
//                                   style: const TextStyle(fontSize: 16,color: Colors.black,),
//
//                                 ),
//                                 Text(
//                                   'Quantity: ${item['quantity']}',
//                                   style: const TextStyle(fontSize: 16,color: Colors.black,),
//
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 handleDelete(item['itemId']);
//                               },
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFD11559),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     'Total : pkr. ${calculateTotalPrice().toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           showCollectingModeDialog(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: const Text(
//                           'Place Order',
//                           style: TextStyle(
//                             color: Color(0xFFD11559),
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           showDonationDialog(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: const Text(
//                           'Donate',
//                           style: TextStyle(
//                             color: Color(0xFFD11559),
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:crypto/crypto.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool _isProcessingPayment = false;
  bool _paymentResultReceived = false;
  String? currentUserEmail;
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    _loadCurrentUserEmail();
  }

  Future<void> _loadCurrentUserEmail() async {
    String? email = SharedPreferencesHelper.getCustomerEmail();
    setState(() {
      currentUserEmail = email ?? 'unknownUser';
    });
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });

    String? email = await getCustomerEmail();
    if (email != null) {
      try {
        final QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection('clients')
            .doc(email)
            .collection('cart')
            .get();

        if (cartSnapshot.docs.isNotEmpty) {
          cartItems = cartSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'itemName': data['itemName'],
              'itemPrice': data['itemPrice'],
              'restaurantName': data['restaurantName'],
              'quantity': data['quantity'],
              'itemId': doc.id,
              'itemImage': data['itemImage'], // Ensure you have this field
            };
          }).toList();
        } else {
          cartItems = [];
        }
      } catch (e) {
        print('Error fetching cart items: $e');
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

  void handleDelete(String itemId) async {
    String? email = await getCustomerEmail();
    if (email != null) {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(email)
          .collection('cart')
          .doc(itemId)
          .delete();
    }
    fetchCartItems();
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item['itemPrice'] * item['quantity'];
    }
    return total;
  }

  void showCollectingModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'What would you prefer?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15, // Adjust the font size as needed
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showPaymentModeDialog(context, 'pickup');
              },
              child: const Text('Pickup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showPaymentModeDialog(context, 'delivery');
              },
              child: const Text('Delivery'),
            ),
          ],
        );
      },
    );
  }

  void showPaymentModeDialog(BuildContext context, String collectingMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Choose Payment Mode',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15, // Adjust the font size as needed
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showJazzCashPaymentDialog(context, collectingMode, false);
              },
              child: const Text('Online'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                placeOrder(false, 'on cash', collectingMode);
              },
              child: const Text('On Cash'),
            ),
          ],
        );
      },
    );
  }

  void showDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Proceed to Online Payment',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15, // Adjust the font size as needed
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showJazzCashPaymentDialog(context, 'donation', true);
              },
              child: const Text('Pay with JazzCash'),
            ),
          ],
        );
      },
    );
  }

  // void showJazzCashPaymentDialog(
  //     BuildContext context, String collectingMode, bool isDonation) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.grey[100],
  //         title: const Text('Pay with JazzCash'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text('Enter your JazzCash number:'),
  //             TextField(
  //               controller: phoneNumberController,
  //               decoration: const InputDecoration(
  //                 hintText: 'Phone Number',
  //                 filled: true,
  //                 fillColor: Colors.white,
  //               ),
  //               keyboardType: TextInputType.phone,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop();
  //               await processJazzCashPayment(
  //                   phoneNumberController.text,
  //                   calculateTotalPrice().toStringAsFixed(2),
  //                   collectingMode,
  //                   isDonation);
  //             },
  //             child: const Text('Pay with JazzCash'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // void showJazzCashPaymentDialog(
  //     BuildContext context, String collectingMode, bool isDonation) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: const Text('Online Payment',style: TextStyle(color: Colors.black),),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text('Enter your JazzCash number:',style: TextStyle(color: Colors.black),),
  //             TextField(
  //               controller: phoneNumberController,
  //               decoration: const InputDecoration(
  //                 hintText: 'Phone Number',
  //                 filled: true,
  //                 fillColor: Colors.white,
  //                 contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  //
  //               ),
  //               keyboardType: TextInputType.phone,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop();
  //               showProcessingDialog(context);
  //               await processJazzCashPayment(
  //                   phoneNumberController.text,
  //                   calculateTotalPrice().toStringAsFixed(2),
  //                   collectingMode,
  //                   isDonation);
  //             },
  //             child: const Text('Pay with JazzCash'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void showJazzCashPaymentDialog(
      BuildContext context, String collectingMode, bool isDonation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Online Payment',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your JazzCash number:',
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF4A4A4A)),
                  ),
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF4A4A4A)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                showProcessingDialog(context);
                await processJazzCashPayment(
                    phoneNumberController.text,
                    calculateTotalPrice().toStringAsFixed(2),
                    collectingMode,
                    isDonation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEFE9E9), // JazzCash brand color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Pay with JazzCash',
                style: TextStyle(fontSize: 16,color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
  void showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),
              Text('Please wait while we confirm the payment...',style: TextStyle(color: Colors.black),),
            ],
          ),
        );
      },
    );
  }
  Future<void> processJazzCashPayment(String phoneNumber, String amount,
      String collectingMode, bool isDonation) async {
    try {
      String dateandtime = DateFormat("yyyyMMddHHmmss").format(DateTime.now());
      String dexpiredate =
      DateFormat("yyyyMMddHHmmss").format(DateTime.now().add(Duration(days: 1)));
      String tre = "T" + dateandtime;
      String pp_Amount = (double.parse(amount) * 100).toStringAsFixed(0);
      String pp_BillReference = "billRef";
      String pp_Description = "Description";
      String pp_Language = "EN";
      String pp_MerchantID = "your id";
      String pp_Password = "your password";
      String pp_ReturnURL =
          "https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction";
      String pp_ver = "1.1";
      String pp_TxnCurrency = "PKR";
      String pp_TxnDateTime = dateandtime.toString();
      String pp_TxnExpiryDateTime = dexpiredate.toString();
      String pp_TxnRefNo = tre.toString();
      String pp_TxnType = "MWALLET";
      String ppmpf_1 = phoneNumber;
      String IntegeritySalt = "your key";
      String and = '&';
      String superdata = IntegeritySalt +
          and +
          pp_Amount +
          and +
          pp_BillReference +
          and +
          pp_Description +
          and +
          pp_Language +
          and +
          pp_MerchantID +
          and +
          pp_Password +
          and +
          pp_ReturnURL +
          and +
          pp_TxnCurrency +
          and +
          pp_TxnDateTime +
          and +
          pp_TxnExpiryDateTime +
          and +
          pp_TxnRefNo +
          and +
          pp_TxnType +
          and +
          pp_ver +
          and +
          ppmpf_1;

      var key = utf8.encode(IntegeritySalt);
      var bytes = utf8.encode(superdata);
      var hmacSha256 = Hmac(sha256, key);
      Digest sha256Result = hmacSha256.convert(bytes);
      var url = Uri.parse(
          'https://sandbox.jazzcash.com.pk/ApplicationAPI/API/Payment/DoTransaction');

      var response = await http.post(url, body: {
        "pp_Version": pp_ver,
        "pp_TxnType": pp_TxnType,
        "pp_Language": pp_Language,
        "pp_MerchantID": pp_MerchantID,
        "pp_Password": pp_Password,
        "pp_TxnRefNo": tre,
        "pp_Amount": pp_Amount,
        "pp_TxnCurrency": pp_TxnCurrency,
        "pp_TxnDateTime": dateandtime,
        "pp_BillReference": pp_BillReference,
        "pp_Description": pp_Description,
        "pp_TxnExpiryDateTime": dexpiredate,
        "pp_ReturnURL": pp_ReturnURL,
        "pp_SecureHash": sha256Result.toString(),
        "ppmpf_1": phoneNumber,
      });

      print("response=>");
      print(response.body);

      if (response.statusCode == 200 && response.body.contains("Success")) {
        Navigator.of(context).pop();
        if (isDonation) {
          // Handle donation success

          placeOrder(true, 'JazzCash', "donation");
        } else {
          // Handle order success
          placeOrder(false, 'JazzCash', collectingMode);
        }
      } else {
        // Handle payment failure
        Navigator.of(context).pop();
        showFailedOrderDialog(context,false);
      }
    } catch (e) {
      Navigator.of(context).pop();
      // Handle exceptions
      print("Exception during JazzCash payment: $e");
      showFailedOrderDialog(context,false);
    }
  }


  Future<void> placeOrder(bool isDonation, String paymentMode, String collectingMode) async {
    if (currentUserEmail == null) return;

    // Fetch current user data
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(currentUserEmail)
        .get();

    String userName = userDoc['userName'] ?? 'unknownUser';
    GeoPoint userLocation = userDoc['location'] ?? const GeoPoint(0, 0);
    String userPhoneNumber = userDoc['phoneNumber'] ?? 'unknown';

    // Prepare order details
    List<Map<String, dynamic>> orderItems = cartItems.map((item) {
      return {
        'itemName': item['itemName'],
        'quantity': item['quantity'],
        'price': item['itemPrice'],
      };
    }).toList();

    double totalPrice = orderItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

    // Group cart items by restaurant
    var restaurantOrders = <String, List<Map<String, dynamic>>>{};

    for (var item in cartItems) {
      var restaurantName = item['restaurantName'];
      if (!restaurantOrders.containsKey(restaurantName)) {
        restaurantOrders[restaurantName] = [];
      }
      restaurantOrders[restaurantName]!.add(item);
    }

    for (var entry in restaurantOrders.entries) {
      var restaurantName = entry.key;
      var items = entry.value;

      // Find restaurantId based on restaurantName
      QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .where('username', isEqualTo: restaurantName)
          .limit(1)
          .get();

      if (restaurantSnapshot.docs.isNotEmpty) {
        var restaurantId = restaurantSnapshot.docs.first.id;

        // Send order details to the restaurant's orders subcollection
        await FirebaseFirestore.instance
            .collection('restaurantAdmins')
            .doc(restaurantId)
            .collection('orders')
            .add({
          'userName': userName,
          'userEmail': currentUserEmail,
          'userLocation': userLocation,
          'userPhoneNumber': userPhoneNumber,
          'orderItems': items,
          'totalPrice': totalPrice,
          'isDonation': isDonation,
          'paymentMode': paymentMode,
          'collectingMode': collectingMode,
          'orderedAt': Timestamp.now(),
          'status': 'pending',
        });
      }
    }

    // Clear the cart
    String? email = await getCustomerEmail();
    if (email != null) {
      final cartCollection = FirebaseFirestore.instance
          .collection('clients')
          .doc(email)
          .collection('cart');

      final cartDocs = await cartCollection.get();
      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }

      fetchCartItems();
    }

    // Show confirmation
    showOrderDialog(context, isDonation);
  }
  void showFailedOrderDialog(BuildContext context, bool isSuccessful) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSuccessful ? 'Payment Successful!' : 'Online Payment Failed!',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD11559),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void showOrderDialog(BuildContext context, bool isDonation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDonation ? 'Donation placed successfully!' : 'Order placed successfully!',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD11559),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD11559),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Center(
          child: Text(
            'Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              fontFamily: 'Recoleta',
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text(
                      'Clear Cart',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Recoleta',
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to clear your cart?',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Recoleta',
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Recoleta',
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Recoleta',
                          ),
                        ),
                        onPressed: () async {
                          String? email = await getCustomerEmail();
                          if (email != null) {
                            await FirebaseFirestore.instance
                                .collection('clients')
                                .doc(email)
                                .collection('cart')
                                .get()
                                .then((snapshot) {
                              for (DocumentSnapshot ds in snapshot.docs) {
                                ds.reference.delete();
                              }
                            });
                            fetchCartItems();
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete_forever, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          // item['itemImage'],
                          "https://th.bing.com/th/id/R.92662f4b75252a8511be070906bd8fef?rik=AihxnhgAvhZiPQ&riu=http%3a%2f%2fcdn.onlinewebfonts.com%2fsvg%2fimg_255516.png&ehk=GW7xObVdfr7cFJU6tWSbD7Iu7QjUza%2fjLeHjtR5QNU4%3d&risl=&pid=ImgRaw&r=0",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['restaurantName'],
                                style: const TextStyle(
                                  color: Colors.black,
                                    fontWeight: FontWeight.bold),

                              ),
                              Text(item['itemName'],style: TextStyle(color: Colors.black,),),
                              Text('Price: Rs. ${item['itemPrice']}',style: TextStyle(color: Colors.black,),),
                              Text('Quantity: ${item['quantity']}',style: TextStyle(color: Colors.black,),),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            handleDelete(item['itemId']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD11559),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Total: Rs. ${calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showCollectingModeDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart,
                            color: Color(0xFFD11559)),
                        const SizedBox(width: 8),
                        const Text(
                          'Place Order',
                          style: TextStyle(
                            color: Color(0xFFD11559),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDonationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite,
                            color: Color(0xFFD11559)),
                        SizedBox(width: 8),
                        Text(
                          'Donate',
                          style: TextStyle(
                            color: Color(0xFFD11559),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
