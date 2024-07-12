import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantCacheProvider with ChangeNotifier {
  List<Map<String, dynamic>>? _cachedRestaurants;

  List<Map<String, dynamic>>? get cachedRestaurants => _cachedRestaurants;

  Future<void> loadCachedRestaurants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? restaurantsJson = prefs.getString('cachedRestaurants');
    if (restaurantsJson != null) {
      List<dynamic> decodedJson = jsonDecode(restaurantsJson);
      _cachedRestaurants = decodedJson.cast<Map<String, dynamic>>();
    }
    notifyListeners();
  }

  Future<void> fetchAndCacheRestaurants() async {
    List<Map<String, dynamic>> restaurants = [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .where('category', isNotEqualTo: 'grocery')
          .get();

      for (var doc in querySnapshot.docs) {
        final itemsSubcollection = await doc.reference.collection('items').get();

        if (itemsSubcollection.docs.isNotEmpty) {
          restaurants.add(doc.data() as Map<String, dynamic>);
        }
      }

      _cachedRestaurants = restaurants;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cachedRestaurants', jsonEncode(restaurants));
    } catch (e) {
      print('Error fetching restaurants: $e');
    }

    notifyListeners();
  }
}
