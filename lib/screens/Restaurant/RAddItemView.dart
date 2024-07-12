import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../util/local_storage/shared_preferences_helper.dart';

class RAddItemView extends StatefulWidget {
  const RAddItemView({super.key});

  @override
  _RAddItemViewState createState() => _RAddItemViewState();
}

class _RAddItemViewState extends State<RAddItemView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final bool _availability = true;
  late String _photoURL;

  @override
  void initState() {
    super.initState();
    _photoURL = ''; // Initial empty photo URL
  }

  Future<void> _addItem() async {
    String? email = SharedPreferencesHelper.getResEmail();
    final currentTime = DateTime.now();

    final itemsRef = FirebaseFirestore.instance.collection('restaurantAdmins');

    // Query to find the document with the matching email
    final querySnapshot = await itemsRef.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming email is unique and there is only one document with this email
      final doc = querySnapshot.docs.first;

      // Get the reference to the items subcollection
      final itemsSubcollectionRef = doc.reference.collection('items');

      // Add the new item to the items subcollection
      await itemsSubcollectionRef.add({
        'availability': _availability,
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : 'the best one in town',
        'image': _photoURL.isNotEmpty ? _photoURL : 'https://th.bing.com/th/id/OIP.QH6HjE9CQaYKWeEM9TI1-wHaE8?rs=1&pid=ImgDetMain',
        'name': _nameController.text.isNotEmpty ? _nameController.text : '',
        'price': _priceController.text.isNotEmpty ? double.parse(_priceController.text) : 0,
        'lastUpdated': Timestamp.fromDate(currentTime),
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add item')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching restaurant found')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photoURL = pickedFile.path;
      });
    }
  }

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
              'Add Item',
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink, width: 2.w),
                  ),
                  child: _photoURL.isEmpty
                      ? Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 50.sp,
                      color: Colors.white,
                    ),
                  )
                      : ClipOval(
                    child: Image.file(
                      File(_photoURL),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color:Colors.black),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(

                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color:Colors.black),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Price',
                  hintStyle: TextStyle(color: Colors.black, fontSize: 14.sp),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,

                  ),
                ),
                style: const TextStyle(color:Colors.black),
              ),
              SizedBox(height: 100.h),
              Center(
                child: MaterialButton(
                  onPressed: _addItem,
                  color: const Color(0xFFD11559),
                  textColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
