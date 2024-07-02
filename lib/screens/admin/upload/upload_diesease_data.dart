import 'package:Dentepic/screens/admin/upload/api.dart';
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/widgets/custom_elevated_button.dart';
import 'package:Dentepic/widgets/custom_text_form_field.dart';

class UploadDiseaseDataScreen extends StatefulWidget {
  @override
  _UploadDiseaseDataScreenState createState() =>
      _UploadDiseaseDataScreenState();
}

class _UploadDiseaseDataScreenState extends State<UploadDiseaseDataScreen> {
  String? _filePath;
  TextEditingController clinicalFindingsController = TextEditingController();
  TextEditingController treatmentPlanController = TextEditingController();
  TextEditingController emptycontroller = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // void _selectFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['csv'],
  //   );

  //   if (result != null) {
  //     setState(() {
  //       _filePath = result.files.single.path;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? appTheme.blue50
            : Colors.black,
        title: Text(
          'Upload Disease Data',
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 60),
              Column(
                children: [
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
                          return Theme.of(context).brightness ==
                                  Brightness.light
                              ? Colors.black
                              : appTheme.teal600;
                        },
                      ),
                    ),
                    onPressed: () {
                      APIs.readCsvAndStoreDiseaseInFirebase(context);
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
                  if (_filePath != null) Text('Selected File: $_filePath'),
                ],
              ),
              SizedBox(height: 16.v),
              Text(
                "or",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : appTheme.teal600,
                ),
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
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.h,
                      vertical: 7.v,
                    ),
                    decoration: AppDecoration.fillBlue.copyWith(
                      borderRadius: BorderRadius.circular(25),
                      color: Theme.of(context).brightness == Brightness.light
                          ? appTheme.teal600
                          : appTheme.teal600,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 45.v),
                        CustomTextFormField(
                          controller: clinicalFindingsController,
                          hintText: "Clinical Findings",
                        ),
                        SizedBox(height: 20.v),
                        CustomTextFormField(
                          controller: treatmentPlanController,
                          hintText: "Treatment Plan",
                          maxLines: 5, // Make it multi-line
                        ),
                        SizedBox(height: 20.v),
                        CustomTextFormField(
                          controller: emptycontroller,
                          hintText: "",
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
                          text: "Upload",
                          onPressed: () async {
                            bool res = await APIs.uploadDiseaseDataToDB(
                                context,
                                clinicalFindingsController.text,
                                treatmentPlanController.text);
                            if (res) {
                              clinicalFindingsController.clear();
                              treatmentPlanController.clear();
                            } else
                              print(res);
                            //  Navigator.pushAndRemoveUntil(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => AdminBottom(
                            //             userId: '',
                            //           )),
                            //   (route) => false);
                          },
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
    );
  }
}
