import 'dart:io';

import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/doctor/all%20steps/step_3/treatmentplan.dart';
import 'package:Dentepic/widgets/dialogs.dart';
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
  bool get wantKeepAlive => true;
  SpeechToText speechToText = SpeechToText();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Disease> diseases = [];
  String? selectedDisease;
  Map<int, String?> selectedToothDisease = {};
  Map<int, XFile?> _selectedImages = {};
  Map<String, List<int>> diseaseToothIds = {};
  Map<String, int> diseaseTextFieldsCount = {};
  final List<Tooth> teeth = [
    // Upper Teeth (Right to Left)
    Tooth(id: 1, left: 0.1, top: 0.4),
    Tooth(id: 2, left: 0.12, top: 0.35),
    Tooth(id: 3, left: 0.14, top: 0.28),
    Tooth(id: 4, left: 0.15, top: 0.22),
    Tooth(id: 5, left: 0.165, top: 0.17),
    Tooth(id: 6, left: 0.198, top: 0.13),
    Tooth(id: 7, left: 0.247, top: 0.105),
    Tooth(id: 8, left: 0.3, top: 0.09),
    Tooth(id: 9, left: 0.36, top: 0.092),

    // Upper Teeth (Left to Right)
    Tooth(id: 10, left: 0.74, top: 0.105),
    Tooth(id: 11, left: 0.802, top: 0.13),
    Tooth(id: 12, left: 0.835, top: 0.17),
    Tooth(id: 13, left: 0.85, top: 0.22),
    Tooth(id: 14, left: 0.865, top: 0.28),
    Tooth(id: 15, left: 0.88, top: 0.35),
    Tooth(id: 16, left: 0.9, top: 0.4),

    // Lower Teeth (Left to Right)
    Tooth(id: 17, left: 0.9, top: 0.6),
    Tooth(id: 18, left: 0.88, top: 0.65),
    Tooth(id: 19, left: 0.865, top: 0.72),
    Tooth(id: 20, left: 0.85, top: 0.78),
    Tooth(id: 21, left: 0.835, top: 0.83),
    Tooth(id: 22, left: 0.802, top: 0.87),
    Tooth(id: 23, left: 0.74, top: 0.895),
    Tooth(id: 24, left: 0.68, top: 0.9),

    // Lower Teeth (Right to Left)
    Tooth(id: 25, left: 0.36, top: 0.9),
    Tooth(id: 26, left: 0.3, top: 0.895),
    Tooth(id: 27, left: 0.247, top: 0.87),
    Tooth(id: 28, left: 0.198, top: 0.83),
    Tooth(id: 29, left: 0.165, top: 0.78),
    Tooth(id: 30, left: 0.15, top: 0.72),
    Tooth(id: 31, left: 0.14, top: 0.65),
    Tooth(id: 32, left: 0.1, top: 0.6),
  ];

  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int toothId) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages[toothId] = pickedFile;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDiseases();
    teeth.forEach((tooth) {
      selectedToothDisease[tooth.id] =
          null; // Initialize selected disease to null for each tooth
    });
  }

  void handleToothSelection(
      String toothId, String disease, String description, String imagePath) {
    // Add selected tooth data to list
    selectedTeethData.add({
      'toothId': toothId,
      'disease': disease,
      'description': description,
      'imagePath': imagePath,
    });
  }

  Future<void> _fetchDiseases() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('diseases').get();
      setState(() {
        diseases = snapshot.docs.map((doc) {
          return Disease(
            name: doc['diseaseName'],
            description: doc['description'],
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching diseases: $e');
      Fluttertoast.showToast(msg: "Error fetching diseases");
    }
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
          String diseaseName = selectedToothDisease[toothId]!;
          String diseaseDescription = diseases
              .firstWhere((disease) => disease.name == diseaseName)
              .description;
          String imagePath = '';
          if (_selectedImages[toothId] != null) {
            imagePath = await _uploadImageToStorage(
                File(_selectedImages[toothId]!.path));
          }

          handleToothSelection(
              toothId.toString(), diseaseName, diseaseDescription, imagePath);
        }
      }
        if (selectedTeethData.isNotEmpty) {
      DocumentReference studentDocRef = _firestore
          .collection('students')
          .doc(widget.studentInfo['id']);

      // CollectionReference teethDataCollectionRef = studentDocRef.collection('teethData');

      // QuerySnapshot teethDataSnapshot = await teethDataCollectionRef.limit(1).get();

      DocumentSnapshot docSnapshot = await studentDocRef.get();

 
      if (docSnapshot.exists){
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
                selectedTeethData: selectedTeethData,
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
                      Color toothColor =
                          _getColorForDisease(tooth.selectedDisease ?? '');

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
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: toothColor,
                              border: Border.all(
                                color: Colors.grey, // Optional: Add border
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
              String? selectedDiseaseName = selectedToothDisease[toothId];
              Disease? selectedDisease = diseases.firstWhere(
                  (disease) => disease.name == selectedDiseaseName,
                  orElse: () => Disease(name: '', description: ''));

              return Column(
                children: [
                  Container(
                    // height:
                    //     250, // You used `250.v`, which may require additional setup for vertical units
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: TextFormField(
                      initialValue: selectedDisease.description,
                      style: TextStyle(color: Colors.black),
                      enabled: false, // Disable editing
                      decoration: InputDecoration(
                        labelText: selectedDisease.name,
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
                        // hintStyle: TextStyle(color: Colors.black),
                      ),
                      maxLines: 5,
                      // expands: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _pickImage(toothId); // Pass toothId to _pickImage method
                    },
                    child: SizedBox(
                      height: 170.adaptSize,
                      width: 170.adaptSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_selectedImages[toothId] == null)
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Select Image",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                            ),
                          if (_selectedImages[toothId] != null)
                            Image.file(
                              File(_selectedImages[toothId]!.path),
                              height: 170,
                              width: 170,
                              fit: BoxFit.cover,
                            ),
                          _isUploading
                              ? CircularProgressIndicator()
                              : Align(
                                  alignment: Alignment.center,
                                  child: DottedBorder(
                                    color: appTheme.black900,
                                    padding: EdgeInsets.only(
                                      left: 2.h,
                                      top: 2.v,
                                      right: 2.h,
                                      bottom: 2.v,
                                    ),
                                    strokeWidth: 2.h,
                                    dashPattern: [4, 4],
                                    child: Container(
                                      height: 170.adaptSize,
                                      width: 170.adaptSize,
                                      decoration: BoxDecoration(),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              );
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

  void _onToothTap(int toothId) {
    final selectedTooth = teeth.firstWhere((tooth) => tooth.id == toothId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Disease',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? appTheme.black900
                  : appTheme.whiteA700,
            ),
          ),
          content: DropdownButtonFormField<String>(
            value: selectedToothDisease[selectedTooth.id],
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? appTheme.black900
                  : appTheme.whiteA700,
            ),
            hint: Text(
              'Select Disease',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? appTheme.black900
                    : appTheme.whiteA700,
              ),
            ),
            onChanged: (newValue) {
              setState(() {
                selectedTooth.selectedDisease = newValue;
                selectedToothDisease[selectedTooth.id] = newValue;

                // Update diseaseToothIds map to associate toothId with disease
                if (newValue != null) {
                  if (diseaseToothIds.containsKey(newValue)) {
                    if (!diseaseToothIds[newValue]!
                        .contains(selectedTooth.id)) {
                      diseaseToothIds[newValue]!.add(selectedTooth.id);
                    }
                  } else {
                    diseaseToothIds[newValue] = [selectedTooth.id];
                  }
                }

                Navigator.of(context).pop();
              });
            },
            items: diseases.map((disease) {
              return DropdownMenuItem<String>(
                value: disease.name,
                child: Text(
                  disease.name,
                  style: TextStyle(
                    color: _getColorForDisease(disease.name),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getColorForDisease(String diseaseName) {
    switch (diseaseName) {
      case 'Dental caries':
        return Colors.brown; // Light brown
      case 'Deep Dental caries':
        return Colors.brown.shade800; // Dark brown
      case 'Periapical abscess':
        return Colors.red; // Red
      case 'Gingivitis':
        return Colors.pink; // Pink
      case 'Root pieces':
        return Colors.grey; // Grey
      case 'Fractured tooth':
        return Colors.grey.shade700; // Dark grey
      case 'Mobile tooth':
        return Colors.amber; // Yellow
      case 'Fluorosis':
        return Colors.blue; // Blue
      case 'High frenal attachment':
        return Colors.pink.shade100; // Light pink
      case 'Enamel hypoplasia':
        return Colors.yellow; // Yellow
      case 'Pericoronitis':
        return Colors.redAccent; // Red accent
      case 'Space infection':
        return Colors.deepOrange; // Deep orange
      case 'Over retained teeth':
        return Colors.grey.shade500; // Medium grey
      case 'Missing teeth':
        return Colors.grey.shade300; // Light grey
      case 'Orthodontic malocclusion':
        return Colors.purple; // Purple
      default:
        return Colors.black; // Default to black if not found
    }
  }
}

class Disease {
  final String name;
  final String description;

  Disease({required this.name, required this.description});
}

class Tooth {
  final int id;
  double? bottom, top, right, left;
  String? selectedDisease;
  String? diseaseDescription;

  Tooth({required this.id, this.left, this.top, this.bottom, this.right});
}
