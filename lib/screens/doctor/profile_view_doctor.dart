import 'dart:io';

import 'package:Dentepic/color_extension.dart';
import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/icon_item_row.dart';
import 'package:Dentepic/theme/theme_notifer,dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileViewDoctor extends StatefulWidget {
  const ProfileViewDoctor();

  @override
  State<ProfileViewDoctor> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileViewDoctor> {
  bool isActive = false;
  bool isEditing = false;
  late User user;
  late TextEditingController nameController;
  String userName = 'Name';
  String userEmail = 'Email';
  String profileImageUrl = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    nameController = TextEditingController();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection(pref.getString('userRole').toString())
        .doc(user.uid)
        .get();

    setState(() {
      userName = userDoc['fullName'] ?? 'Name';
      userEmail = user.email ?? 'Email';
      profileImageUrl = userDoc['profileImageUrl'];
      nameController.text = userName;
    });
  }

  Future<void> saveUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance
        .collection(pref.getString('userRole').toString())
        .doc(pref.getString('id'))
        .update({
      'fullName': nameController.text,
    });

    setState(() {
      userName = nameController.text;
      isEditing = false;
    });
  }

  Future<void> updateProfilePic() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance
        .collection(pref.getString('userRole').toString())
        .doc(pref.getString('id'))
        .set({
      'profileImageUrl': profileImageUrl, // Update profile image URL
    }, SetOptions(merge: true));

    setState(() {
      userName = nameController.text;
      isEditing = false;
    });
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child('profile_images').child('${user.uid}.jpg');

    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    updateProfilePic();

    setState(() {
      profileImageUrl = imageUrl;
      isLoading = false;
    });
  }

  void _showImageSourceBottomSheet(
    BuildContext context,
  ) {
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

  Future<void> _pickImage(ImageSource path) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: path);

    if (image != null) {
      File imageFile = File(image.path);
      await _uploadImage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkMode = themeNotifier.themeMode == ThemeMode.dark;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(children: [
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                _showImageSourceBottomSheet(
                    context); // Call method to pick image from gallery
              },
              child: Stack(
                children: [
                  if (profileImageUrl.isNotEmpty)
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: appTheme.teal600,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(profileImageUrl),
                      ),
                    ),
                  if (profileImageUrl.isEmpty)
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: appTheme.teal600,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: AssetImage(ImageConstant.drProfile),
                      ),
                    ),
                  if (isLoading)
                    Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  width: 200,
                  height: 40,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: nameController,
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
            const SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userEmail,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                if (isEditing) {
                  saveUserData();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.only(
                    top: 6, bottom: 6, left: 14, right: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: TColor.border.withOpacity(0.15),
                  ),
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : appTheme.teal600,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  isEditing ? 'Save' : 'Edit profile',
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 8),
                    child: Text(
                      "General",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TColor.border.withOpacity(0.1),
                      ),
                      color: appTheme.teal600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // IconItemRow(
                        //   title: "Security",
                        //   icon: Icon(Icons.security, color: Colors.white),
                        //   value: "FaceID",
                        // ),
                        IconItemSwitchRow(
                          title: "Dark Mode",
                          icon: Icon(Icons.dark_mode, color: Colors.black),
                          // value: isActive,
                          // didChange: (newVal) {
                          //   setState(() {
                          //     isActive = newVal;
                          //   });
                          // },
                          value: isDarkMode,
                          didChange: (newVal) {
                            themeNotifier.toggleTheme(newVal);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
