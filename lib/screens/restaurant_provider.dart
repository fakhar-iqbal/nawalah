import 'package:flutter/foundation.dart';
import '../repositories/customer_firebase_calls.dart';
import '../util/local_storage/shared_preferences_helper.dart';

class RestaurantProvider with ChangeNotifier {
  List<dynamic> _restaurantLists = [];
  List<dynamic> _restaurantListIds = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  List<dynamic> get restaurantLists => _restaurantLists;
  List<dynamic> get restaurantListIds => _restaurantListIds;
  bool get isLoading => _isLoading;

  Future<void> fetchRestaurants({bool force = false}) async {
    if (!force && _restaurantLists.isNotEmpty && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inMinutes < 0.5) {  // Only refresh if more than 1 minutes have passed
        return;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final mydata = MyCustomerCalls();
      final items = SharedPreferencesHelper.getCustomerType() == 'guest'
          ? await mydata.getRestaurantsWithDiscountsForGuest()
          : await mydata.getRestaurantsWithDiscounts();

      _restaurantLists.clear();
      _restaurantListIds.clear();

      for (final item in items) {
        _restaurantListIds.add(item['restaurantId']);
        _restaurantLists.add(item);
      }

      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('Error fetching restaurants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}