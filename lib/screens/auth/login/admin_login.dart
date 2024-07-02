import 'package:Dentepic/screens/auth/login/forgot_pass.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dentepic/screens/admin/admin_bottom_nav.dart';
import 'package:Dentepic/screens/doctor/doctor_bottom_nav.dart';
import 'package:Dentepic/screens/auth/register/register.dart';
import 'package:Dentepic/widgets/custom_text_form_field.dart';
import 'package:Dentepic/widgets/custom_elevated_button.dart';
import 'package:Dentepic/core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  AdminLoginPageState createState() => AdminLoginPageState();
}

class AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    try {
      if (_formKey.currentState!.validate()) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Dialogs.showProgressBar(context);
        // Sign in user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text);

        // Check user's role based on the collections
        String userId = userCredential.user!.uid;
        DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(userId)
            .get();
        DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
            .collection('admins')
            .doc(userId)
            .get();

        if (doctorSnapshot.exists) {
          // User is a doctor
          Dialogs.showSnackbar(context, 'Log in Successful ):');
          await prefs.setString('userRole', 'doctors');
          await prefs.setString('id', userId.toString());
          print(userId);
          Navigator.pop(context);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DoctorBottom(
                        userId: '',
                      )),
              (route) => false);
        } else if (adminSnapshot.exists) {
          // User is an admin
          Dialogs.showSnackbar(context, 'Log in Successful ):');
          await prefs.setString('userRole', 'admins');
          await prefs.setString('id', userId.toString());

          Navigator.pop(context);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminBottom(
                        userId: '',
                      )),
              (route) => false);
        } else {
          // User is not found in either collection
          Navigator.pop(context);
          Dialogs.showSnackbar(context, 'Account Not Found..!');
        }
      }
    } on FirebaseAuthException catch (error) {
        Navigator.pop(context);

      if (error.code == 'wrong-password') {
        // Show error message for incorrect password
        Dialogs.showSnackbar(context, 'Incorrect password. Please try again.');
      } else {
        // Show error message for other authentication errors
        Dialogs.showSnackbar(
            context, 'Failed to sign in. Please check your credentials.');
      }
      } catch (error) {
      print(error);
      Navigator.pop(context);
      String errorMessage = 'Login failed';
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body:  Form(
                key: _formKey,
                // child: Container(
                //   width: double.maxFinite,
                //   decoration: AppDecoration.fillBlue.copyWith(
                //         color: Theme.of(context).brightness == Brightness.light
                //             ? appTheme.teal600
                //             : appTheme.teal600,
                //         borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.h,
                      vertical: 7.v,
                    ),
                    decoration: AppDecoration.fillBlue.copyWith(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                        color: Theme.of(context).brightness == Brightness.light
                            ? appTheme.teal600
                            : appTheme.teal600,
                      ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 45.v),
                        CustomTextFormField(
                          controller: emailController,
                          hintText: "Email",
                          textInputType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 25.v),
                        CustomTextFormField(
                          controller: passwordController,
                          hintText: "Password",
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.visiblePassword,
                          obscureText: true,
                          showPassIcon: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 7.v),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            child: Text(
                              "Forgot Password?",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ForgotPassScreen()),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 58.v),
                        CustomElevatedButton(
                          buttonTextStyle: TextStyle(
                            color:Colors.white,
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
                          text: "Sign In",
                          onPressed: login,
                        ),
                        SizedBox(height: 10.v),
                        Text(
                          "Or",
                          style: CustomTextStyles.titleMediumOnPrimaryContainer,
                        ),
                        SizedBox(height: 10.v),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Register()),
                            );
                          },
                          child: Text(
                            "Register Now",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 14
                            ),
                          ),
                        ),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ),
                // ),
              ),
            ),
          );
  }
}
