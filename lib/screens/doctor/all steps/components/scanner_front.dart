import 'dart:io';
import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/widgets/custom_elevated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class ScannerFrontPage extends StatefulWidget {
  final String lable, studentId;
  final Function(String) imagePathCallback;
  const ScannerFrontPage(
      {Key? key,
      required this.lable,
      required this.studentId,
      required this.imagePathCallback})
      : super(
          key: key,
        );

  @override
  ScannerFrontPageState createState() => ScannerFrontPageState();
}

class ScannerFrontPageState extends State<ScannerFrontPage>
    with AutomaticKeepAliveClientMixin<ScannerFrontPage> {
  @override
  bool get wantKeepAlive => true;
  XFile? _selectedImage;

  bool _isUploading = false;
  bool _uploadSuccess = false;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage(ImageSource path) async {
    final XFile? pickedFile = await _picker.pickImage(source: path);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        handleImageSelection(pickedFile.path);
      });
    }
  }
Future<void> _uploadImage() async {
  setState(() {
    _isUploading = true;
    _uploadSuccess = false;
  });

  try {
    if (_selectedImage == null) return;

    File file = File(_selectedImage!.path);
    String imageName = "${widget.lable}_${DateTime.now().millisecondsSinceEpoch}.jpg";

    UploadTask task = _storage.ref().child('images/$imageName').putFile(file);

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      print(task.snapshot);
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    });

    await task.whenComplete(() async {
      // Get the download URL
      String downloadURL = await _storage.ref('images/$imageName').getDownloadURL();

      DocumentReference toothImageCollection = FirebaseFirestore
          .instance
          .collection('students')
          .doc(widget.studentId);
      
      //     .collection('toothImage');

      // // Check if the document exists
      // DocumentReference documentRef = toothImageCollection.doc('images');
      DocumentSnapshot docSnapshot = await toothImageCollection.get();

      if (docSnapshot.exists) {
        // Update the existing document
        await toothImageCollection.update({widget.lable: downloadURL});
      } else {
        // Create a new document
        await toothImageCollection.set({widget.lable: downloadURL});
      }

      setState(() {
        _isUploading = false;
        _uploadSuccess = true;
      });
      print('Upload complete!');
    });
  } catch (e) {
    print('Error uploading image: $e');
    setState(() {
      _isUploading = false;
      _uploadSuccess = false;
    });
  }
}



  void handleImageSelection(String selectedPath) {
    widget.imagePathCallback(selectedPath);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: _buildScrollView(context),
      ),
    );
  }

  /// Section Widget
  Widget _buildScrollView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.h),
            padding: EdgeInsets.fromLTRB(31.h, 38.v, 31.h, 39.v),
            decoration:
                AppDecoration.fillwhite.copyWith(color: appTheme.teal600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 28.v),
                GestureDetector(
                  onTap: () {
                    _showImageSourceBottomSheet(context);
                  },
                  child: SizedBox(
                    height: 170.adaptSize,
                    width: 170.adaptSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedImage == null)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Select Image",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ),
                        if (_selectedImage != null)
                          Image.file(
                            File(_selectedImage!.path),
                            height: 170.adaptSize,
                            width: 170.adaptSize,
                            fit: BoxFit.cover,
                          ),
                        _isUploading
                            ? Container(
                                height: 170.adaptSize,
                                width: 170.adaptSize,
                                alignment: Alignment.center,
                                child: _uploadSuccess
                                    ? Lottie.asset(
                                        'assets/lotties/done.json',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.contain,
                                      )
                                    : LinearProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          appTheme.teal600,
                                        ),
                                      ),
                              )
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
                SizedBox(height: 57.v),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onPressed: _uploadImage,
                        text: "Upload",
                        margin: EdgeInsets.only(left: 30.h, right: 30.h),
                        showIcon: true,
                        leftIcon: Container(
                          margin: EdgeInsets.only(right: 6.h),
                          child: Icon(Icons.upload, color:Colors.white,size: 20,)
                        ),
                        buttonTextStyle: theme.textTheme.labelLarge!.copyWith(
                          fontSize: 12
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
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
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
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
}
