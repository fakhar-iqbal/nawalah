import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/widgets/restaurant_tile.dart';
import 'package:provider/provider.dart';



import 'restaurant_cache_provider.dart';


class HomeRestaurantsList extends StatefulWidget {
  const HomeRestaurantsList({super.key});

  @override
  State<HomeRestaurantsList> createState() => _HomeRestaurantsListState();
}

class _HomeRestaurantsListState extends State<HomeRestaurantsList> {
  late Future<void> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RestaurantCacheProvider>(context, listen: false);
    _restaurantsFuture = provider.loadCachedRestaurants().then((_) {
      if (provider.cachedRestaurants == null) {
        return provider.fetchAndCacheRestaurants();
      }
    });
  }

  Future<void> refreshRestaurants() async {
    await Provider.of<RestaurantCacheProvider>(context, listen: false).fetchAndCacheRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _restaurantsFuture,
      builder: (context, snapshot) {
        final provider = Provider.of<RestaurantCacheProvider>(context);
        if (snapshot.connectionState == ConnectionState.waiting && provider.cachedRestaurants == null) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (provider.cachedRestaurants == null || provider.cachedRestaurants!.isEmpty) {
          return const Center(child: Text('No restaurants found!'));
        } else {
          final restaurants = provider.cachedRestaurants!;

          return SizedBox(
            width: double.infinity,
            height: 580.h,
            child: RefreshIndicator(
              onRefresh: refreshRestaurants,
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];

                  return RestaurantTile(
                    isClosed: false,
                    isAvailable: restaurant['availability'] ?? true,
                    restaurantID: restaurant['restaurantId'] ?? "",
                    email: restaurant['email'] ?? "",
                    restaurantName: restaurant['username'] ?? "",
                    restaurantAddress: restaurant['address'] ?? "Unknown",
                    restaurantDescription: 'Buy discounted food items 🔥',
                    distance: 'now',
                    image: restaurant['logo'] ?? "",
                    isOnlineImage: true,
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
