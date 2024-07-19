
import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/controllers/customer_controller.dart';
import 'package:nawalah/util/theme/theme.dart';
import 'package:nawalah/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/profile_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../routes/routes_constants.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import '../widgets/svgtextfield.dart';
import 'forgotPassword.dart';

class LoginFormController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;
  RxBool rememberMe = false.obs;

  void toggleRememberMe() {
    rememberMe.toggle();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter your password";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  void submitForm(BuildContext context) {

  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginFormController loginFormController =
  Get.put(LoginFormController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isAuthenticating = false;

  void signInAnonymously(Function callback) {
    FirebaseAuth.instance.signInAnonymously().then((value) {
      if (kDebugMode) print("User ID: ${value.user!.uid}");
      callback();
    });
  }

  EmailOTP myAuth = EmailOTP();

  @override
  Widget build(BuildContext context) {
    final customerController =
    Provider.of<CustomerController>(context, listen: false);

    return Scaffold(

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
                    child: ListView(children: [
                      12.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/paraiso_logo.png',
                            height: 240.h,
                            width: 240.w,
                          ),
                          // 9.horizontalSpace,
                          // Text(
                          //   "NAWALAH",
                          //   style: context.headlineLarge!.copyWith(
                          //     fontWeight: FontWeight.w700,
                          //     fontFamily: 'Recoleta',
                          //     color: Colors.black,
                          //   ),
                          // ),
                        ],
                      ),
                      88.verticalSpace,
                      SizedBox(
                        width: 208,
                        height: 39,
                        child: Text(
                          AppLocalizations.of(context)!.welcomeBack,
                          textAlign: TextAlign.center,
                          style: context.titleLarge!.copyWith(
                            fontWeight: bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      4.verticalSpace,
                      SizedBox(
                        width: 273.w,
                        height: 55.h,
                        child: AutoSizeText(
                          AppLocalizations.of(context)!
                              .useYourCredentialsBelowAndLoginToYourAccount,
                          textAlign: TextAlign.center,
                          style: context.titleSmall?.copyWith(color: Colors.black),
                          maxLines: 2,

                        ),
                      ),
                      38.verticalSpace,
                      Obx(() {
                        return SvgTextField(
                          hintText:
                          AppLocalizations.of(context)!.enterYourEmail,
                          controller: loginFormController._emailController,
                          validator: loginFormController.emailValidator,
                          prefixIcon: "assets/images/email_icon.svg",
                          suffixIcon: loginFormController.isEmailValid
                              ? Transform.scale(
                            scale: .4,
                            child: CircleAvatar(
                              radius: 15,
                              //backgroundColor: Colors.white,
                              backgroundColor:Colors.white,
                              child: Icon(
                                Icons.check,
                                color: const Color(0xFF800000),
                                size: 30.sp,
                              ),
                            ),

                          )
                              : null,
                          textInputType: TextInputType.emailAddress,
                          backgroundColor: Colors.white, // Light maroon shade
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF800000)), // Example focused border
                          ),
                          textStyle: TextStyle(color: Colors.black, fontSize: 15.sp),
                          hintStyle: TextStyle(color: Colors.black, fontSize: 15.sp),
                        );
                      }),
                      18.verticalSpace,
                      SvgTextField(
                        hintText:
                        AppLocalizations.of(context)!.enterYourPassword,
                        controller: loginFormController._passwordController,
                        validator: loginFormController.passwordValidator,
                        prefixIcon:
                        "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                        isPasswordField: true,
                        textInputType: TextInputType.emailAddress,
                        backgroundColor: Colors.white, // Light maroon shade
                        color: Colors.black,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF800000)), // Red border when focused
                        ),
                        // suffixIconColor: Color(0xFF800000), // Maroon color for eye icon
                      ),
                      15.verticalSpace,
                      SizedBox(
                        width: context.width * .8767,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const ForgotPasswordScreen()));
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .forgotPassword,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )),
                            ]),
                      ),
                      53.verticalSpace,
                      Center(
                        child: PrimaryButton(
                          onPressed: () async {
                            if (loginFormController
                                ._emailController.text.isEmpty ||
                                loginFormController
                                    ._passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF800000),
                                  content: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .pleaseFillInAllFields,
                                      style: context.titleMedium?.copyWith(color: Colors.white,
                                        fontFamily: 'Recoleta',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),

                                ),

                              );
                            } else {
                              setState(() {
                                isAuthenticating = true;
                              });
                              final customerAuth = CustomerAuthRep();
                              final result = await customerAuth.signIn(
                                loginFormController._emailController.text,
                                loginFormController._passwordController.text,
                              );
                              if (result == "Login successful") {
                                await SharedPreferencesHelper.saveCustomerEmail(
                                    loginFormController._emailController.text);
                                await customerController.getCurrentUser();
                                if (kDebugMode) print("loginuserrrrrrrrrr");
                                if (kDebugMode) print(customerController.user);
                                SharedPreferencesHelper.saveCustomerType(
                                    'user');
                                setState(() {
                                  isAuthenticating = false;
                                });
                                loginFormController._emailController.clear();
                                loginFormController._passwordController.clear();
                                if (mounted) {
                                  context.go(AppRouteConstants.homeRoute);
                                }
                              } else {
                                setState(() {
                                  isAuthenticating = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF800000),
                                    content: Center(
                                      child: Text(
                                        result,
                                        style: context.titleMedium?.copyWith(color: Colors.white,
                                          fontFamily: 'Recoleta',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),

                                  ),
                                );
                              }
                            }
                          },
                          backgroundColor: const Color(0xFF800000),
                          child: isAuthenticating
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : AutoSizeText(
                            AppLocalizations.of(context)!
                                .logIntoYourAccount,
                            style: TextStyle(
                              color: Colors.white, // White text in button
                              fontSize: 18.sp,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                          ), // Maroon button color
                        ),
                      ),
                      ScreenUtil().scaleHeight < 1
                          ? 83.h.verticalSpace
                          : 163.h.verticalSpace,
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                              '${AppLocalizations.of(context)!.dontHaveAnAccount} ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.signUpHere,
                              style: const TextStyle(
                                color: Color(0xFF800000),
                                fontSize: 15,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ).onTap(
                            () {
                          context.push(AppRouteConstants.createProfileName);
                        },
                      ).paddingOnly(bottom: 5.h),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),),
    );
  }
}
