
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/screens/Restaurant/RAddItemView.dart';
import 'package:paraiso/screens/Restaurant/REditItemView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/local_storage/shared_preferences_helper.dart';

import 'package:intl/intl.dart';


class RMenuView extends StatefulWidget {
  const RMenuView({super.key});

  @override
  _RMenuViewState createState() => _RMenuViewState();
}

class _RMenuViewState extends State<RMenuView> {
  late Future<String?> _fetchEmailFuture;
  String? _restaurantEmail;

  @override
  void initState() {
    super.initState();
    _fetchEmailFuture = _fetchEmail();
  }

  Future<String?> _fetchEmail() async {
    String? email = SharedPreferencesHelper.getResEmail();
    setState(() {
      _restaurantEmail = email;
    });
    return email;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD11559), // Background color for the app bar
        automaticallyImplyLeading: false, // To use a custom back button
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
              'Menu',
              style: TextStyle(
                fontFamily: 'Recoleta',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 23.sp,
              ),
            ),
            const Spacer(),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.h),
            Expanded(
              child: FutureBuilder<String?>(
                future: _fetchEmailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Restaurant email not found'));
                  } else {
                    _restaurantEmail = snapshot.data;
                    return _buildMenuItems(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RAddItemView()));
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFD11559),
        elevation: 0.0,
        child: const Icon(Icons.add),
      ),
    );

  }

  Widget _buildMenuItems(BuildContext context) {
    if (_restaurantEmail == null) {
      return const Center(child: Text('Restaurant email not available'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('restaurantAdmins').where('email', isEqualTo: _restaurantEmail).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No menu items available'));
        }

        final items = snapshot.data!.docs.first.reference.collection('items').snapshots();

        return StreamBuilder<QuerySnapshot>(
          stream: items,
          builder: (context, itemSnapshot) {
            if (itemSnapshot.hasError) {
              return Center(child: Text('Error: ${itemSnapshot.error}'));
            }

            if (itemSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!itemSnapshot.hasData || itemSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No menu items available'));
            }

            return ListView.builder(
              itemCount: itemSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final product = itemSnapshot.data!.docs[index];
                return _buildMenuItemCard(context, product);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItemCard(BuildContext context, DocumentSnapshot product) {
    final itemData = product.data() as Map<String, dynamic>;
    final formatter = DateFormat.yMMMMd().add_jm();
    final lastUpdated = itemData['lastUpdated'] != null ? (itemData['lastUpdated'] as Timestamp).toDate() : DateTime.now();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => REditItemView(product: itemData),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: const Color(0xFFD11559),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.white54,
              backgroundImage: NetworkImage(itemData['image'] ?? ''),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemData['name'] ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Rs. ${itemData['price']?.toStringAsFixed(1) ?? ''}',
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    itemData['description'] ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Available: ${itemData['availability'] == true ? 'Yes' : 'No'}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Last Updated: ${formatter.format(lastUpdated)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => _deleteProduct(context, product),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                      ),
                      SizedBox(width: 4.w),
                      IconButton(
                        onPressed: () => _deleteProduct(context, product),
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                      ),
                      SizedBox(width: 5.w),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => REditItemView(product: itemData),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        color: const Color(0xFFD11559),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(BuildContext context, DocumentSnapshot product) async {
    final itemsSubcollection = product.reference.parent;
    final itemName = product['name'];

    itemsSubcollection.where('name', isEqualTo: itemName).get().then((subcollectionSnapshot) {
      for (var itemDocument in subcollectionSnapshot.docs) {
        itemDocument.reference.delete().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete item')),
          );
        });
      }
    });
  }
}
