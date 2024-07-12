import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _groceries = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  List<Map<String, dynamic>> get groceries => _groceries;
  bool get isLoading => _isLoading;

  Future<void> fetchGroceries({bool force = false}) async {
    if (!force && _groceries.isNotEmpty && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inMinutes < 0.5) {  // Only refresh if more than 5 minutes have passed
        return;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .where('category', isEqualTo: 'grocery')
          .get();

      List<Map<String, dynamic>> newGroceries = [];

      for (var doc in querySnapshot.docs) {
        final itemsSubcollection = await doc.reference.collection('items').get();

        if (itemsSubcollection.docs.isNotEmpty) {
          bool hasAvailableItem = itemsSubcollection.docs.any((itemDoc) {
            final data = itemDoc.data() as Map<String, dynamic>;
            return data['availability'] == true;
          });

          if (hasAvailableItem) {
            newGroceries.add(doc.data() as Map<String, dynamic>);
          }
        }
      }

      _groceries = newGroceries;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('Error fetching groceries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}