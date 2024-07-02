import 'package:Dentepic/screens/admin/admin_bottom_nav.dart';
import 'package:Dentepic/screens/auth/register/register.dart';
import 'package:Dentepic/widgets/custom_text_form_field.dart';
import 'package:Dentepic/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:Dentepic/core/app_export.dart';

// ignore_for_file: must_be_immutable
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key})
      : super(
          key: key,
        );

  @override
  AdminLoginPageState createState() => AdminLoginPageState();
}

class AdminLoginPageState extends State<AdminLoginPage>
    with AutomaticKeepAliveClientMixin<AdminLoginPage> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: SizeUtils.width,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Container(
                width: double.maxFinite,
                decoration: AppDecoration.fillBlue,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 46.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.h,
                    vertical: 7.v,
                  ),
                  decoration: AppDecoration.fillBlue.copyWith(
                    borderRadius: BorderRadiusStyle.customBorderBL13,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 45.v),
                      CustomTextFormField(
                        controller: emailController,
                        hintText: "Email",
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 25.v),
                      CustomTextFormField(
                        controller: passwordController,
                        hintText: "Password",
                        textInputAction: TextInputAction.done,
                        textInputType: TextInputType.visiblePassword,
                        obscureText: true,
                        showPassIcon: true,
                      ),
                      SizedBox(height: 7.v),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Forgot Password?",
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      SizedBox(height: 58.v),
                      CustomElevatedButton(
                        text: "Sign In",
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminBottom(
                                        userId: '',
                                      )),
                              (route) => false);
                        },
                      ),
                      SizedBox(height: 16.v),
                      Text(
                        "Or",
                        style: CustomTextStyles.titleMediumOnPrimaryContainer,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => Register()));
                        },
                        child: Text(
                          "Register Now",
                          style: CustomTextStyles.titleMediumTeal600,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
