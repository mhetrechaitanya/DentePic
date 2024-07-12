// ignore_for_file: deprecated_member_use, unused_field

import 'dart:io';

import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/doctor/all%20steps/step_3/treatmentplan.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SelectToothPage extends StatefulWidget {
  final Map<String, dynamic> studentInfo;
  final String? frontImagePath, upperImagePath, lowerImagePath;

  const SelectToothPage(
      {Key? key,
      required this.studentInfo,
      this.frontImagePath,
      this.upperImagePath,
      this.lowerImagePath})
      : super(key: key);

  @override
  SelectToothPageState createState() => SelectToothPageState();
}

class SelectToothPageState extends State<SelectToothPage>
    with AutomaticKeepAliveClientMixin<SelectToothPage> {
  // @override
  List<Map<String, dynamic>> selectedTeethData = [];
  List<Map<String, dynamic>> selectedTeethDatalocal = [];
  bool get wantKeepAlive => true;
  SpeechToText speechToText = SpeechToText();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedDisease;
  Map<int, String?> selectedToothDisease = {};
  Map<int, XFile?> _selectedImages = {};
  Map<int, String> toothDescriptions = {};
    Map<int, TextEditingController> toothControllers = {};
  Map<String, List<int>> diseaseToothIds = {};
  Map<String, int> diseaseTextFieldsCount = {};
  bool _isListning = false;

  final List<Tooth> teeth = [
    // Upper Teeth (Right to Left)
    Tooth(id: 1, left: 0.175, top: 0.425),
    Tooth(id: 2, left: 0.185, top: 0.350),
    Tooth(id: 3, left: 0.200, top: 0.250),
    Tooth(id: 4, left: 0.230, top: 0.165),
    Tooth(id: 5, left: 0.265, top: 0.100),
    Tooth(id: 6, left: 0.305, top: 0.035),
    Tooth(id: 7, left: 0.370, top: 0.005),
    Tooth(id: 8, left: 0.435, top: 0.000),

    // Upper Teeth (Left to Right)
    Tooth(id: 9, right: 0.435, top: 0.000),
    Tooth(id: 10, right: 0.370, top: 0.005),
    Tooth(id: 11, right: 0.305, top: 0.035),
    Tooth(id: 12, right: 0.265, top: 0.100),
    Tooth(id: 13, right: 0.230, top: 0.165),
    Tooth(id: 14, right: 0.200, top: 0.250),
    Tooth(id: 15, right: 0.185, top: 0.350),
    Tooth(id: 16, right: 0.175, top: 0.425),

    // Lower Teeth (Right to Left)
    Tooth(id: 17, right: 0.175, bottom: 0.425),
    Tooth(id: 18, right: 0.200, bottom: 0.330),
    Tooth(id: 19, right: 0.235, bottom: 0.220),
    Tooth(id: 20, right: 0.260, bottom: 0.140),
    Tooth(id: 21, right: 0.290, bottom: 0.080),
    Tooth(id: 22, right: 0.335, bottom: 0.035),
    Tooth(id: 23, right: 0.395, bottom: 0.005),
    Tooth(id: 24, right: 0.448, bottom: 0.000),

    // Lower Teeth (Right to Left)
    Tooth(id: 25, left: 0.448, bottom: 0.000),
    Tooth(id: 26, left: 0.395, bottom: 0.005),
    Tooth(id: 27, left: 0.335, bottom: 0.035),
    Tooth(id: 28, left: 0.290, bottom: 0.080),
    Tooth(id: 29, left: 0.260, bottom: 0.140),
    Tooth(id: 30, left: 0.235, bottom: 0.220),
    Tooth(id: 31, left: 0.200, bottom: 0.330),
    Tooth(id: 32, left: 0.175, bottom: 0.425),
  ];

  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int toothId, ImageSource path) async {
    final XFile? pickedFile = await _picker.pickImage(source: path);
    if (pickedFile != null) {
      setState(() {
        _selectedImages[toothId] = pickedFile;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _fetchDiseases();
    teeth.forEach((tooth) {
      selectedToothDisease[tooth.id] =
          null; 
      toothControllers[tooth.id] = TextEditingController();// Initialize selected disease to null for each tooth
    });
  }
    @override
  void dispose() {
    toothControllers.forEach((_, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void handleToothSelection(
      String toothId, String description, String imagePath, String devicePath) {
    // Add selected tooth data to list
    selectedTeethData.add({
      'toothId': toothId,
      'description': description,
      'imagePath': imagePath,
    });
    selectedTeethDatalocal.add({
      'toothId': toothId,
      'description': description,
      'imagePath': devicePath,
    });
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final ref =
          FirebaseStorage.instance.ref().child('teeth_images/$fileName');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      Fluttertoast.showToast(msg: "Error uploading image");
      throw e;
    }
  }

  Future<void> _saveData() async {
    Dialogs.showProgressBar(context);
    setState(() {
      _isUploading = true;
    });

    try {
      for (int toothId in selectedToothDisease.keys) {
        if (selectedToothDisease[toothId] != null) {
          // String diseaseName = selectedToothDisease[toothId]!;
          String description = toothControllers[toothId]?.text ?? '';
          String imagePath = '';
          if (_selectedImages[toothId] != null) {
            imagePath = await _uploadImageToStorage(
                File(_selectedImages[toothId]!.path));
          }

          handleToothSelection(toothId.toString(), description, imagePath, _selectedImages[toothId]!.path);
        }
      }
      if (selectedTeethData.isNotEmpty) {
        DocumentReference studentDocRef =
            _firestore.collection('students').doc(widget.studentInfo['id']);
        // CollectionReference teethDataCollectionRef = studentDocRef.collection('teethData');

        // QuerySnapshot teethDataSnapshot = await teethDataCollectionRef.limit(1).get();

        DocumentSnapshot docSnapshot = await studentDocRef.get();

        if (docSnapshot.exists) {
          // If the collection exists, update the document within it
          // DocumentReference documentRef = teethDataSnapshot.docs.first.reference;
          await studentDocRef.update({
            'teeth': selectedTeethData,
          });
        } else {
          // If the collection does not exist, create the document within it
          await studentDocRef.set({
            'teeth': selectedTeethData,
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
                  begin: const Offset(1.0, 0.0), // Offset for right to left
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
              return SelectTreatmentStep(
                studentInfo: widget.studentInfo,
                frontImagePath: widget.frontImagePath,
                upperImagePath: widget.upperImagePath,
                lowerImagePath: widget.lowerImagePath,
                selectedTeethData: selectedTeethDatalocal,
              );
            },
          ),
        );
      } else {
        Navigator.pop(context);
        Dialogs.showSnackbar(context, "Please Select Tooth");
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error saving data: $e');
      Fluttertoast.showToast(msg: "Error saving data");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _onToothTap(int toothId) {
    setState(() {
      if (selectedToothDisease[toothId] == null) {
        selectedToothDisease[toothId] = ''; // Select the tooth with no disease
      } else {
        selectedToothDisease.remove(toothId); // Deselect the tooth
      }
    });
  }

  void _showImageSourceBottomSheet(BuildContext context, int toothId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(toothId, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(toothId, ImageSource.gallery);
                },
              ),
              SizedBox(
                height: 15,
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _startListening(int toothId) async {
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
                 toothControllers[toothId]?.text = result.recognizedWords;
            });
          },
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: _buildScrollView(context),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveData,
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

  Widget _buildScrollView(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appTheme.teal600,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                double height = width; // Assuming a square image

                return Stack(
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.toothImg,
                      height: 350,
                      width: width,
                    ),
                    ...teeth.map((tooth) {
                      return Positioned(
                        left: tooth.left != null ? tooth.left! * width : null,
                        right:
                            tooth.right != null ? tooth.right! * width : null,
                        top: tooth.top != null ? tooth.top! * height : null,
                        bottom: tooth.bottom != null
                            ? tooth.bottom! * height
                            : null,
                        child: GestureDetector(
                          onTap: () {
                            _onToothTap(tooth.id);
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedToothDisease[tooth.id] != null
                                  ? Colors.red
                                  : Colors.transparent,
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tooth.id.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            SizedBox(
              height: 30,
            ),
            ...selectedToothDisease.keys
                .where((toothId) => selectedToothDisease[toothId] != null)
                .map((toothId) {
              return _buildToothInfoSection(toothId);
            }).toList(),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        height: 20,
      ),
    ]));
  }

  Widget _buildToothInfoSection(int toothId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tooth $toothId',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _selectedImages[toothId] != null
              ? Stack(
                  children: [
                    Image.file(
                      File(_selectedImages[toothId]!.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.remove(toothId);
                          });
                        },
                        child: Container(
                          color: Colors.red,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  dashPattern: [8, 4],
                  strokeWidth: 2,
                  child: GestureDetector(
                    onTap: () => _showImageSourceBottomSheet(context, toothId),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: Text('Upload Image'),
                      ),
                    ),
                  ),
                ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                   controller: toothControllers[toothId],
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Tooth Description',
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(color: Colors.black),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: AvatarGlow(
                          animate: _isListning,
                          duration: Duration(milliseconds: 1500),
                          glowColor: appTheme.black900,
                          repeat: true,
                          glowRadiusFactor: 0.2,
                          child: GestureDetector(
                            onTapDown: (details) async {
                              await _startListening(toothId);
                            },
                            onTapUp: (details) {
                              _stopListening();
                            },
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? appTheme.teal600
                                  : appTheme.blue50,
                              radius: 12,
                              child: Icon(
                                _isListning ? Icons.mic : Icons.mic_none,
                                color: Colors.black,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      )),
                  onChanged: (value) {
                    setState(() {
                      toothDescriptions[toothId] = value;
                    });
                  },
                  maxLines: 4,
                  // initialValue: toothDescriptions[toothId],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.black,
            thickness: 0.7,
          )
        ],
      ),
    );
  }
}

class Tooth {
  final int id;
  double? bottom, top, right, left;
  String? selectedDisease;
  String? diseaseDescription;

  Tooth({required this.id, this.left, this.top, this.bottom, this.right});
}
