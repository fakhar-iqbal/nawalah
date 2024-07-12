import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:paraiso/screens/Restaurant/RSignInView.dart';
import 'package:provider/provider.dart';

import 'package:velocity_x/velocity_x.dart';

import '../controllers/customer_controller.dart';
import '../controllers/profile_controller.dart';
import '../repositories/customer_firebase_calls.dart';

import '../util/theme/theme.dart';
import '../util/theme/theme_constants.dart';
import '../widgets/primary_button.dart';
import '../widgets/svgtextfield.dart';
import 'login_screen.dart';
import 'email_service.dart'; // Import the email service
/*
class ForgotFormController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;
  RxBool rememberMe = false.obs;

  void toggleRememberMe() {
    rememberMe.toggle();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      emailValid.value = false;
      return 'Please enter an email address';
    }

    if (!GetUtils.isEmail(value)) {
      emailValid.value = false;
      return 'Please enter a valid email address';
    }
    // Add additional email validation logic
    emailValid.value = true;
    return null;
  }

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter your password.";
    } else if (value.length < 6) {
      return "The password must be at least 6 characters long.";
    }
    // Add additional password validation logic
    return null;
  }

  String? otpValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter the OTP.";
    } else if (value.length != 6) {
      return "The OTP must be 6 digits long.";
    }
    // Add additional password validation logic
    return null;
  }

  void submitForm(BuildContext context) {
    //TODO uncomment this
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  final String userType;
  const ForgotPasswordScreen({Key? key,this.userType="user"}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotFormController loginFormController =
  Get.put(ForgotFormController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isAuthenticating = false;

  String forgotUserId = "";
  String forgotUserEmail = "";
  String forgotUserType = "";

  void signInAnonymously(Function callback) {
    FirebaseAuth.instance.signInAnonymously().then((value) {
      if (kDebugMode) print("User ID: ${value.user!.uid}");
      callback();
    });
  }

  String screenType = "email";

  EmailOTP myAuth = EmailOTP();


// Inside your ForgotPasswordScreen class
  Future<void> sendOtp() async {
    if (loginFormController._emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Please fill all fields",
              style: context.titleMedium,
            ),
          ),
          backgroundColor: dangerColor,
        ),
      );
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "OTP sending in progress...",
              style: context.titleMedium?.copyWith(
                color: white,
              ),
            ),
          ),
          backgroundColor: successColor,
        ),
      );

      final emailService = EmailService();
      final otp = generateOtp(); // Method to generate OTP
      final emailBody = 'Your OTP is: $otp';

      await emailService.sendEmail(
        loginFormController._emailController.text,
        'Your OTP Code',
        emailBody,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "OTP sent!",
              style: context.titleMedium?.copyWith(
                color: white,
              ),
            ),
          ),
          backgroundColor: successColor,
        ),
      );

      setState(() {
        screenType = "otp";
      });
    }
  }

  String generateOtp() {
    final random = Random();
    final otp = random.nextInt(900000) + 100000; // Generate a 6-digit OTP
    return otp.toString();
  }


  Future<void> verifyOtp() async{
    if (loginFormController
        ._otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Please fill all the fields",
              style: context.titleMedium,
            ),
          ),
          backgroundColor: dangerColor,
        ),
      );
      return;
    }
    else{
      bool isVerified=await myAuth.verifyOTP(
        otp: loginFormController._otpController.text,
      );
      if(isVerified){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "The OTP has been verified!",
                style: context.titleMedium?.copyWith(
                  color: white,
                ),
              ),
            ),
            backgroundColor: successColor,
          ),
        );
        setState(() {
          screenType = "password";
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "Wrong OTP, please try again!",
                style: context.titleMedium?.copyWith(
                  color: white,
                ),
              ),
            ),
            backgroundColor: dangerColor,
          ),
        );
      }

      loginFormController._otpController.clear();

    }

  }

  Future<void> changePassword() async{

    print("forgotUserId: $forgotUserId");
    print("forgotUserEmail: $forgotUserEmail");
    print("forgotUserType: $forgotUserType");


    if (loginFormController
        ._passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Please fill all the fields",
              style: context.titleMedium,
            ),
          ),
          backgroundColor: dangerColor,
        ),
      );
      return;
    }
    else{



      final mycust=MyCustomerCalls();

      await mycust.changePassword(
        password : loginFormController._passwordController.text,
        userId : forgotUserId,
        userType : forgotUserType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Password changed!",
              style: context.titleMedium?.copyWith(
                color: white,
              ),
            ),
          ),
          backgroundColor: successColor,
        ),
      );


      loginFormController._passwordController.clear();

      if(widget.userType=="user"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RSignInView()));
      }


      setState(() {
        screenType = "email";
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    final customerController =
    Provider.of<CustomerController>(context, listen: false);

    return
      Container(
        // decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //         colors: [Color(0xFFFFF7AD), Color(0xFFFFA9F9)])),
        child: Scaffold(
          backgroundColor: Color(0xFFFDF6F7),


          body: SafeArea(
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
                          128.verticalSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/paraiso_logo.png',height: 230.h,
                                width: 230.w,),

                            ],
                          ),
                          88.verticalSpace,
                          SizedBox(
                            width: 208,
                            height: 39,
                            child: Text(
                              "Reset password",
                              textAlign: TextAlign.center,
                              style: context.titleLarge!.copyWith(
                                fontWeight: bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          4.verticalSpace,
                          if (screenType == "email")
                            SizedBox(
                              width: 273.w,
                              height: 55.h,
                              child: AutoSizeText(
                                "Please enter your email address below and we will send you an OTP code to reset your password.",
                                textAlign: TextAlign.center,
                                style: context.titleSmall!.copyWith(
                                  color: Colors.black,
                                ),
                                maxLines: 2,

                              ),
                            ),
                          if (screenType == "otp")
                            SizedBox(
                              width: 273.w,
                              child: AutoSizeText(
                                "Please enter the OTP sent to your email address: ",
                                textAlign: TextAlign.center,
                                style: context.titleSmall!.copyWith(
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          if (screenType == "otp")
                            SizedBox(
                              width: 273.w,
                              child: AutoSizeText(
                                loginFormController._emailController.text,
                                textAlign: TextAlign.center,
                                style: context.titleSmall!.copyWith(
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          if (screenType == "password")
                            SizedBox(
                              width: 273.w,
                              child: AutoSizeText(
                                "Please enter your new password.",
                                textAlign: TextAlign.center,
                                style: context.titleSmall!.copyWith(
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          38.verticalSpace,
                          if (screenType == "email")Obx(() {
                            return SvgTextField(
                              hintText:
                              "Enter your Email",
                              controller: loginFormController._emailController,
                              validator: loginFormController.emailValidator,
                              prefixIcon: "assets/images/email_icon.svg",
                              // suffixIcon: loginFormController.isEmailValid
                              //     ? const SizedIcons(
                              //   svgPath: "assets/images/icon_checkmark.svg",
                              //   scale: .4,
                              // )
                              //     : null,
                              textInputType: TextInputType.emailAddress,
                              backgroundColor: const Color(0xFFFFE5E5),
                            );
                          }),
                          18.verticalSpace,
                          if (screenType == "otp")
                            SvgTextField(
                              hintText: "Enter the OTP",
                              controller: loginFormController._otpController,
                              validator: loginFormController.otpValidator,
                              prefixIcon:
                              "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                              textInputType: TextInputType.number,
                              backgroundColor: const Color(0xFFFFE5E5),
                            ),
                          if (screenType == "password")
                            SvgTextField(
                              hintText: "Enter the new word",
                              controller: loginFormController._passwordController,
                              validator: loginFormController.passwordValidator,
                              prefixIcon:
                              "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                              isPasswordField: true,
                              textInputType: TextInputType.emailAddress,
                              backgroundColor: const Color(0xFFFFE5E5),
                            ),
                          53.verticalSpace,
                          Center(
                            child: PrimaryButton(
                              onPressed: () async {

                                if(screenType=="email"){
                                  final mycust=MyCustomerCalls();

                                  final listsss= await mycust.getEmails();

                                  bool isRegistered=false;

                                  for(int i=0;i<listsss.length;i++){
                                    if(listsss[i]["email"]==loginFormController._emailController.text){
                                      await sendOtp();
                                      isRegistered=true;
                                      setState(() {
                                        forgotUserId = listsss[i]["id"];
                                        forgotUserEmail = listsss[i]["email"];
                                        forgotUserType = listsss[i]["userType"];
                                      });
                                      break;
                                    }
                                  }
                                  if(!isRegistered){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Center(
                                          child: Text(
                                            "pass. Unregistered email!",
                                            style: context.titleMedium!.copyWith(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        backgroundColor: dangerColor,
                                      ),
                                    );
                                  }

                                }

                                if(screenType=="otp"){
                                  await verifyOtp();
                                }

                                if(screenType=="password"){
                                  await changePassword();
                                  // setState(() {
                                  //   screenType = "email";
                                  // });
                                }
                              },
                              child: isAuthenticating
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : AutoSizeText(
                                screenType == "email"
                                    ? "Send OTP"
                                    : screenType == "otp"
                                    ? "Check OTP"
                                    : "Reset password",

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
                          ScreenUtil().scaleHeight < 1
                              ? 83.h.verticalSpace
                              : 163.h.verticalSpace,

                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Back",
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
                              if(screenType=="email"){
                                if(widget.userType=="user"){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                }
                                else{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RSignInView()));
                                }
                              }
                              else if(screenType=="otp"){
                                setState(() {
                                  screenType = "email";
                                });
                              }
                              else if(screenType=="password"){
                                setState(() {
                                  screenType = "otp";
                                });
                              }
                            },
                          ).paddingOnly(bottom: 5.h),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),);
  }
}


*/
//////////////////////////////////////////////////////////////////////

