
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../util/local_storage/shared_preferences_helper.dart';

//
//
class RestaurantDetailsScreen extends StatefulWidget {
  final String image;
  final double price;
  final bool isOnlineImage;
  final String restaurantId;
  final bool isAvailable;
  final String restaurantName;
  final String restaurantImage;
  final Map<String, dynamic> foodItem;
  final String restaurantAddress;

  const RestaurantDetailsScreen({
    Key? key,
    required this.image,
    required this.price,
    required this.isOnlineImage,
    required this.restaurantId,
    required this.isAvailable,
    required this.restaurantName,
    required this.restaurantImage,
    required this.foodItem,
    required this.restaurantAddress,
  }) : super(key: key);

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  Map<String, bool> addedItems = {}; // Track added state for each item
  Map<String, int> itemQuantities = {}; // Track quantities for each item
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserEmail();
  }

  // Method to load the current user's email from SharedPreferences
  Future<void> _loadCurrentUserEmail() async {
    String? email = await SharedPreferencesHelper.getCustomerEmail();
    setState(() {
      currentUserEmail = email ?? 'unknownUser';
    });
  }

  // Method to add items to the cart
  Future<bool> addToCart(String itemName, double itemPrice,
      String fetchedItemImage, int quantity) async {

    if (currentUserEmail == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(currentUserEmail)
          .collection('cart')
          .add({
        'itemName': itemName,
        'itemPrice': itemPrice,
        'itemImage': fetchedItemImage,
        'quantity': quantity,
        'restaurantName': widget.restaurantName,
        'addedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: fetchRestaurantData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text('Error fetching data')));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
              body: Center(child: Text('No data available')));
        }

        var restaurantData = snapshot.data!.data();
        print(restaurantData);

        String fetchedImage = '';
        if (restaurantData is Map<String, dynamic>) {
          fetchedImage = restaurantData['logo'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpjFs9Gyct2YwXBewzCbAcEzbePEZkS0CnNQ&s';
        } else {
          fetchedImage = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpjFs9Gyct2YwXBewzCbAcEzbePEZkS0CnNQ&s';
        }
        print(fetchedImage);
        double fetchedPrice =
            double.tryParse(widget.foodItem['price'].toString()) ?? 0.0;
        print(fetchedPrice);

        return Scaffold(
          backgroundColor: const Color(0xFFFDF6F7),
          appBar: AppBar(
            title: Text(
              widget.restaurantName,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 25,
                fontFamily: 'Recoleta',
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: const Color(0xFFD11559),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD11559),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFF3EEDD),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 95,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: widget.isOnlineImage
                              ? NetworkImage(widget.image)
                              : AssetImage("assets/images/${widget.image}")
                          as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurantName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "The taste finds you",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Items We Serve',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              FutureBuilder<QuerySnapshot>(
                future: fetchItemsData(),
                builder: (context, itemsSnapshot) {
                  if (itemsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemsSnapshot.hasError) {
                    return const Center(child: Text('Error fetching items'));
                  }

                  if (!itemsSnapshot.hasData ||
                      itemsSnapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No items available'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var itemData =
                      itemsSnapshot.data!.docs[index].data() as Map<String, dynamic>?;

                      String fetchedItemImage = itemData?['image'] ??
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpjFs9Gyct2YwXBewzCbAcEzbePEZkS0CnNQ&s';
                      double fetchedItemPrice =
                          double.tryParse(itemData?['price']?.toString() ??
                              '0.0') ??
                              0.0;
                      String itemName = itemData?['name'] ?? 'Unknown';

                      // Initialize quantity if not already set
                      itemQuantities.putIfAbsent(itemName, () => 1);

                      return StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setItemState) {
                          bool isItemAdded = addedItems[itemName] ?? false;
                          int itemQuantity = itemQuantities[itemName] ?? 1;

                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 6, right: 6),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD11559),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 95,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(fetchedItemImage),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itemName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'Price: Rs. ${fetchedItemPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            itemData?['description'] ??
                                                'Description',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setItemState(() {
                                                    if (itemQuantity > 1) {
                                                      itemQuantities[itemName] =
                                                          itemQuantity - 1;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text(
                                                '${itemQuantities[itemName]}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  setItemState(() {
                                                    itemQuantities[itemName] =
                                                        itemQuantity + 1;
                                                  });
                                                },
                                              ),
                                              const Spacer(),
                                              // ElevatedButton(
                                              //   style: ElevatedButton.styleFrom(
                                              //     backgroundColor:
                                              //     Colors.white,
                                              //     foregroundColor: Colors.red,
                                              //   ),
                                              //   onPressed: () async {
                                              //     bool success =
                                              //     await addToCart(
                                              //         itemName,
                                              //         fetchedItemPrice,
                                              //         fetchedItemImage,
                                              //         itemQuantities[
                                              //         itemName]!);
                                              //     if (success) {
                                              //       setItemState(() {
                                              //         addedItems[itemName] =
                                              //         true;
                                              //       });
                                              //     }
                                              //   },
                                              //   child: isItemAdded
                                              //       ? const Row(
                                              //     mainAxisSize:
                                              //     MainAxisSize.min,
                                              //     children: [
                                              //       Text('Added',
                                              //           style: TextStyle(
                                              //               color: Colors
                                              //                   .red)),
                                              //       SizedBox(width: 5),
                                              //       Icon(Icons.check,
                                              //           color:
                                              //           Colors.red),
                                              //     ],
                                              //   )
                                              //       : const Text('Add to Cart',
                                              //       style: TextStyle(
                                              //           color: Colors.red)),
                                              // ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 18.0), // Adjust the padding as needed
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    bool success = await addToCart(
                                                        itemName,
                                                        fetchedItemPrice,
                                                        fetchedItemImage,
                                                        itemQuantities[itemName]!);
                                                    if (success) {
                                                      setItemState(() {
                                                        addedItems[itemName] = true;
                                                      });
                                                    }
                                                  },
                                                  child: isItemAdded
                                                      ? const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text('Added', style: TextStyle(color: Colors.red,fontSize: 14)),
                                                      SizedBox(width: 5),
                                                      Icon(Icons.check, color: Colors.red),
                                                    ],
                                                  )
                                                      : const Text('Add to Cart', style: TextStyle(color: Colors.red,fontSize: 14)),
                                                ),
                                              )

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to fetch restaurant data
  Future<DocumentSnapshot> fetchRestaurantData() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .where('username', isEqualTo: widget.restaurantName)
        .where('address', isEqualTo: widget.restaurantAddress)
        .limit(1) // Limit to 1 because we expect only one match
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    } else {
      throw Exception('Restaurant not found');
    }
  }

  // Method to fetch items data
  Future<QuerySnapshot> fetchItemsData() async {
    return await FirebaseFirestore.instance
        .collection('restaurantAdmins') // Collection containing restaurant documents
        .where('restaurantName', isEqualTo: widget.restaurantName) // Filter to match restaurantName
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var restaurantDoc = querySnapshot.docs.first;
        return FirebaseFirestore.instance
            .collection('restaurantAdmins')
            .doc(restaurantDoc.id) // Use the ID of the restaurant document
            .collection('items') // Subcollection named 'items' under the restaurant document
            .where('availability', isEqualTo: true) // Filter items with availability set to true
            .get();
      }
      else {
        throw 'No restaurant found with name ${widget.restaurantName}';
      }
    });
  }
}

