import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nawalah/controllers/profile_controller.dart';
import 'package:nawalah/routes/routes_constants.dart';
import 'package:nawalah/util/theme/theme.dart';
import 'package:nawalah/util/theme/theme_constants.dart';
import 'package:nawalah/widgets/normal_appbar.dart';
import 'package:nawalah/widgets/primary_button.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NameValidator {
  static String? validateName(String? value) {
    // if (value != null) {
    // if (value.length < 3) {
    //   return 'Name must be more than 2 charater';
    // } else
    return '';
    // }
  }

  static void submitForm(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      // Validation successful, proceed with form submission
    } else {
      // Validation failed, handle invalid form data
    }
  }
}

class CreateProfileName extends StatefulWidget {
  const CreateProfileName({super.key});

  @override
  State<CreateProfileName> createState() => _CreateProfileNameState();
}

class _CreateProfileNameState extends State<CreateProfileName> {
  TextEditingController nameController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    profileController.dispose();
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
                value: 1 / 5,
                height: 5.h,
                backgroundColor: onNeutralColor,
                color: const Color(0xFFD11559),
              ),
              130.verticalSpace,
              Center(
                child: SizedBox(
                  width: 326,
                  height: 68,
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.readyToCreateYourProfileFirstWhatsYourName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: bold,
                      fontSize: 60,
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
                  // child: AutoSizeText(
                  //   AppLocalizations.of(context)!.thisIsHowYoullAppearOnParaisoNew,
                  //   textAlign: TextAlign.center,
                  //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  //     color: Colors.black,
                  //   ),
                  //   maxLines: 2,
                  // ),
                ),
              ),
              38.verticalSpace,
              Center(
                child: SvgTextField(
                  hintText: AppLocalizations.of(context)!.enterYourFullName,
                  controller: nameController,
                  validator: NameValidator.validateName,
                  prefixIcon: 'assets/images/Create Account(name-2)_User_248_3071.svg',
                  textInputType: TextInputType.emailAddress,
                  backgroundColor: Colors.white,
                  color:Colors.black,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD11559)), // Example focused border
                  ),
                ),
              ),
              30.verticalSpace,
              Center(
                child: PrimaryButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      Get.find<ProfileController>().name = nameController.text;
                      context.push(AppRouteConstants.createProfileEmail);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFD11559),
                          content: Center(child: Text(AppLocalizations.of(context)!.pleaseEnterYourName,
                            style: const TextStyle(color: Colors.white,fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w400,),)),
                        ),
                      );
                    }
                  },
                  icon: Icons.arrow_forward_ios_outlined,
                  color: const Color(0xFFD11559),
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
