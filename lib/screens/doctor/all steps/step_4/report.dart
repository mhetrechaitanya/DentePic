// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:Dentepic/screens/doctor/doctor_bottom_nav.dart';
import 'package:Dentepic/services/file_handle_api.dart';
import 'package:Dentepic/services/pdf_service_dr.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Dentepic/core/app_export.dart';

class ReportScreen extends StatefulWidget {
  final Map<String, dynamic> studentInfo;
  final String? frontImagePath, upperImagePath, lowerImagePath;
  final List<Map<String, dynamic>> selectedTeethData;
  final String treatmentDescription;

  const ReportScreen({
    Key? key,
    required this.studentInfo,
    this.frontImagePath,
    this.upperImagePath,
    this.lowerImagePath,
    required this.selectedTeethData,
    required this.treatmentDescription,
  }) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late TabController tabviewController;

  void uploadReportData() async {
    Dialogs.showProgressBar(context);

    try {
      // FirebaseStorage _storage = FirebaseStorage.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Example path to store reports
      // DocumentReference reportRef = firestore.collection('reports').doc();
      DocumentReference studentsRef =
          firestore.collection('students').doc(widget.studentInfo['id']);
      await studentsRef.update(
        {
          // 'reportRef': reportRef.id,
          'checkupStatus': true,
        },
      );

      // Delay to show success message
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop(); // Hide saving dialog
      Dialogs.showSnackbar(context, "Report uploaded successfully");

      _generateAndSharePdf();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => DoctorBottom(
                  userId: '',
                )),
        (route) => false, // Removes all routes from the stack
      );
    } catch (e) {
      // print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print('Error uploading report: $e');

      Navigator.of(context).pop(); // Hide saving dialog
      Dialogs.showSnackbar(
          context, "Failed to upload report. Please try again later: $e");
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submit',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              )),
          content: Text('Are you sure you want to submit this report?',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              )),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
              onPressed: () {
                // Navigator.of(context).pop();
                uploadReportData();
                _generateAndSharePdf();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndSharePdf() async {
    PdfApiDr pdf = PdfApiDr();
    final pdfFile = await pdf.generate(
        widget.studentInfo,
        widget.frontImagePath,
        widget.upperImagePath,
        widget.lowerImagePath,
        widget.selectedTeethData,
        widget.treatmentDescription);
    FileHandleApi.openFile(pdfFile);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => DoctorBottom(
                userId: '',
              )),
      (route) => false, // Removes all routes from the stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? appTheme.blue50
              : Colors.black,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
        body: Container(
          width: double.maxFinite,
          decoration: AppDecoration.fillBlue.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? appTheme.blue50
                : Colors.black,
          ),
          child: Column(
            children: [
              _buildUserProfile(context, widget.studentInfo),
              SizedBox(height: 18.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Step 4: Report',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 36.v),
                      SizedBox(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Photos:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildPhoto(widget.frontImagePath ??
                                            ImageConstant.imageNotFound),
                                        _buildPhoto(widget.upperImagePath ??
                                            ImageConstant.imageNotFound),
                                        _buildPhoto(widget.lowerImagePath ??
                                            ImageConstant.imageNotFound),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Clinical Findings & Investigation:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: widget.selectedTeethData
                                        .map((teethData) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          teethData['imagePath'] == ''
                                              ? Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 22),
                                                  child: Image.asset(
                                                    teethData['imagePath'] ??
                                                        ImageConstant
                                                            .imageNotFound,
                                                    height: 50,
                                                    width: 50,
                                                  ),
                                                )
                                              : Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 22),
                                                  child: _buildPhotoNet(
                                                      teethData['imagePath']),
                                                ),
                                          SizedBox(height: 10),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 22),
                                            child: Text(
                                              'Tooth: ${teethData['toothId']}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 22),
                                            child: Text(
                                              'Description: ${teethData['description']}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                           Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 22),
                                            child:Divider(color: Colors.black, thickness: 0.3,),

                                          ),
                                          SizedBox(height: 10,),

                                        ],
                                      ); 
                                    }).toList(),
                                  ),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Treatment Plan:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      widget.treatmentDescription,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                            fontSize: 14
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showConfirmationDialog();
          },
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? appTheme.teal600
              : appTheme.blue50,
          child: Icon(
            Icons.done,
            color: Colors.black,
            size: 40,
          ),
          shape: CircleBorder(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildUserProfile(
      BuildContext context, Map<String, dynamic> studentInfo) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 32.h, vertical: 15.v),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 1.h),
                child: Text("Name", style: TextStyle(color: Colors.black)),
              ),
              SizedBox(height: 3.v),
              Padding(
                padding: EdgeInsets.only(left: 1.h),
                child: Text(
                  studentInfo['full_name'].toString(),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              SizedBox(height: 12.v),
              Text("Blood Group", style: TextStyle(color: Colors.black)),
              SizedBox(height: 4.v),
              Text(
                studentInfo['blood_group'].toString(),
                style: theme.textTheme.titleMedium,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 32.h, bottom: 2.v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Gender", style: TextStyle(color: Colors.black)),
                SizedBox(height: 4.v),
                Text(
                  studentInfo['gender'].toString(),
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 12.v),
                Text("Age", style: TextStyle(color: Colors.black)),
                SizedBox(height: 2.v),
                Text(
                  studentInfo['age'].toString(),
                  style: theme.textTheme.titleMedium,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhoto(String imagePath) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover, // Adjust the BoxFit as per your requirement
        ),
      ),
    );
  }

  Widget _buildPhotoNet(String imagePath) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover, // Adjust the BoxFit as per your requirement
        ),
      ),
    );
  }
}
