//
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geolocator/geolocator.dart';
//
// import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
//
// class CategoriesProvider extends ChangeNotifier {
//   int activeChip = 100;
//   String selectedCategory = '';
//   List<String> categories = [];
//   List<Map<String, dynamic>> restaurantsList = [];
//
//   void setActiveChip(int index) {
//     activeChip = index;
//     print('Active Chip Set to: $activeChip');
//     notifyListeners();
//   }
//
//   void setSelectedCategory(String category) {
//     selectedCategory = category;
//     print('Selected Category Set to: $selectedCategory');
//     notifyListeners();
//   }
//
//   Future<void> fetchCategories(GeoPoint currentGeoPoint, double radius) async {
//     final email = SharedPreferencesHelper.getCustomerEmail();
//     if (email == null) {
//       print('No user is logged in');
//       return;
//     }
//
//     try {
//       final DocumentSnapshot<Map<String, dynamic>> clientsSnapshot =
//       await FirebaseFirestore.instance.collection('clients').doc(email).get();
//
//       if (!clientsSnapshot.exists) {
//         print('No client document found for the current user');
//         return;
//       }
//
//       final QuerySnapshot<Map<String, dynamic>> restaurantSnapshot =
//       await clientsSnapshot.reference.collection('restaurants').get();
//
//       Set<String> uniqueCategories = {};
//
//       for (final doc in restaurantSnapshot.docs) {
//         final GeoPoint location = doc['location'];
//         final double distance = Geolocator.distanceBetween(
//           currentGeoPoint.latitude,
//           currentGeoPoint.longitude,
//           location.latitude,
//           location.longitude,
//         );
//         print(distance);
//         if (distance > 0) {
//           String restaurantCategory = doc['category'];
//           if (!uniqueCategories.contains(restaurantCategory)) {
//             uniqueCategories.add(restaurantCategory);
//           }
//           print(restaurantCategory);
//         }
//       }
//
//       categories = uniqueCategories.toList();
//       print('Fetched Categories: $categories');
//       if (categories.isNotEmpty) {
//         setActiveChip(0);
//         setSelectedCategory(categories[0]);
//       }
//
//       notifyListeners();
//     } catch (e) {
//       print('Error fetching categories: $e');
//     }
//   }
//
//
//   Future<void> fetchRestaurants(String category) async {
//     try {
//       print('Fetching restaurants for category: $category');
//       final QuerySnapshot<Map<String, dynamic>> restaurantSnapshot =
//       await FirebaseFirestore.instance
//           .collection('restaurantAdmins')
//           .where('category', isEqualTo: category)
//           .get();
//       print(restaurantSnapshot.docs);
//
//       if (restaurantSnapshot.docs.isNotEmpty) {
//         restaurantsList = restaurantSnapshot.docs
//             .where((doc) => doc.data().keys.every((key) => doc[key] != null)) // Filter out docs with any null fields
//             .map((doc) => doc.data())
//             .toList();
//
//         print('Fetched Restaurants: $restaurantsList');
//       } else {
//         restaurantsList = [];
//         print('No restaurants found for category: $category');
//       }
//       notifyListeners();
//     } catch (e) {
//       print('Error fetching restaurants: $e');
//       restaurantsList = [];
//       notifyListeners();
//     }
//   }
//
//
// }
