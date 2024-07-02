import 'package:Dentepic/screens/admin/admin_bottom_nav.dart';
import 'package:Dentepic/screens/auth/login/login_tab.dart';
import 'package:Dentepic/screens/doctor/doctor_bottom_nav.dart';
import 'package:Dentepic/services/notifi_service.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/widgets/custom_dropdown_field.dart';
import 'package:Dentepic/widgets/custom_elevated_button.dart';
import 'package:Dentepic/widgets/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController regIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cnfpasswordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedRole;

  Future<void> register() async {
    try {
      if (_formKey.currentState!.validate()) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Dialogs.showProgressBar(context);
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        if (selectedRole == 'Doctor') {
          // Add doctor data to Firestore
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(userCredential.user!.uid)
              .set({
            'email': emailController.text,
            'fullName': fullnamecontroller.text,
            'role': 'Doctor',
            'status': 'AV',
            'red_id': regIdController.text,
            // Add more fields as needed
          });
          print(userCredential.user!.uid);
          await prefs.setString('userRole', 'doctors');
          await prefs.setString('id', userCredential.user!.uid.toString());

          // Navigate to DoctorBottomNav screen
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorBottom(
                  userId: userCredential.user!.uid,
                ),
              ),
              (route) => false);
        } else if (selectedRole == 'Admin') {
          // Add admin data to Firestore
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(userCredential.user!.uid)
              .set({
            'email': emailController.text,
            'fullName': fullnamecontroller.text,
            'role': 'Admin',
            'varified': false,
            // Add more fields as needed
          });
          print(userCredential.user!.uid);

          await prefs.setString('userRole', 'admins');
          await prefs.setString('id', userCredential.user!.uid.toString());

          // Navigate to AdminBottomNav screen
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => AdminBottom(
                  userId: userCredential.user!.uid,
                ),
              ),
              (route) => false);
        }
        // Navigator.pop(context);
        NotificationService().showNotification(
            title: 'Welcome ${fullnamecontroller.text}',
            body:
                'Welcome to Dentepic\'s Keeping your smile bright and healthy.',
            id: 0);
        NotificationService().scheduleNotificationAfter2Minutes(
          id: 0,
          title: 'Welcome ${fullnamecontroller.text}',
          body: 'Welcome to Dentepic\'s Keeping your smile bright and healthy.',
        );

        Dialogs.showSnackbar(context, "Registration Successful");
      }
    } catch (error) {
      Navigator.pop(context);
      String errorMessage = 'Registration failed';
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Operation not allowed. Please contact support.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          default:
            errorMessage = 'An undefined error occurred.';
        }
      }
      Dialogs.showSnackbar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 45.v),
          CustomImageView(
            imagePath: ImageConstant.imgImage3,
            height: 180.v,
          ),
          Center(
            child: Text(
              "Register",
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Expanded(
            child: Container(
              decoration: AppDecoration.fillBlue.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? appTheme.teal600
                    : appTheme.teal600,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.50),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        //   child: Container(
                        //     width: double.maxFinite,
                        //     decoration: AppDecoration.fillBlue.copyWith(
                        // borderRadius: BorderRadius.circular(25),
                        // color: Theme.of(context).brightness == Brightness.light
                        //     ? appTheme.teal600
                        //     : appTheme.teal600,),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.h,
                            vertical: 7.v,
                          ),
                          decoration: AppDecoration.fillBlue.copyWith(
                            borderRadius: BorderRadius.circular(25),
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? appTheme.teal600
                                    : appTheme.teal600,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 45.v),
                              CustomTextFormField(
                                controller: fullnamecontroller,
                                hintText: "Full Name",
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.v),
                              CustomTextFormField(
                                controller: emailController,
                                hintText: "Email",
                                textInputType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.v),
                              CustomDropdownField(
                                value: selectedRole,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedRole = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 20.v),
                              if (selectedRole == 'Doctor')
                                // SizedBox(height: 20),
                                CustomTextFormField(
                                  controller: regIdController,
                                  hintText: "Registration Id",
                                  // textInputType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Registration Id';
                                    }
                                    return null;
                                  },
                                ),
                              if (selectedRole == 'Doctor')
                                SizedBox(height: 20.v),
                              CustomTextFormField(
                                // controller: passwordController,
                                hintText: "key",
                                // textInputAction: TextInputAction.done,
                                // textInputType: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your key';
                                  }
                                  if (value != 'Dentepic123@dpp') {
                                    Dialogs.showSnackbar(
                                        context, 'Not Valid key');
                                    return 'Please Emter Valid Key';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.v),
                              CustomTextFormField(
                                controller: passwordController,
                                hintText: "Password",
                                textInputAction: TextInputAction.done,
                                textInputType: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                showPassIcon: true,
                              ),
                              SizedBox(height: 20.v),
                              CustomTextFormField(
                                controller: cnfpasswordController,
                                hintText: "Confirm Password",
                                textInputAction: TextInputAction.done,
                                textInputType: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                showPassIcon: true,
                              ),
                              SizedBox(height: 58.v),
                              CustomElevatedButton(
                                buttonTextStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                buttonStyle: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      return Colors.black;
                                    },
                                  ),
                                ),
                                text: "Register",
                                onPressed: () {
                                  register();
                                },
                              ),
                              SizedBox(height: 16.v),
                              Text(
                                "Or",
                                style: CustomTextStyles
                                    .titleMediumOnPrimaryContainer,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginTab(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                      fontFamily: 'Inter'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
