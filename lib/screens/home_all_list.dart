import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:provider/provider.dart';

import '../widgets/restaurant_tile.dart';

import 'restaurant_provider.dart';
class HomeAllList extends StatefulWidget {
  const HomeAllList({Key? key}) : super(key: key);

  @override
  State<HomeAllList> createState() => _HomeAllListState();
}

class _HomeAllListState extends State<HomeAllList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().fetchRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        if (restaurantProvider.isLoading && restaurantProvider.restaurantLists.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
          height: MediaQuery.of(context).size.height * .7,
          child: RefreshIndicator(
            onRefresh: () => restaurantProvider.fetchRestaurants(force: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: restaurantProvider.restaurantLists.length *
                        MediaQuery.of(context).size.height *
                        .135,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurantProvider.restaurantLists.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurantProvider.restaurantLists[index];
                        final restaurantId = restaurantProvider.restaurantListIds[index];

                        return RestaurantTile(
                          restaurantID: restaurantId,
                          restaurantName: restaurant['restaurantName'],
                          restaurantAddress: restaurant['restaurantAddress'],
                          restaurantDescription:
                          '${restaurant["discount"]} discount on ${restaurant['itemName']}',
                          distance: 'now',
                          image: restaurant['restaurantLogo'],
                          isOnlineImage: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
