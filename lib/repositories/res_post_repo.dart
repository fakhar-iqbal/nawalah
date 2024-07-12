import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/nearby_restaurants.dart';
import '../models/order_model.dart';
import '../models/restaurant_admin_model.dart';
import '../util/local_storage/shared_preferences_helper.dart';

class RestaurantPostRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GET NEARBY RESTAURANTS from firebase
  Future<List<NearbyRestaurants>> getNearbyRestaurants(String email) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('email', isEqualTo: email)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData =
            snap.docs[0];

        final CollectionReference<Map<String, dynamic>> restaurantsRef =
            restaurantAdminData.reference.collection('restaurants');

        final QuerySnapshot<Map<String, dynamic>> restaurantsSnap =
            await restaurantsRef.get();

        final List<NearbyRestaurants> restaurantsList = restaurantsSnap.docs
            .map((restaurantDoc) =>
                NearbyRestaurants.fromMap(restaurantDoc.data()))
            .toList();

        return restaurantsList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch nearby restaurants: $e');
    }
  }

  Future<void> toggleRestaurantFavorite(
      String restaurantId, bool isFavorite) async {
    try {
      final email = SharedPreferencesHelper.getCustomerEmail();
      final userDocRef = _firestore.collection("clients").doc(email);
      final currentUserDocument = await userDocRef.get();

      final List<String> favorites =
          List<String>.from(currentUserDocument.data()?["favorites"] ?? []);

      if (!isFavorite) {
        if (!favorites.contains(restaurantId)) {
          favorites.add(restaurantId);
          await userDocRef.update({'favorites': favorites});
        }
      } else {
        if (favorites.contains(restaurantId)) {
          favorites.remove(restaurantId);
          await userDocRef.update({'favorites': favorites});
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle restaurant favorite: $e');
    }
  }

  Future<bool> isRestaurantFavorite(String restaurantId) async {
    try {
      final email = SharedPreferencesHelper.getCustomerEmail();
      final userDocRef = _firestore.collection("clients").doc(email);
      final currentUserDocument = await userDocRef.get();

      final List<String> favorites =
          List<String>.from(currentUserDocument.data()?["favorites"] ?? []);

      return favorites.contains(restaurantId);
    } catch (e) {
      throw Exception('Failed to check if restaurant is a favorite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRestaurantsWithDiscounts(
      RestaurantAdmin admin) async {
    final restaurantAdminsCollection =
        _firestore.collection('restaurantAdmins');
    final List<Map<String, dynamic>> restaurants = [];

    try {
      final currentRestaurantQuery = await restaurantAdminsCollection
          .where('userId', isEqualTo: admin.userId)
          .get();
      //
      // if (kDebugMode) print("111111");

      if (currentRestaurantQuery.docs.isNotEmpty) {
        // final currentRestaurantData = currentRestaurantQuery.docs.first.data();

        final restaurantAdminsQuery = await restaurantAdminsCollection.get();

        final nearbyRestaurants = await currentRestaurantQuery
            .docs.first.reference
            .collection("restaurants")
            .get();

        // if (kDebugMode) print("22222");
        // if (kDebugMode) print(nearbyRestaurants.docs.length);

        for (final restaurantDocument in nearbyRestaurants.docs) {
          final restaurantData = restaurantDocument.data();

          // if (kDebugMode) print("333333");
          // if (kDebugMode) print(restaurantData["email"]);

          // Find a matching main restaurant by email
          final matchingMainRestaurant =
              restaurantAdminsQuery.docs.firstWhereOrNull(
            (mainDoc) => mainDoc.data()['email'] == restaurantData['email'],
          );
          //
          // if (kDebugMode) print("44444444");
          // if (kDebugMode) print(matchingMainRestaurant?.data());

          final restaurantId = matchingMainRestaurant?.id;
          final restaurantName = matchingMainRestaurant?.data()['username'];
          final restaurantLogo = matchingMainRestaurant?.data()['logo'];
          //
          // if (kDebugMode) print("555555");

          final restaurantMenu =
              await matchingMainRestaurant?.reference.collection("items").get();

          if (restaurantMenu != null) {
            // if (kDebugMode) print(restaurantMenu.docs.length);
            //
            // if (kDebugMode) print("66666");

            for (final itemDocument in restaurantMenu.docs) {
              // if (kDebugMode) print("7777777");
              final itemData = itemDocument.data();

              if (itemData['discount'] != '0%' &&
                  itemData.containsKey("lastUpdated")) {
                // if (kDebugMode) print("8888888");
                restaurants.add({
                  'restaurantId': restaurantId,
                  'restaurantName': restaurantName,
                  'restaurantLogo': restaurantLogo,
                  'itemName': itemData['name'],
                  'discount': itemData['discount'],
                  'lastUpdated': itemData['lastUpdated'],
                });
              }
            }
          }
        }

        // Sort the restaurants by "lastUpdated" in descending order
        restaurants
            .sort((a, b) => b['lastUpdated'].compareTo(a['lastUpdated']));

        // if (kDebugMode) print("999999");

        return restaurants.take(10).toList();
      } else {
        // Handle the case when the current restaurant is not found
        return [];
      }
    } catch (error) {
      // if (kDebugMode) print(stk);
      // if (kDebugMode) print("10101010110");
      if (kDebugMode) print('Error fetching restaurants: $error');
      rethrow;
    }
  }

  // find nearby restaurants & save in firebase
  Future<void> fetchAndSaveNearbyRestaurants(RestaurantAdmin admin) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> restaurantAdminsSnap =
          await _firestore.collection('restaurantAdmins').get();

      final QuerySnapshot<Map<String, dynamic>> currentResUser =
          await _firestore
              .collection('restaurantAdmins')
              .where('userId', isEqualTo: admin.userId)
              .get();

      final GeoPoint currentGeoPoint = GeoPoint(
        admin.location!.latitude,
        admin.location!.longitude,
      );

      final List<DocumentSnapshot<Map<String, dynamic>>>
          matchedRestaurants1000 = await searchRestaurantsWithinRadius(
              admin, restaurantAdminsSnap.docs, currentGeoPoint, 1000);

      if (matchedRestaurants1000.length < 10) {
        final List<DocumentSnapshot<Map<String, dynamic>>>
            matchedRestaurants10000 = await searchRestaurantsWithinRadius(
                admin, restaurantAdminsSnap.docs, currentGeoPoint, 10000);

        if (matchedRestaurants10000.length < 10) {
          final List<DocumentSnapshot<Map<String, dynamic>>>
              matchedRestaurants50000 = await searchRestaurantsWithinRadius(
                  admin, restaurantAdminsSnap.docs, currentGeoPoint, 50000);

          final List<DocumentSnapshot<Map<String, dynamic>>> allMatches = [
            ...matchedRestaurants1000,
            ...matchedRestaurants10000,
            ...matchedRestaurants50000,
          ];

          final Set<String> addedEmails = {};
          final List<DocumentSnapshot<Map<String, dynamic>>>
              deduplicatedMatches = deduplicateMatches(allMatches, addedEmails);

          addMatchesToSubcollection(deduplicatedMatches,
              currentResUser.docs[0].reference.collection('restaurants'));
        } else {
          addMatchesToSubcollection(matchedRestaurants10000,
              currentResUser.docs[0].reference.collection('restaurants'));
        }
      } else {
        addMatchesToSubcollection(matchedRestaurants1000,
            currentResUser.docs[0].reference.collection('restaurants'));
      }
    } catch (e) {
      throw Exception('Failed to fetch and save nearby restaurants: $e');
    }
  }

  // remove duplicates if any
  List<DocumentSnapshot<Map<String, dynamic>>> deduplicateMatches(
      List<DocumentSnapshot<Map<String, dynamic>>> matches,
      Set<String> addedEmails) {
    final List<DocumentSnapshot<Map<String, dynamic>>> deduplicatedMatches = [];

    for (final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData
        in matches) {
      final String email = restaurantAdminData["email"];
      if (!addedEmails.contains(email)) {
        deduplicatedMatches.add(restaurantAdminData);
        addedEmails.add(email);
      }
    }

    return deduplicatedMatches;
  }

  // search restaurants with in specified radius
  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      searchRestaurantsWithinRadius(
          RestaurantAdmin admin,
          List<DocumentSnapshot<Map<String, dynamic>>> restaurantAdmins,
          GeoPoint currentGeoPoint,
          double radius) async {
    final QuerySnapshot<Map<String, dynamic>> currentResUser = await _firestore
        .collection('restaurantAdmins')
        .where('userId', isEqualTo: admin.userId)
        .get();

    final QuerySnapshot<Map<String, dynamic>> nearbyRestaurants =
        await currentResUser.docs[0].reference.collection("restaurants").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> matches = [];

    for (final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData
        in restaurantAdmins) {
      final GeoPoint adminLocation =
          restaurantAdminData['location'] as GeoPoint;
      final double adminLatitude = adminLocation.latitude;
      final double adminLongitude = adminLocation.longitude;

      final double distance = Geolocator.distanceBetween(
        currentGeoPoint.latitude,
        currentGeoPoint.longitude,
        adminLatitude,
        adminLongitude,
      );

      if (distance <= radius) {
        final matching = filterDocsByMatchingEmail(
            nearbyRestaurants.docs, restaurantAdminData["email"]);
        if (matching.isEmpty && admin.email != restaurantAdminData["email"]) {
          restaurantAdminData.reference.update({"distance": distance});
          matches.add(restaurantAdminData);
        }
      }
    }
    return matches;
  }

  // add matched restaurants to subcollection
  void addMatchesToSubcollection(
      List<DocumentSnapshot<Map<String, dynamic>>> matches,
      CollectionReference<Map<String, dynamic>> subcollectionRef) {
    for (final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData
        in matches) {
      subcollectionRef.add({
        'name': restaurantAdminData['username'],
        'location': restaurantAdminData['location'],
        "distance": restaurantAdminData["distance"],
        "logo": restaurantAdminData["logo"],
        "email": restaurantAdminData["email"],
        "description": restaurantAdminData["description"],
      });
      // if (kDebugMode) print("doneeeeeeeeeeee");
    }
  }

  // check (by email) if the restaurant is already there in the sub collection
  List<DocumentSnapshot<Map<String, dynamic>>> filterDocsByMatchingEmail(
    List<DocumentSnapshot<Map<String, dynamic>>> documents,
    String emailToMatch,
  ) {
    return documents.where((doc) {
      final String? docEmail = doc.data()?['email'];
      return docEmail != null && docEmail == emailToMatch;
    }).toList();
  }

  Future<Map<String, dynamic>> getItemWithTopDiscount() async {
    Map<String, dynamic>? topDiscountItem;

    try {
      final QuerySnapshot<Map<String, dynamic>> restaurantSnap =
          await _firestore.collection('restaurantAdmins').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> restaurantDoc
          in restaurantSnap.docs) {
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final QuerySnapshot<Map<String, dynamic>> itemsSnap =
            await menuRef.get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> itemDoc
            in itemsSnap.docs) {
          final dynamic discountField = itemDoc.data()['discount'];
          final String discount = discountField ?? "0%";

          if (topDiscountItem == null ||
              _compareDiscounts(discount, topDiscountItem['discount'])) {
            topDiscountItem = {
              'itemId': itemDoc['itemId'],
              'itemName': itemDoc['name'],
              'discount': discount,
              'restaurantName': restaurantDoc['username'],
            };
          }
        }
      }
    } catch (e) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to retrieve item with top discount: $e');
    }

    return topDiscountItem ?? {};
  }

  bool _compareDiscounts(String discount1, String discount2) {
    final double percentage1 = double.tryParse(discount1.replaceAll('%', ''))!;
    final double percentage2 = double.tryParse(discount2.replaceAll('%', ''))!;

    return percentage1 > percentage2;
  }

  // MAKE ITEM FREE
  Future<void> makeItemFree(
      String userId, String itemId, Map<String, dynamic> giftItem) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final DateTime currentTime = DateTime.now();

        final QuerySnapshot<Map<String, dynamic>> itemQuery =
            await menuRef.where('itemId', isEqualTo: itemId).get();

        if (itemQuery.docs.isNotEmpty) {
          final DocumentReference<Map<String, dynamic>> itemDocRef =
              itemQuery.docs[0].reference;

          await itemDocRef.update({
            'free': giftItem,
            'lastUpdated': Timestamp.fromDate(currentTime),
          });
        }
      }
    } catch (e) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to update item discounts: $e');
    }
  }

  // REMOVE FREE ITEM
  Future<void> clearFreeItem(String userId, String itemId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final QuerySnapshot<Map<String, dynamic>> itemQuery =
            await menuRef.where('itemId', isEqualTo: itemId).get();

        if (itemQuery.docs.isNotEmpty) {
          final DocumentReference<Map<String, dynamic>> itemDocRef =
              itemQuery.docs[0].reference;

          Map<String, dynamic> data = {
            'free': FieldValue.delete(),
          };

          itemDocRef.update(data).then((_) {
            // if (kDebugMode) print("Field deleted successfully");
          }).catchError((error) {
            if (kDebugMode) print("Error deleting field: $error");
          });
        }
      }
    } catch (e) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to clear item discounts: $e');
    }
  }

  // GET CLIENTS BASED ON REWARDS SENT
  Future<List<Map<String, dynamic>>> getClientsWithSentRewards(
    String restaurantId,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> clientsSnapshot =
          await _firestore
              .collection('clients')
              .where('orderedFrom', arrayContains: restaurantId)
              .get();

      List<String> clientEmails = clientsSnapshot.docs.map((doc) {
        return doc.id;
      }).toList();

      if (clientEmails.isNotEmpty) {
        final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
            await _firestore
                .collection('posts')
                .where('senderEmail', whereIn: clientEmails)
                .get();

        List<Map<String, dynamic>> postsList = postsSnapshot.docs.map((doc) {
          final Map<String, dynamic> postData = doc.data();
          return {
            'sentOn': postData['sentOn'],
            'senderEmail': postData['senderEmail'],
            'sentTo': postData['sentTo'],
            'photo': postData['photo'],
            'sender': postData['sender'],
            'type': postData['type'],
          };
        }).toList();

        postsList.sort((a, b) {
          return b['sentOn'].compareTo(a['sentOn']);
        });

        return postsList;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch clients with sent rewards: $e');
    }
  }

  // GET ALL ORDERS
  Future<List<OrderModel>> getOrdersForRestaurant(String restaurantId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      final List<OrderModel> orders = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromMap(data);
      }).toList();

      orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return orders;
    } catch (error) {
      throw Exception('Failed to fetch orders: $error');
    }
  }

  // UPDATE ORDER STATUS
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (error) {
      throw Exception('Failed to update order status: $error');
    }
  }

  // TOTAL SALES
  Future<double> calculateTotalOrderAmount(String resId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> orderDocs = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: resId)
          .get();

      final totalAmountList = orderDocs.docs
          .where((orderDoc) => orderDoc.data().containsKey('totalPrice'))
          .map((orderDoc) => (orderDoc.data()['totalPrice'] as num).toDouble())
          .toList();

      double totalAmount = totalAmountList.fold(0.0, (a, b) => a + b);

      return totalAmount;
    } catch (e) {
      if (kDebugMode) print('Error calculating total order amount: $e');
      return 0.0;
    }
  }

  bool checkDate(String dateString , String type){
    try {
      DateTime date = DateFormat("yyyy-MM-dd hh:mm a").parse(dateString);

      // Get today's date
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      // Check if the date is today
      if(type == "today"){
        return date.year == today.year && date.month == today.month && date.day == today.day;
      }
      else if(type == "weekly"){
        return date.isAfter(today.subtract(const Duration(days: 7)));
      }
      else if(type == "monthly"){
        return date.isAfter(today.subtract(const Duration(days: 30)));
      }
      else{
        return true;
      }
    } catch (e) {
      print("Error parsing the date: $e");
      return false; // Return false if there's an error parsing the date
    }
  }

  Future<double> calculateTotalOrder(String resId, String timeFrame) async {
    try {

      final QuerySnapshot<Map<String, dynamic>> orderDocs = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: resId)
          .get();

      final totalAmountList = orderDocs.docs
          .where((orderDoc) => orderDoc.data().containsKey('totalPrice'))
          .where((orderDoc) =>
               checkDate(orderDoc.data()['time'] , timeFrame))
          .map((orderDoc) => (orderDoc.data()['totalPrice'] as num).toDouble())
          .toList();

      double totalAmount = totalAmountList.fold(0.0, (a, b) => a + b);

      return totalAmount;
    } catch (e) {
      if (kDebugMode) print('Error calculating total order amount: $e');
      return 0.0;
    }
  }


