
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../util/local_storage/shared_preferences_helper.dart';
//
// class HomeChipsController extends GetxController {
//   var activeChip = 0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Load from SharedPreferences
//     SharedPreferencesHelper.getActiveChip().then((value) {
//       activeChip.value = value;
//     });
//   }
//
//   @override
//   void onClose() {
//     // Save to SharedPreferences
//     SharedPreferencesHelper.saveActiveChip(activeChip.value);
//     super.onClose();
//   }
//
//   void setActiveChip(int index) {
//     activeChip.value = index;
//     SharedPreferencesHelper.saveActiveChip(index);
//   }
// }
//
//
// class HomeChipsRow extends StatefulWidget {
//   const HomeChipsRow({super.key});
//
//   @override
//   State<HomeChipsRow> createState() => _HomeChipsRowState();
// }
//
// class _HomeChipsRowState extends State<HomeChipsRow> {
//   late Future<String> _usernameFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _usernameFuture = _fetchUsername();
//   }
//
//   Future<String> _fetchUsername() async {
//     // Check if the username is already cached
//     String? cachedUsername = await SharedPreferencesHelper.getUsername();
//     if (cachedUsername != null) {
//       return cachedUsername;
//     }
//
//     // Get the current user email from SharedPreferences
//     final email = SharedPreferencesHelper.getCustomerEmail();
//     if (email == null) {
//       throw Exception('User email not found');
//     }
//
//     // Fetch the user's document from Firestore
//     DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
//         .collection('clients')
//         .doc(email)
//         .get();
//
//     if (!userDoc.exists) {
//       throw Exception('User document not found');
//     }
//
//     // Get the username from the user's document
//     String username = userDoc.data()?['userName'] ?? 'User';
//     // Cache the username
//     SharedPreferencesHelper.saveUsername(username);
//     return username;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Get the current time
//     final now = DateTime.now();
//     String greeting;
//
//     // Determine the appropriate greeting
//     if (now.hour < 12) {
//       greeting = 'Good Morning';
//     } else if (now.hour < 17) {
//       greeting = 'Good Afternoon';
//     } else {
//       greeting = 'Good Evening';
//     }
//
//     return FutureBuilder<String>(
//       future: _usernameFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else {
//           final String username = snapshot.data!;
//           return Container(
//             color: const Color(0xFFD11559),
//             width: 390.w,
//             height: 100.h,
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.symmetric(horizontal: 20.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Hi $username,",
//                   style: TextStyle(
//                     fontSize: 24.sp,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 Text.rich(
//                   TextSpan(
//                     children: [
//                       TextSpan(
//                         text: "$greeting, Let's Save a Meal!",
//                         style: TextStyle(
//                           fontSize: 20.sp,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }

class HomeChipsController extends GetxController {
  var activeChip = 0.obs;
  final SessionManager sessionManager = Get.put(SessionManager());

  @override
  void onInit() {
    super.onInit();
    // Load active chip from SharedPreferences
    SharedPreferencesHelper.getActiveChip().then((value) {
      activeChip.value = value;
    });
  }

  @override
  void onClose() {
    // Save active chip to SharedPreferences
    SharedPreferencesHelper.saveActiveChip(activeChip.value);
    super.onClose();
  }

  void setActiveChip(int index) {
    activeChip.value = index;
    SharedPreferencesHelper.saveActiveChip(index);
  }
}




class HomeChipsRow extends StatefulWidget {
  const HomeChipsRow({super.key});

  @override
  State<HomeChipsRow> createState() => _HomeChipsRowState();
}

class _HomeChipsRowState extends State<HomeChipsRow> {
  final SessionManager sessionManager = Get.find<SessionManager>();
  late Future<String> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _usernameFuture = _fetchUsername();
  }

  Future<String> _fetchUsername() async {
    // Check if the username is already cached in session manager
    if (sessionManager.username.isNotEmpty) {
      return sessionManager.username.value;
    }

    // Get the current user email from SharedPreferences
    final email = await SharedPreferencesHelper.getCustomerEmail();
    if (email == null) {
      throw Exception('User email not found');
    }

    // Fetch the user's document from Firestore
    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(email)
        .get();

    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    // Get the username from the user's document
    String username = userDoc.data()?['userName'] ?? 'User';
    // Cache the username in session manager
    sessionManager.setUsername(username);
    return username;
  }

  @override
  Widget build(BuildContext context) {
    // Get the current time
    final now = DateTime.now();
    String greeting;

    // Determine the appropriate greeting
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return FutureBuilder<String>(
      future: _usernameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final String username = snapshot.data!;
          return Container(
            color: const Color(0xFFD11559),
            width: 390.w,
            height: 100.h,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hi $username,",
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "$greeting, Let's Save a Meal!",
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}





class SessionManager extends GetxController {
  var username = ''.obs;

  void setUsername(String name) {
    username.value = name;
  }

  void clearUsername() {
    username.value = '';
  }
}