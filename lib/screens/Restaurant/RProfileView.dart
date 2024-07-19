import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nawalah/controllers/Restaurants/res_auth_controller.dart';
import 'package:nawalah/models/restaurant_admin_model.dart';
import 'package:nawalah/util/theme/theme_constants.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../controllers/profile_pic_controller.dart';
import '../../util/image_source.dart';
import '../../util/local_storage/shared_preferences_helper.dart';
import '../../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ResProfileController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      emailValid.value = false;
      return 'Please enter an email';
    }
    if (!GetUtils.isEmail(value)) {
      emailValid.value = false;
      return 'Please enter a valid email';
    }
    emailValid.value = true;
    return null;
  }

  String? textValidator(String? value) {
    if (value!.isEmpty) {
      return "Can't be Empty!";
    }
    return null;
  }

  Future<void> getCurrentUser(RestaurantAdmin admin) async {
    _emailController.text = admin.email;
    _nameController.text = admin.username;
    _addressController.text = admin.address;
    _openingTimeController.text = admin.openingHrs;
  }

  Future<void> updateRestaurantProfile(Map<String, dynamic> data) async {
    String? email = await SharedPreferencesHelper.getResEmail();
    if (email != null && email.isNotEmpty) {
      var collection = FirebaseFirestore.instance.collection('restaurantAdmins');
      var query = collection.where('email', isEqualTo: email);
      var snapshot = await query.get();
      for (var doc in snapshot.docs) {
        if (data['logo'] == null) {
          // If logo is not updated, fetch current logo
          var currentData = doc.data();
          data['logo'] = currentData['logo'];
        }
        await doc.reference.update(data);
      }
    }
  }
}


class RProfileView extends StatefulWidget {
  const RProfileView({Key? key}) : super(key: key);

  @override
  State<RProfileView> createState() => _RProfileViewState();
}

class _RProfileViewState extends State<RProfileView> {
  final ResProfileController resProfileController = Get.put(ResProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String photo = '';
  String address = '';
  String openingTime = '';
  String openingTime1 = '';
  String closingTime = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchEmailAndLoadProfile();
  }

  Future<void> fetchEmailAndLoadProfile() async {
    String? email = await SharedPreferencesHelper.getResEmail();
    print(email);

    if (email != null && email.isNotEmpty) {
      final authController = Provider.of<AuthController>(context, listen: false);
      var collection = FirebaseFirestore.instance.collection('restaurantAdmins');
      var query = collection.where('email', isEqualTo: email);
      var snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        var data = doc.data();
        setState(() {
          name = data['username'] ?? "";
          email = email!;
          address = data['address'] ?? "";
          openingTime1 = data['openingHrs'].split("-")[0] ?? "";
          closingTime = data['openingHrs'].split("-")[1] ?? "";
          photo = data['logo'] ??
              "https://static.vecteezy.com/system/resources/previews/002/285/943/original/food-service-logo-design-template-free-vector.jpg";
        });
        resProfileController.getCurrentUser(RestaurantAdmin.fromMap(data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    openingTime = "$openingTime1-$closingTime";

    final profilePicController = Provider.of<ProfilePicController>(context);

    void selectAndUploadImage() async {
      final imageSource = await ImageSourcePicker.showImageSource(context);
      if (imageSource != null) {
        final file = await ImageSourcePicker.pickFile(imageSource);
        if (file != null) {
          await profilePicController.uploadImageToFirebase(file);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD11569),
        leading: IconButton(
          icon: Container(
            height: 53.h,
            width: 53.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            padding: EdgeInsets.only(left: 10.w),
            child: const Icon(Icons.arrow_back_ios),
          ),
          onPressed: () async {
            await profilePicController.setImageUrlNull();
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'Profile',
            style: TextStyle(
              color: const Color(0xFFE4E4E4),
              fontSize: 25.sp,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          const SizedBox(width: 44), // Adjusted for spacing
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            onChanged: () {
              _formKey.currentState!.validate();
            },
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: context.height,
                      width: context.width * .8767,
                      child: ListView(
                        children: [
                          const SizedBox(height: 65), // Adjusted for spacing
                          Container(
                            width: 150.r,
                            height: 150.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: profilePicController.imageUrl != null
                                    ? NetworkImage(profilePicController.imageUrl!)
                                    : NetworkImage(photo),
                              ),
                            ),
                            child: ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: selectAndUploadImage,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 35), // Adjusted for spacing
                          TextFormField(
                            enabled: false,
                            controller: resProfileController._emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),

                            ),
                            style: TextStyle(color: Colors.black),
                            validator: resProfileController.emailValidator,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15), // Adjusted for spacing
                          TextFormField(
                            controller: resProfileController._nameController,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: resProfileController.textValidator,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 15), // Adjusted for spacing
                          TextFormField(
                            controller: resProfileController._addressController,
                            decoration: InputDecoration(
                              hintText: 'Address',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: resProfileController.textValidator,
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 15), // Adjusted for spacing
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    setState(() {
                                      openingTime1 = value!.format(context);
                                    });
                                  });
                                },
                                child: Container(
                                  height: 50.h,
                                  width: 185.w,
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Opens: ${openingTime1 == "" ? "select" : openingTime1}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.timer,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    setState(() {
                                      closingTime = value!.format(context);
                                    });
                                  });
                                },
                                child: Container(
                                  height: 50.h,
                                  width: 185.w,
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Closes: ${closingTime == "" ? "select" : closingTime}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.timer,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35), // Adjusted for spacing
                          DefaultButton(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                Map<String, dynamic> updatedData = {};
                                if (profilePicController.imageUrl != photo) {
                                  updatedData['logo'] = profilePicController.imageUrl;
                                }
                                if (resProfileController._nameController.text != name) {
                                  updatedData['username'] = resProfileController._nameController.text;
                                  updatedData['restaurantName'] = resProfileController._nameController.text;
                                }
                                if (resProfileController._addressController.text != address) {
                                  updatedData['address'] = resProfileController._addressController.text;
                                }
                                if (openingTime != "$openingTime1-$closingTime") {
                                  updatedData['openingHrs'] = "$openingTime1-$closingTime";
                                }

                                await resProfileController.updateRestaurantProfile(updatedData);
                                Navigator.pop(context);
                              }
                            },
                            text: "Update Profile",
                            width: context.width,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double width;

  const DefaultButton({
    Key? key,
    required this.onTap,
    required this.text,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: const Color(0xFFD11569),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}