// TOP SELLERS
  Future<List<Map<String, dynamic>>> findTopSalesRestaurants(int limit) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> restaurantDocs =
          await _firestore.collection('restaurantAdmins').get();

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> restaurants =
          restaurantDocs.docs;

      final List<Map<String, dynamic>> topRestaurants = [];

      final Map<String, double> restaurantSales = {};

      for (final restaurantDoc in restaurants) {
        final String restaurantId = restaurantDoc.id;

        final double totalSales = await calculateTotalOrderAmount(restaurantId);

        restaurantSales[restaurantId] = totalSales;
      }

      restaurants.sort(
          (a, b) => restaurantSales[b.id]!.compareTo(restaurantSales[a.id]!));

      for (final restaurantDoc in restaurants.take(limit)) {
        final data = restaurantDoc.data();
        final restaurantInfo = {
          'username': data['username'],
          'logo': data['logo'],
        };
        topRestaurants.add(restaurantInfo);
      }

      return topRestaurants;
    } catch (e) {
      if (kDebugMode) print('Error finding top sales restaurants: $e');
      return [];
    }
  }

  // NO. OF CLIENTS
  Future<int> fetchUserCount() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> clientsDocs =
          await _firestore.collection('clients').get();
      return clientsDocs.size;
    } catch (e) {
      return 0;
    }
  }

  // NO. OF CLIENTS
  Future<int> fetchClientCount(String restaurantId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('clients').get();

      final List<DocumentSnapshot<Map<String, dynamic>>> documentsWithoutField =
          querySnapshot.docs.where((docSnapshot) {
        final Map<String, dynamic> docData = docSnapshot.data();
        return docData.containsKey('orderedFrom') &&
            docData['orderedFrom'].contains(restaurantId);
      }).toList();

      // if (kDebugMode) print("______________________________________________");
      // if (kDebugMode) print(documentsWithoutField.length);

      return documentsWithoutField.length;
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      return 0;
    }
  }

  // CONNECTED WITH IN 1 KM

  Future<int> fetchUsersWithin1KM(RestaurantAdmin admin) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('clients').get();

      GeoPoint? resAddress = admin.location;
      List<DocumentSnapshot> documents = querySnapshot.docs;

      List<DocumentSnapshot> clientsWithin1KM = [];

      for (var document in documents) {
        Map<String, dynamic>? documentData =
            document.data() as Map<String, dynamic>?;
        GeoPoint? clientAddress = documentData?['location'];

        if (clientAddress != null && resAddress != null) {
          double distance = Geolocator.distanceBetween(
            resAddress.latitude,
            resAddress.longitude,
            clientAddress.latitude,
            clientAddress.longitude,
          );

          if (distance <= 1000) {
            clientsWithin1KM.add(document);
          }
        }
      }

      // Return the length of the list of clients within 1 km.
      return clientsWithin1KM.length;
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      return 0;
    }
  }

  Future uploadImageToFirebase({File? imgPath}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imgPath!);
    return uploadTask.then((TaskSnapshot storageTaskSnapshot) {
      return storageTaskSnapshot.ref.getDownloadURL();
    }, onError: (e) {
      throw Exception(e.toString());
    });
  }

  // UPDATE USER LOCATION
  Future<void> updateResLocation(
      String resId, double latitude, double longitude) async {
    try {
      final resDocRef = _firestore.collection('restaurantAdmins').doc(resId);
      final newLocation = GeoPoint(latitude, longitude);
      await resDocRef.update({'location': newLocation});
      // if (kDebugMode) print('Location updated successfully.');
    } catch (e) {
      if (kDebugMode) print('Error updating location: $e');
    }
  }


  Future<List<Map<String, dynamic>>> getTopUsersBySales(
      String restaurantId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> ordersSnapshot =
          await _firestore
              .collection('orders')
              .where('restaurantId', isEqualTo: restaurantId)
              .get();

      final Map<String, double> userSalesMap = {};

      for (var doc in ordersSnapshot.docs) {
        final String userId = doc['clientId'];
        final double totalPrice = doc['totalPrice'];

        if (userSalesMap.containsKey(userId)) {
          double currSales = userSalesMap[userId]!;
          userSalesMap[userId] = currSales + totalPrice;
        } else {
          userSalesMap[userId] = totalPrice;
        }
      }

      final sortedUsers = userSalesMap.keys.toList()
        ..sort((a, b) => userSalesMap[b]!.compareTo(userSalesMap[a]!));

      final topUsers = sortedUsers.take(5).toList();

      final usersData = await fetchUsersData(topUsers);

      return usersData;
    } catch (e) {
      throw Exception('Failed to fetch top users by sales with photos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsersData(
      List<String> userIds) async {
    try {
      final List<Map<String, dynamic>> usersData = [];

      for (var userId in userIds) {
        final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await _firestore.collection('clients').doc(userId).get();

        if (userSnapshot.exists) {
          final Map<String, dynamic> userData = userSnapshot.data()!;
          final String userName = userData['userName'];
          final String userPhoto = userData['photo'] ?? "";

          usersData.add({
            'userName': userName,
            'photo': userPhoto,
          });
        }
      }

      return usersData;
    } catch (e) {
      throw Exception('Failed to fetch user data with photos: $e');
    }
  }
}
