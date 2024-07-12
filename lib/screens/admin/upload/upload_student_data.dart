import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/admin/upload/api.dart';
import 'package:Dentepic/widgets/custom_bloodgrp_field.dart';
import 'package:Dentepic/widgets/custom_elevated_button.dart';
import 'package:Dentepic/widgets/custom_gender_field.dart';
import 'package:Dentepic/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class UploadStudentDataScreen extends StatefulWidget {
  @override
  _UploadStudentDataScreenState createState() =>
      _UploadStudentDataScreenState();
}

class _UploadStudentDataScreenState extends State<UploadStudentDataScreen> {
  // List<List<dynamic>> _data = [];
  TextEditingController fullNameController = TextEditingController();
  TextEditingController instituteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedGender;
  String? selectedBloodGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? appTheme.blue50
            : Colors.black,
        title: Text(
          'Upload Student Data',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : appTheme.teal600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              CustomElevatedButton(
                buttonTextStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
                  fontSize: 14,
                ),
                buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.teal600;
                    },
                  ),
                ),
                onPressed: () {
                  APIs.readCsvAndStoreInFirebase(context);
                },
                text: 'Upload Excel Sheet',
                showIcon: true,
                leftIcon: Icon(
                  Icons.upload_file,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              SizedBox(height: 16.v),
              Text(
                "or",
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : appTheme.teal600,
                    fontSize: 16),
              ),
              SizedBox(height: 10.v),
              Form(
                key: _formKey,
                child: Container(
                  width: double.maxFinite,
                  decoration: AppDecoration.fillBlue.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? appTheme.teal600
                          : appTheme.teal600,
                      borderRadius: BorderRadius.circular(25)),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(height: 45.v),
                    CustomTextFormField(
                      controller: fullNameController,
                      hintText: "Full Name",
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 20.v),
                    CustomTextFormField(
                      controller: mobileController,
                      hintText: "Mobile No",
                      textInputType: TextInputType.phone,
                    ),
                    SizedBox(height: 20.v),
                    CustomTextFormField(
                      controller: emailController,
                      hintText: "Email",
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 20.v),
                    CustomGenderDropdownField(
                      value: selectedGender,
                      onChanged: (newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    CustomBloodDropdownField(
                      value: selectedBloodGroup,
                      onChanged: (newValue) {
                        setState(() {
                          selectedBloodGroup = newValue;
                        });
                      },
                      defaultBloodGroup:
                          'Select Blood Group', // Optional: Provide a default value
                    ),
                    SizedBox(height: 20.v),
                    CustomTextFormField(
                      controller: ageController,
                      hintText: "Age",
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.visiblePassword,
                      // obscureText: true,
                    ),
                    SizedBox(height: 20.v),
                    CustomTextFormField(
                      controller: instituteController,
                      hintText: "Institute",
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.visiblePassword,
                    ),
                    SizedBox(height: 30.v),
                    CustomElevatedButton(
                      buttonTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      text: "Register",
                      buttonStyle: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.black;
                          },
                        ),
                      ),
                      onPressed: () async {
                        bool res = await APIs.storeStudentDataToDB(
                            context,
                            fullNameController.text,
                            selectedGender,
                            selectedBloodGroup,
                            instituteController.text,
                            ageController.text,
                            emailController.text,
                            mobileController.text);
                        if (res) {
                          fullNameController.clear();
                          ageController.clear();
                          instituteController.clear();
                          setState(() {
                            selectedBloodGroup = null;
                            selectedGender = null;
                          });
                        } else
                          print(res);
                      },
                    ),
                    SizedBox(height: 30.v),
                  ]),
                ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
