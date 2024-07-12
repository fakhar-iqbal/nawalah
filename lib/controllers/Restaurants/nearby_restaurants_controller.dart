import 'package:flutter/foundation.dart';
import 'package:paraiso/repositories/res_post_repo.dart';
import 'package:paraiso/models/restaurant_admin_model.dart';

import '../../models/nearby_restaurants.dart';

class NearbyRestaurantsController with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  List<NearbyRestaurants> _nearbyRestaurantsList = [];
  List<Map<String, dynamic>> _restaurantsWithDiscounts = [];



  List<NearbyRestaurants> get nearbyRestaurantsList => _nearbyRestaurantsList;

  List<Map<String, dynamic>> get restaurantsWithDiscount =>
      _restaurantsWithDiscounts;

  Future<void> fetchNearbyRestaurants(RestaurantAdmin admin) async {
    final restaurants = await _repo.getNearbyRestaurants(admin.email);
    _nearbyRestaurantsList = restaurants;
    notifyListeners();
  }

  Future<void> fetchAndSaveNearbyRestaurants(
    RestaurantAdmin admin,
  ) async {
    await _repo.fetchAndSaveNearbyRestaurants(admin);
    notifyListeners();
  }

  Future<void> getRestaurantsWithDiscounts(RestaurantAdmin admin) async {
    final ress = await _repo.getRestaurantsWithDiscounts(admin);
    _restaurantsWithDiscounts = ress;
    notifyListeners();
  }

  final Map<String, bool> _restaurantFavorites = {};
  Map<String, bool> get restaurantFavorites => _restaurantFavorites;

  Future<void> toggleRestaurantFavorite(String resId, bool isFavorite) async {
    try {
      await _repo.toggleRestaurantFavorite(resId, isFavorite);
      _restaurantFavorites[resId] = isFavorite;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error toggling restaurant favorite: $e");
    }
  }

  Future<bool> isRestaurantFavorite(String resId) async {
    if (_restaurantFavorites.containsKey(resId)) {
      return _restaurantFavorites[resId]!;
    } else {
      final res = await _repo.isRestaurantFavorite(resId);
      _restaurantFavorites[resId] = res;
      return res;
    }
  }


}