class ForgotFormController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;
  RxBool rememberMe = false.obs;

  void toggleRememberMe() {
    rememberMe.toggle();
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      emailValid.value = false;
      return 'Please enter an email address';
    }

    if (!GetUtils.isEmail(value)) {
      emailValid.value = false;
      return 'Please enter a valid email address';
    }
    emailValid.value = true;
    return null;
  }

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter your password.";
    } else if (value.length < 6) {
      return "The password must be at least 6 characters long.";
    }
    return null;
  }

  String? otpValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter the OTP.";
    } else if (value.length != 6) {
      return "The OTP must be 6 digits long.";
    }
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  final String userType;
  const ForgotPasswordScreen({Key? key, this.userType = "user"}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotFormController loginFormController = Get.put(ForgotFormController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String otp = "";

  bool isAuthenticating = false;

  String forgotUserId = "";
  String forgotUserEmail = "";
  String forgotUserType = "";

  void signInAnonymously(Function callback) {
    FirebaseAuth.instance.signInAnonymously().then((value) {
      callback();
    });
  }

  String screenType = "email";

  EmailOTP myAuth = EmailOTP();

  Future<void> sendOtp() async {
    if (loginFormController.emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("Please fill in all fields", style: context.titleMedium),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text("OTP sending in progress...", style: context.titleMedium?.copyWith(color: Colors.white)),
        ),
        backgroundColor: Colors.green,
      ),
    );

    final emailService = EmailService();
    final otp = generateOtp();
    final emailBody = 'Your OTP is: $otp';

    try {
      await emailService.sendEmail(
        loginFormController.emailController.text,
        'Your OTP Code',
        emailBody,
      );

      // Store the OTP securely, for example in a variable or preferably in secure storage
      // This is just an example, use a more secure method in production
      setState(() {
        this.otp = otp;
        screenType = "otp";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("OTP sent!", style: context.titleMedium?.copyWith(color: Colors.white)),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("Failed to send OTP: ${e.toString()}", style: context.titleMedium?.copyWith(color: Colors.white)),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String generateOtp() {
    final random = Random();
    final otp = random.nextInt(900000) + 100000; // Generate a 6-digit OTP
    // Store OTP securely here if necessary
    return otp.toString();
  }

  Future<void> verifyOtp() async {
    if (loginFormController.otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("Please fill in all fields", style: context.titleMedium),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (loginFormController.otpController.text == this.otp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("The OTP has been verified!", style: context.titleMedium?.copyWith(color: Colors.white)),
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        screenType = "password";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("Wrong OTP, please try again!", style: context.titleMedium?.copyWith(color: Colors.white)),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    loginFormController.otpController.clear();
  }


  Future<void> changePassword() async {
    print("forgotUserId: $forgotUserId");
    print("forgotUserEmail: $forgotUserEmail");
    print("forgotUserType: $forgotUserType");

    if (loginFormController.passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("Please fill in all fields", style: context.titleMedium),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else {
      final mycust = MyCustomerCalls();

      try {
        await mycust.changePassword(
          password: loginFormController.passwordController.text,
          userId: forgotUserId,
          userType: forgotUserType,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text("Password changed!", style: context.titleMedium?.copyWith(color: Colors.white)),
            ),
            backgroundColor: Colors.green,
          ),
        );

        loginFormController.passwordController.clear();

        if (forgotUserType == "clients") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RSignInView()));
        }

        setState(() {
          screenType = "email";
        });
      } catch (e) {
        print("Error changing password: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text("Failed to change password. Please try again.", style: context.titleMedium?.copyWith(color: Colors.white)),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF6F7),
      body: SafeArea(
        child: Form(
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
            child: Stack(
              children: [
                ListView(
                  children: <Widget>[
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                        image: DecorationImage(
                          alignment: Alignment.center,
                          image: AssetImage("assets/images/OTP.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 50),
                          if (screenType == "email") ...[
                            Text(
                              "Enter your email address and we will send you an OTP to reset your password.",
                              style: context.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: loginFormController.emailController,
                              style: context.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              validator: loginFormController.emailValidator,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "you@example.com",
                                labelStyle: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                hintStyle: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.black, width: 1),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.pink, width: 1),
                                ),
                                prefixIcon: const Icon(Icons.email_outlined, color: Colors.pink),
                                suffixIcon: Obx(() => loginFormController.isEmailValid ? const Icon(Icons.check, color: Colors.green) : const SizedBox.shrink()),
                                contentPadding: const EdgeInsets.all(0),
                                isDense: true,
                                fillColor: Colors.white,
                                filled: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                backgroundColor: Colors.pink,
                                textStyle: context.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              onPressed: () async {

    if(screenType=="email"){
    final mycust=MyCustomerCalls();

    final listsss= await mycust.getEmails();

    bool isRegistered=false;

    for(int i=0;i<listsss.length;i++){
    if(listsss[i]["email"]==loginFormController.emailController.text){
    await sendOtp();
    isRegistered=true;
    setState(() {
    forgotUserId = listsss[i]["id"];
    forgotUserEmail = listsss[i]["email"];
    forgotUserType = listsss[i]["userType"];
    });
    break;
    }
    }
    if(!isRegistered){
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Center(
    child: Text(
    "pass. Unregistered email!",
    style: context.titleMedium!.copyWith(
    color: Colors.black,
    ),
    ),
    ),
    backgroundColor: dangerColor,
    ),
    );
    }

    }

    if(screenType=="otp"){
    await verifyOtp();
    }

    if(screenType=="password"){
    await changePassword();
    // setState(() {
    //   screenType = "email";
    // });
    }
    },

                              //////////////////////////////////
                              child: const Text("Send OTP"),
                            ),
                          ],
                          if (screenType == "otp") ...[
                            Text(
                              "Enter the OTP sent to your email address.",
                              style: context.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: loginFormController.otpController,
                              style: context.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              validator: loginFormController.otpValidator,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "OTP",
                                fillColor: Colors.white,
                                labelStyle: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                hintStyle: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.black, width: 1),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.pink, width: 1),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.pink),
                                contentPadding: const EdgeInsets.all(0),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                backgroundColor: Colors.pink,
                                textStyle: context.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              onPressed: verifyOtp,
                              child: const Text("Verify OTP"),
                            ),
                          ],
                          if (screenType == "password") ...[
                            Text(
                              "Create a new password.",
                              style: context.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: loginFormController.passwordController,
                              style: context.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              validator: loginFormController.passwordValidator,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: "New Password",
                                fillColor: Colors.white,
                                labelStyle: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                hintStyle: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.black, width: 1),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.pink, width: 1),
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.pink),
                                contentPadding: const EdgeInsets.all(0),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                backgroundColor: Colors.pink,
                                textStyle: context.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              onPressed: changePassword,
                              child: const Text("Change Password"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Assumes you have navigation set up
                    },
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


