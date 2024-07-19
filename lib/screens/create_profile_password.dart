import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/util/theme/theme.dart';
import 'package:nawalah/util/theme/theme_constants.dart';
import 'package:nawalah/widgets/normal_appbar.dart';
import 'package:nawalah/widgets/primary_button.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

import '../controllers/profile_controller.dart';
import '../routes/routes_constants.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateProfilePassword extends StatefulWidget {
  const CreateProfilePassword({super.key});

  @override
  State<CreateProfilePassword> createState() => _CreateProfilePasswordState();
}

class _CreateProfilePasswordState extends State<CreateProfilePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const NormalAppbar(),
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
          child: ListView(physics: const ClampingScrollPhysics(), children: [
            34.verticalSpace,
            ProgressBar(
              width: 1.sw,
              value: 3 / 5,
              height: 5.h,
              backgroundColor: onNeutralColor,
              color: const Color(0xFFD11569),
            ),
            93.verticalSpace,
            Center(
              child: SizedBox(
                width: 326,
                height: 68,
                child: AutoSizeText(
                  AppLocalizations.of(context)!.pleaseChooseAStrongPassword,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineLarge!.copyWith(
                    fontWeight: bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            31.verticalSpace,
            Center(
              child: SizedBox(
                width: 293.w,
                height: 55.h,
                child: AutoSizeText(
                  AppLocalizations.of(context)!.makeSureItsUniqueAtLeast8Characters,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.black,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
            38.verticalSpace,
            Center(
              child: SvgTextField(
                hintText: "examplePass123",
                backgroundColor: Colors.white,
                color:Colors.black,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD11569)), // Example focused border
                ),
                controller: _passwordController,
                validator: (value) {
                  // if (value!.isEmpty) {
                  //   return "Please enter your password";
                  // }
                  return null;
                },
                // lock
                prefixIcon: "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                isPasswordField: true,
              ),
            ),
            18.verticalSpace,
            Center(
              child: SvgTextField(
                //TODO: TRANSFORM
                hintText: "Confirm password",
                controller: _confirmPasswordController,
                validator: (value) {
                  // if (value!.isEmpty) {
                  //   return "Please confirm your password";
                  // }
                  return null;
                },
                prefixIcon: "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                isPasswordField: true,
                backgroundColor: Colors.white,
                color:Colors.black,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD11569)), // Example focused border
                ),
              ),
            ),
            41.verticalSpace,
            Center(

              child: PrimaryButton(
                onPressed: () {
                  // check if empty, show snackbar
                  if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFD11569),
                        content: Center(
                          child: Text(
                            AppLocalizations.of(context)!.passwordValidatorPleaseEnterYourPassword,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (_passwordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFD11569),
                        content: Center(
                          child: Text(
                            AppLocalizations.of(context)!.passwordValidatorPasswordMustBeAtLeast6Characters,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (_passwordController.text == _confirmPasswordController.text) {
                    Get.find<ProfileController>().password = _passwordController.text;
                    context.push(AppRouteConstants.createProfilePhone);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFD11569),
                        content: Center(
                          child: Text(
                            AppLocalizations.of(context)!.passwordsDoNotMatch,
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
                icon: Icons.arrow_forward_ios_outlined,
                color: const Color(0xFFD11569),
                child: AutoSizeText(
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
            //check if height of viewport 1.vh is smaller than 500
            ScreenUtil().scaleHeight < 1 ? 83.h.verticalSpace : 163.h.verticalSpace,
          ]),
        ),
      ),),
    );
  }
}
