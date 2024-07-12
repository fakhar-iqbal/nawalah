import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/restaurant_admin_model.dart';
import '../util/local_storage/shared_preferences_helper.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      User? user = userCredential.user;
      if (user != null) return user;
      return null;
    } catch (e) {
      return null;
    }
  }



  Future<RestaurantAdmin?> signInUserWithEmailAndPassword({required String email, required String password}) async {
    const customSalt = '\$2a\$10\$CwTycUXWue0Thq9StjUM0u';
    final hash = BCrypt.hashpw(password, customSalt);
    print(hash);
    try {
      if (await checkIfUserEmailExistsAndPassword(email, hash)) {
        RestaurantAdmin admin = await retriveUserByEmailId(email);
        return admin;
      } else {
        return null;
      }
    } on FirebaseException {
      return null;
    }
  }

  Future<bool> checkIfUserEmailExistsAndPassword(String email, String password) async {
    try {
      final result = await _firestore.collection('restaurantAdmins').where('email', isEqualTo: email).where('password', isEqualTo: password).get();
      if (result.size == 1) {
        return true;
      }
      return false;
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> checkIfUserEmailExists(String email) async {
    try {
      final result = await _firestore.collection('Webusers').where('email', isEqualTo: email).get();
      if (result.size == 1) {
        return false;
      }
      return true;
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }

  Future<RestaurantAdmin> retriveUserByEmailId(String email) async {
    final snap = await _firestore.collection('restaurantAdmins').where('email', isEqualTo: email).get();
    DocumentSnapshot snapshot = snap.docs.first;
    RestaurantAdmin restaurantAdmin = RestaurantAdmin.fromMap(snapshot.data() as Map<String, dynamic>);
    return restaurantAdmin;
  }

  Future<RestaurantAdmin> retriveUserFromFirebase({String? userId}) async {
    try {
      final snap = await _firestore.collection("restaurantAdmins").doc(userId!).get();
      RestaurantAdmin restaurantAdmin = RestaurantAdmin.fromMap(snap.data() as Map<String, dynamic>);
      return restaurantAdmin;
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }

  Future<RestaurantAdmin> updateRestaurant(String userId, Map<String, dynamic> data) async {
    final snap = _firestore.collection("restaurantAdmins").doc(userId);
    final resDoc = await snap.get();

    if (resDoc.exists) {
      await snap.update(data);
    }
    return retriveUserFromFirebase(userId: userId);
  }

  Future logout() async {
    await _firebaseAuth.signOut();
  }

  Future<bool> deleteRestaurant() async {
    try {
      String? resEmail = SharedPreferencesHelper.getResEmail();
      QuerySnapshot resDocSnapshotQuery = await _firestore.collection('restaurantAdmins').where("email", isEqualTo: resEmail).get();
      final resDocSnapshot = resDocSnapshotQuery.docs.first;
      QuerySnapshot nearbyRestaurants = await resDocSnapshot.reference.collection('restaurants').get();
      QuerySnapshot items = await resDocSnapshot.reference.collection('items').get();
      if (resDocSnapshot.exists) {
        for (QueryDocumentSnapshot restaurant in nearbyRestaurants.docs) {
          await restaurant.reference.delete();
        }
        for (QueryDocumentSnapshot item in items.docs) {
          await item.reference.delete();
        }
        await resDocSnapshotQuery.docs.first.reference.delete();
        if (kDebugMode) print('User and corresponding document deleted successfully.');
      } else {
        if (kDebugMode) print('User document not found in Firestore.');
      }
      return true;
    } catch (error) {
      if (kDebugMode) print('Error deleting user and document: $error');
      return false;
    }
  }
}
