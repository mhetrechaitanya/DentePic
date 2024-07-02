// ignore_for_file: deprecated_member_use

import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/doctor/all%20steps/step_4/report.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SelectTreatmentStep extends StatefulWidget {
  final Map<String, dynamic> studentInfo;
  final String? frontImagePath, upperImagePath, lowerImagePath;
  final List<Map<String, dynamic>> selectedTeethData;
  const SelectTreatmentStep(
      {Key? key,
      required this.studentInfo,
      this.frontImagePath,
      this.upperImagePath,
      this.lowerImagePath,
      required this.selectedTeethData})
      : super(
          key: key,
        );

  @override
  ScannerFrontTabContainerPageState createState() =>
      ScannerFrontTabContainerPageState();
}

class ScannerFrontTabContainerPageState extends State<SelectTreatmentStep> {
  late TabController tabviewController;
  final TextEditingController _textEditingController = TextEditingController();
  SpeechToText speechToText = SpeechToText();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isListning = false;
  String _selectedLanguage = 'en-US'; // Default language

  bool _areTextFieldsValid() {
    return _textEditingController.text.trim().isNotEmpty;
  }

  Future<void> _saveData() async {
  Dialogs.showProgressBar(context);
  try {
      if (_textEditingController.text.isNotEmpty) {
      DocumentReference treatmentCollection = _firestore
          .collection('students')
          .doc(widget.studentInfo['id']);
          // .collection('treatment');

      // Check if the collection exists by trying to fetch a limited snapshot
      // QuerySnapshot treatmentSnapshot = await treatmentCollection.limit(1).get();
            DocumentSnapshot docSnapshot = await treatmentCollection.get();


      if (docSnapshot.exists) {
        // If the collection exists, check if a document with the same treatment description already exists
        // DocumentReference documentRef = treatmentCollection.doc('treatmentData');
        // DocumentSnapshot docSnapshot = await documentRef.get();

          await treatmentCollection.update({
            'treatment': _textEditingController.text.trim(),
          });

          //  await treatmentCollection.set({
          //   'treatment': _textEditingController.text.trim(),
          // }, SetOptions(merge: true));
        } else {
          // Create a new document
          await treatmentCollection.set({
            'treatment': _textEditingController.text.trim(),
          });
      }

      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Data saved successfully");

      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 500),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return ReportScreen(
              studentInfo: widget.studentInfo,
              frontImagePath: widget.frontImagePath,
              upperImagePath: widget.upperImagePath,
              lowerImagePath: widget.lowerImagePath,
              selectedTeethData: widget.selectedTeethData,
              treatmentDescription: _textEditingController.text.trim(),
            );
          },
        ),
      );
    } else {
      Navigator.pop(context);
      Dialogs.showSnackbar(context, "Please enter treatment description.");
    }
  } catch (e) {
    Navigator.pop(context);
    print('Error saving data: $e');
    Fluttertoast.showToast(msg: "Error saving data");
  }
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
              SizedBox(height: 30.v),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.v),
                      SizedBox(
                        height: 818.v,
                        width: double.maxFinite,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildUserProfile(
                                      context, widget.studentInfo),
                                  SizedBox(height: 18.v),
                                  Text(
                                    'Step 3: Treatment Plan',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : appTheme.blue50,
                                    ),
                                  ),
                                  SizedBox(height: 30.v),
                                  Text(
                                    'Tap to activate Speech to Text',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AvatarGlow(
                                        animate: _isListning,
                                        duration: Duration(milliseconds: 1500),
                                        glowColor: appTheme.black900,
                                        repeat: true,
                                        glowRadiusFactor: 20,
                                        child: GestureDetector(
                                          onTapDown: (details) async {
                                            await _startListening();
                                          },
                                          onTapUp: (details) {
                                            _stopListening();
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.light
                                                ? appTheme.teal600
                                                : appTheme.blue50,
                                            radius: 30,
                                            child: Icon(
                                              _isListning
                                                  ? Icons.mic
                                                  : Icons.mic_none,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      DropdownButton<String>(
                                        value: _selectedLanguage,
                                        icon: Icon(Icons.arrow_downward),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(color: Colors.black),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedLanguage = newValue!;
                                          });
                                        },
                                        items: <String>[
                                          'en-US',
                                          'hi-IN',
                                          'mr-IN'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 455.v,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 34),
                                    child: TextFormField(
                                      controller: _textEditingController,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: appTheme.whiteA700,
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                      ),
                                      maxLines: 8,
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
            if (_areTextFieldsValid()) {
              _saveData();
            } else {
              Dialogs.showSnackbar(
                  context, "Please enter treatment description.");
            }
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
      padding: EdgeInsets.symmetric(
        horizontal: 32.h,
        vertical: 15.v,
      ),
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
                child: Text(
                  "Name",
                  style: TextStyle(color: Colors.black),
                ),
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
              Text(
                "Blood Group",
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 4.v),
              Text(
                studentInfo['blood_group'].toString(),
                style: theme.textTheme.titleMedium,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              right: 32.h,
              bottom: 2.v,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gender",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 4.v),
                Text(
                  studentInfo['gender'].toString(),
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 12.v),
                Text(
                  "Age",
                  style: TextStyle(color: Colors.black),
                ),
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

  Future<void> _startListening() async {
    if (!_isListning) {
      bool available = await speechToText.initialize(
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() {
          _isListning = true;
        });
        speechToText.listen(
          onResult: (result) {
            setState(() {
              _textEditingController.text = result.recognizedWords;
            });
          },
          localeId: _selectedLanguage,
          cancelOnError: true,
        );
      }
    }
  }

  void _stopListening() {
    if (_isListning) {
      speechToText.stop();
      setState(() {
        _isListning = false;
      });
    }
  }
}
