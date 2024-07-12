

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_switch/flutter_switch.dart';

class REditItemView extends StatefulWidget {
  final Map<String, dynamic> product;
  const REditItemView({super.key, required this.product});

  @override
  State<REditItemView> createState() => _REditItemViewState();
}

class _REditItemViewState extends State<REditItemView> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  bool _availability = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController = TextEditingController(text: widget.product['description']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _availability = widget.product['availability'] ?? false;
  }

  Future<void> _updateProduct() async {
    String? email = await SharedPreferences.getInstance().then((prefs) => prefs.getString('restaurant_email'));
    final itemName = widget.product['name'];
    final itemsRef = FirebaseFirestore.instance.collection('restaurantAdmins');

    itemsRef.where('email', isEqualTo: email).get().then((querySnapshot) {
      for (var document in querySnapshot.docs) {
        final itemsSubcollection = document.reference.collection('items');
        itemsSubcollection.where('name', isEqualTo: itemName).get().then((subcollectionSnapshot) {
          for (var itemDocument in subcollectionSnapshot.docs) {
            itemDocument.reference.update({
              'name': _nameController.text.isNotEmpty ? _nameController.text : widget.product['name'],
              'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : widget.product['description'],
              'price': _priceController.text.isNotEmpty ? double.parse(_priceController.text) : widget.product['price'],
              'availability': _availability,
              'lastUpdated': FieldValue.serverTimestamp(),
            }).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Update Successful!")),
              );
              Navigator.pop(context);
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Update error!")),
              );
            });
          }
        });
      }
    });
  }



  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD11559),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50.h,
                width: 50.w,
                margin: EdgeInsets.only(right: 5.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD11559),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Edit Item',
              style: TextStyle(
                fontFamily: 'Recoleta',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 23.sp,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 30.h),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Description',
                        labelStyle: const TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 30.h),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Price',
                        labelStyle: const TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 30.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Availability',
                            style: TextStyle(color: Colors.black, fontSize: 18.sp),
                          ),
                          FlutterSwitch(
                            value: _availability,
                            onToggle: (value) {
                              setState(() {
                                _availability = value;
                              });
                            },
                            toggleColor: const Color(0xFFD11559),
                            toggleSize: 30.0,
                            borderRadius: 30.0,
                            padding: 8.0,
                            showOnOff: false,
                            activeText: 'On',
                            inactiveText: 'Off',
                            activeTextColor: Colors.white,
                            inactiveTextColor: Colors.white,
                            activeToggleColor: Colors.white,
                            inactiveToggleColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 200.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD11559),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontFamily: 'Recoleta',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

