
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../controllers/customer_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/sort_by_distance_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../repositories/customer_firebase_calls.dart';
import '../util/location/user_location.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:paraiso/widgets/normal_appbar.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formattedText = StringBuffer();

    if (text.isNotEmpty) {
      formattedText.write('+92 ');
      if (text.length > 2) {
        formattedText.write(text.substring(2, 6));
        formattedText.write(' ');
      } else if (text.length > 1) {
        formattedText.write(text.substring(1));
      }

      if (text.length > 6) {
        formattedText.write(text.substring(6));
      }
    }

    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class CreateProfilePhone extends StatefulWidget {
  const CreateProfilePhone({super.key});

  @override
  State<CreateProfilePhone> createState() => _CreateProfilePhoneState();
}

class _CreateProfilePhoneState extends State<CreateProfilePhone> {
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ProfileController profileController = Get.put(ProfileController());
  bool isAuthenticating = false;
  bool restaurantsLookUp = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F7),
      appBar: const NormalAppbar(),
      body: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState!.validate();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)],
            ),
          ),
          child: SafeArea(
          child: ListView(
            children: [
              34.verticalSpace,
              ProgressBar(
                width: 1.sw,
                value: 4 / 5,
                height: 5.h,
                backgroundColor: onNeutralColor,
                color: const Color(0xFFD11559),
              ),
              93.verticalSpace,
              Center(
                child: SizedBox(
                  width: 326,
                  height: 68,
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.gotchaNextWhatsYourPhoneNumber,
                    textAlign: TextAlign.center,
                    style: context.headlineLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Recoleta',
                      color: Colors.black,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              31.verticalSpace,
              Center(
                child: SizedBox(
                  width: 293.w,
                  height: 55.h,
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.thisIsSoYouCanVerifyYourAccount,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.black,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              31.verticalSpace,
              Center(
                child: SvgTextField(
                  hintText: "+92 300 0000000",
                  backgroundColor: Colors.white,
                  color: Colors.black,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD11559)), // Example focused border
                  ),
                  controller: phoneController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber;
                    }
                    return null;
                  },
                  textInputFormatter: [
                    LengthLimitingTextInputFormatter(15),
                    MaskTextInputFormatter(mask: "+92 ### #######")
                  ],
                  prefixIcon: "assets/images/Create Account(phone num)_Call_248_3459.svg",
                  textInputType: TextInputType.phone,
                ),
              ),
              40.verticalSpace,
              Center(
                child: PrimaryButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Get.find<ProfileController>().phone = phoneController.text;
                      setState(() {
                        isAuthenticating = true;
                      });

                      try {
                        final myData = Get.find<ProfileController>();
                        final myLocation = await UserLocation().requestLocationPermission();
                        final customerAuth = CustomerAuthRep();
                        print(myData.email);
                        print(myData.name);
                        print(myData.password);
                        print(myData.phone);
                        final result = await customerAuth.signUp(
                          email: myData.email,
                          password: myData.password,
                          name: myData.name,
                          phoneNumber: myData.phone,
                          position: myLocation,
                          rewards: 0,
                        );
                        print('user added');
                        if (result == "User added") {
                          setState(() {
                            isAuthenticating = false;
                            restaurantsLookUp = true;
                          });
                          if (mounted) {
                           //// print("jk");
                            //final resByDist = Provider.of<SortByDistanceController>(context, listen: false);
                            final currentUserController = Provider.of<CustomerController>(context, listen: false);
                            //final restController = Provider.of<RestaurantsWithDiscountController>(context, listen: false);
                            //print("jk2");

                            //await MyCustomerCalls().fetchAndSaveNearbyRestaurants();
                            print("jk3");

                            await currentUserController.getCurrentUser();

                          }
                          setState(() {
                            restaurantsLookUp = false;
                          });
                          if (mounted){ context.go(AppRouteConstants.homeRoute);
                          // print("jku");
                          }
                        } else {
                          //throw Exception(result);
                          throw Exception(result);
                        }
                      } catch (e) {
                        setState(() {
                          isAuthenticating = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFD11559),
                            content: Center(
                              child: Text(
                                e.toString(),
                                style: context.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontFamily: 'Recoleta',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFD11559),
                          content: Center(
                            child: Text(
                              AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  icon: isAuthenticating || restaurantsLookUp ? null : Icons.arrow_forward_ios_outlined,
                  color: const Color(0xFFD11559),
                  child: isAuthenticating
                      ? CircularProgressIndicator(
                    color: onPrimaryColor,
                  )
                      : restaurantsLookUp
                      ? AutoSizeText(
                    AppLocalizations.of(context)!.findingRestaurantsNearYou,
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 15.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                  )
                      : AutoSizeText(
                    AppLocalizations.of(context)!.continueText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),),
      ),
    );
  }
}
