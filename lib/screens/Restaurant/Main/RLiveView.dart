
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../custom_drawer.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../../../util/local_storage/shared_preferences_helper.dart';



class RLiveView extends StatefulWidget {
  const RLiveView({super.key});

  @override
  State<RLiveView> createState() => _RLiveViewState();
}

class _RLiveViewState extends State<RLiveView> {
  final TextEditingController _donationController = TextEditingController();

  Future<void> _sendDonation() async {
    // Retrieve the current restaurant email
    String? email = SharedPreferencesHelper.getResEmail();
    print(email);

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to retrieve email')),
      );
      return;
    }

    try {
      // Get the Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query the restaurantAdmins collection to find the current restaurant
      final QuerySnapshot restaurantSnapshot = await firestore
          .collection('restaurantAdmins')
          .where('email', isEqualTo: email)
          .get();

      if (restaurantSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant not found')),
        );
        return;
      }

      final restaurantDoc = restaurantSnapshot.docs.first;
      final restaurantData = restaurantDoc.data() as Map<String, dynamic>;

      final String restaurantName = restaurantData['restaurantName'] ?? 'Unknown Restaurant';
      final String restaurantLocation = restaurantData['address'] ?? 'Unknown Location';
      final String description = _donationController.text;
      final String phoneNumber = restaurantData['phone'] ?? "not provided";

      // Create the donation data
      final Map<String, dynamic> donationData = {
        'restaurantName': restaurantName,
        'restaurantLocation': restaurantLocation,
        'description': description,
        'restaurantEmail': email,
        'timestamp': FieldValue.serverTimestamp(),
        'restaurantPhone': phoneNumber
      };

      // Send the donation data to Firestore
      await firestore.collection('donations').add(donationData);

      // Clear the text field
      _donationController.clear();



      // Show the thank you popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),

            ),
            title: const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 50,
            ),
            content: const Text(
              'Thank you for your donation!\nAn NGO will contact you soon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black,),
            ),
            actions: [
              TextButton(

                child: const Text('OK',style: TextStyle(fontSize: 15),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send donation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(scaffoldKey: scaffoldKey),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20.h),
            decoration: const BoxDecoration(
              color: Colors.pink,
            ),
            child: Text(
              "Donate to save the planet",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.sp),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    size: 80.sp,
                    color: Colors.pink,
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: TextField(
                        controller: _donationController,
                        style: TextStyle(color: Colors.black, fontSize: 16.sp),
                        textAlign: TextAlign.left,
                        maxLines: 8,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Describe your donation here...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  ElevatedButton(
                    onPressed: _sendDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD11559),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                    ),
                    child: Text(
                      'Donate',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _donationController.dispose();
    super.dispose();
  }
}