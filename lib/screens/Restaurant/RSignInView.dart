import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controllers/Restaurants/res_auth_controller.dart';
import '../../controllers/location_controller.dart';
import '../../routes/routes_constants.dart';
import '../../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../forgotPassword.dart';

class RSignInView extends StatefulWidget {
  const RSignInView({super.key});

  @override
  _RSignInViewState createState() => _RSignInViewState();
}

class _RSignInViewState extends State<RSignInView> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool emailValid = false;
  bool rememberMe = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        emailValid = false;
      });
      return 'Please enter an email';
    }

    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      setState(() {
        emailValid = false;
      });
      return 'Please enter a valid email';
    }

    setState(() {
      emailValid = true;
    });

    return null;
  }

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter your password";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    // Add additional password validation logic
    return null;
  }

  void toggleRememberMe() {
    setState(() {
      rememberMe = !rememberMe;
    });
  }

  @override

  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final locationController = Provider.of<LocationProvider>(context, listen: false);
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
            key: formKey,
            onChanged: () {
              formKey.currentState!.validate();
            },
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width * .8767,
                      child: ListView(
                        children: [
                          128.verticalSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/paraiso_logo.png',
                                    height: 230.h,
                                    width: 230.w,
                                  ),
                                ],
                              ),
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
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          4.verticalSpace,
                          SizedBox(
                            width: 273.w,
                            height: 55.h,
                            child: AutoSizeText(
                              AppLocalizations.of(context)!.useYourCredentialsBelowAndLoginToYourAccount,
                              textAlign: TextAlign.center,
                              style: context.titleSmall?.copyWith(color: Colors.black),
                              maxLines: 2,
                            ),
                          ),
                          38.verticalSpace,
                          SvgTextField(
                            controller: _emailController,
                            hintText: AppLocalizations.of(context)!.enterYourEmail,
                            validator: emailValidator,
                            prefixIcon: "assets/images/email_icon.svg",
                            suffixIcon: emailValid
                                ? Transform.scale(
                              scale: .4,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: const Color(0xFFFFE5E5),
                                child: Icon(
                                  Icons.check,
                                  color: const Color(0xFF800000),
                                  size: 30.sp,
                                ),
                              ),
                            )
                                : null,
                            textInputType: TextInputType.emailAddress,
                            backgroundColor: Colors.white,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF800000)), // Example focused border
                            ),
                            textStyle: TextStyle(color: Colors.black, fontSize: 16.sp),
                            hintStyle: TextStyle(color: Colors.black, fontSize: 16.sp),
                          ),
                          18.verticalSpace,
                          SvgTextField(
                            controller: _passwordController,
                            hintText: AppLocalizations.of(context)!.enterYourPassword,
                            validator: passwordValidator,
                            prefixIcon: "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                            isPasswordField: true,
                            textInputType: TextInputType.emailAddress,
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF800000)), // Red border when focused
                            ),
                          ),
                          15.verticalSpace,
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .8767,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      value: rememberMe,
                                      onChanged: (bool? value) {
                                        toggleRememberMe();
                                      },
                                      checkColor: const Color(0xFF800000),
                                      fillColor: WidgetStateProperty.all(const Color(0xFFFFE5E5)),
                                      activeColor: const Color(0xFFFFE5E5),
                                    ),
                                    14.w.horizontalSpace,
                                    Text(
                                      AppLocalizations.of(context)!.rememberMe,
                                      style: TextStyle(
                                        color: const Color(0xFF000000),
                                        fontSize: 15.sp,
                                        fontFamily: 'Recoleta',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPasswordScreen(userType: "restaurant"),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.forgotPassword,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: const Color(0xFF000000),
                                      fontSize: 15.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          53.verticalSpace,
                          Center(
                            child: PrimaryButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text.trim();

                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Color(0xFF800000),
                                        content: Text(
                                          'Please enter both email and password.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Recoleta',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await authController.signIn(email, password, rememberMe);
                                  await authController.signInAnonymously();

                                  if (mounted) {
                                    if (authController.user == null) {
                                      context.go(AppRouteConstants.restaurantHome);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Color(0xFFD11569),
                                          content: Center(
                                            child: Text(
                                              'Wrong credentials! Please Try again..',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Recoleta',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: authController.isLoading || locationController.isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : AutoSizeText(
                                AppLocalizations.of(context)!.logIntoYourAccount,
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
