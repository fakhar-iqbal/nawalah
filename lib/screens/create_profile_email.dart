import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/routes/routes_constants.dart';
import 'package:nawalah/util/theme/theme.dart';
import 'package:nawalah/util/theme/theme_constants.dart';
import 'package:nawalah/widgets/normal_appbar.dart';
import 'package:nawalah/widgets/primary_button.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

import '../controllers/profile_controller.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileEmailController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;

  final TextEditingController _emailController = TextEditingController();

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      emailValid.value = false;
      return 'Please enter an email';
    }

    if (!GetUtils.isEmail(value)) {
      emailValid.value = false;
      return 'Please enter a valid email';
    }
    // Add additional email validation logic
    emailValid.value = true;
    return null;
  }

  void submitForm() {
    //TODO uncomment this
    // if (formKey.currentState!.validate()) {
    //   // Validation successful, proceed with form submission
    //   _emailController.clear();
    //   _passwordController.clear();
    // } else {
    //   // Validation failed, handle invalid form data
    // }
  }
}

class CreateProfileEmail extends StatefulWidget {
  const CreateProfileEmail({super.key});

  @override
  State<CreateProfileEmail> createState() => _CreateProfileEmailState();
}

class _CreateProfileEmailState extends State<CreateProfileEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfileEmailController profileEmailController = Get.put(ProfileEmailController());

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
                value: 2 / 5,
                height: 5.h,
                backgroundColor: onNeutralColor,
                color: const Color(0xFFD11569),

              ),
              130.verticalSpace,
              Center(
                child: SizedBox(
                  width: 326,
                  height: 68,
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.niceToMeetYouWhatsYourEmail,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge!.copyWith(
                      fontWeight: bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              12.verticalSpace,
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
              38.verticalSpace,
              Center(
                child: Obx(() => SvgTextField(
                      hintText: "example@gmailcom",
                      controller: profileEmailController._emailController,
                      validator: profileEmailController.emailValidator,
                      prefixIcon: "assets/images/email_icon.svg",
                      suffixIcon: profileEmailController.isEmailValid
                          // ? const SizedIcons(
                          //     svgPath: "assets/images/icon_checkmark.svg",
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
                      backgroundColor: Colors.white,
                      focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF800000)), // Example focused border
                  ),
                )),
              ),
              50.verticalSpace,

              Center(
                child: PrimaryButton(
                  onPressed: () {
                    final email = profileEmailController._emailController.text;
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF800000),
                          content: Center(
                            child: Text(
                              AppLocalizations.of(context)!.pleaseEnterAnEmail,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (!GetUtils.isEmail(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF800000),
                          content: Center(
                            child: Text(
                              AppLocalizations.of(context)!.pleaseEnterAValidEmail,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      Get.find<ProfileController>().email = email;
                      context.push(AppRouteConstants.createProfilePassword);
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

            ],
          ),
        ),),
      ),
    );
  }
}
