import 'package:Dentepic/screens/auth/login/login_tab.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/widgets/custom_elevated_button.dart';
import 'package:Dentepic/widgets/custom_text_form_field.dart';

class ForgotPassScreen extends StatefulWidget {
  @override
  _ForgotPassScreenState createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  TextEditingController emailController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    try {
      if (_formKey.currentState!.validate()) {
        // Send password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );
        // Show success message
        Dialogs.showSnackbar(
            context, "Password reset email sent successfully.");
        emailController.clear();
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        // Show error message if user does not exist
        Dialogs.showSnackbar(context, "This email does not exist.");
      } else {
        // Show generic error message for other errors
        Dialogs.showSnackbar(context, "Failed to send password reset email.");
      }
    } catch (error) {
      Dialogs.showSnackbar(context, "Failed to send password reset email.");
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
            height: 279.v,
          ),
          Center(
            child: Text(
              "Reset Password",
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: appTheme.teal600,
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
                                controller: emailController,
                                hintText: "Email",
                                textInputType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
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
                                text: "Send Mail",
                                onPressed: resetPassword,
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
