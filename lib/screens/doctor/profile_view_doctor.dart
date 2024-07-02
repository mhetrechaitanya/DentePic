import 'package:Dentepic/color_extension.dart';
import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/icon_item_row.dart';
import 'package:Dentepic/theme/theme_notifer,dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // profileImageUrl = userDoc['profileImageUrl'] ?? ImageConstant.imgEllipse3;
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

  @override
  Widget build(BuildContext context) {
        var themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkMode = themeNotifier.themeMode == ThemeMode.dark;
    return Scaffold(
      // backgroundColor: appTheme.teal600,
      // appBar: AppBar(
      //   title: Text(
      //     'Profile',
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontSize: 20,
      //       fontWeight: FontWeight.w700,
      //     ),
      //   ),
      //   centerTitle: true,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(children: [
            const SizedBox(
              height: 20,
            ),
            CircleAvatar(
              radius: 50, // Adjust the radius as needed
              backgroundColor: appTheme.teal600, // Border color
              child: CircleAvatar(
                radius: 48, // Adjust the radius as needed
                backgroundImage:
                    // NetworkImage(profileImageUrl),
                    AssetImage(ImageConstant.imgEllipse3), // Image asset
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
