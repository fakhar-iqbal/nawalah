import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NGOCacheProvider with ChangeNotifier {
  List<Map<String, dynamic>>? _cachedNGOs;

  List<Map<String, dynamic>>? get cachedNGOs => _cachedNGOs;

  Future<void> loadCachedNGOs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ngosJson = prefs.getString('cachedNGOs');
    if (ngosJson != null) {
      List<dynamic> decodedJson = jsonDecode(ngosJson);
      _cachedNGOs = decodedJson.cast<Map<String, dynamic>>();
    }
    notifyListeners();
  }

  Future<void> fetchAndCacheNGOs() async {
    List<Map<String, dynamic>> ngos = [];

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('ngos').get();

      for (var doc in querySnapshot.docs) {
        ngos.add(doc.data() as Map<String, dynamic>);
      }

      _cachedNGOs = ngos;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cachedNGOs', jsonEncode(ngos));
    } catch (e) {
      print('Error fetching NGOs: $e');
    }

    notifyListeners();
  }
}
