import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogoProvider extends ChangeNotifier {
  String? _logoUrl;

  String? get logoUrl => _logoUrl;

  Future<void> fetchLogo(String email) async {
    if (_logoUrl != null) {
      return; // Return if logo is already fetched
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      _logoUrl = snapshot.docs.first['logo'];
      notifyListeners(); // Notify listeners about change
    }
  }
}
