// import 'dart:convert';

import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/profile_view.dart';
import 'package:Dentepic/screens/admin/doctor_data_screen/doctor_data_screen.dart';
import 'package:Dentepic/screens/admin/notifications_screen/notifications_screen.dart';
import 'package:Dentepic/screens/admin/students_data_screen/students_data_screen.dart';
import 'package:Dentepic/screens/admin/upload/upload_diesease_data.dart';
import 'package:Dentepic/screens/admin/upload/upload_student_data.dart';
import 'package:Dentepic/screens/auth/login/login_tab.dart';
import 'package:Dentepic/services/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

const Color inActiveIconColor = Color(0xFFB6B6B6);
Color activeColor = appTheme.blue50;

class AdminBottom extends StatefulWidget {
  final String userId;

  const AdminBottom({Key? key, required this.userId}) : super(key: key);

  static String routeName = "/";

  @override
  State<AdminBottom> createState() => _InitScreenState();
}

class _InitScreenState extends State<AdminBottom> {
  int currentSelectedIndex = 0;
  late User user;
  String profileImageUrl = '';

  late List<Widget Function(String)> pages; // Declare pages as a late variable

  @override
  void initState() {
    super.initState();
    // Initialize pages using userId
    pages = [
      (userId) => StudentsDataScreen(),
      (userId) => DoctorDataScreen(),
      (userId) => NotificationsScreen(),
    ];
    PermissionHandler().requestPermissions();
    user = FirebaseAuth.instance.currentUser!;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection(pref.getString('userRole').toString())
        .doc(user.uid)
        .get();

    setState(() {
      profileImageUrl = userDoc['profileImageUrl']??ImageConstant.drProfile;
    });
  }

  updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? appTheme.blue50
            : Colors.black,
        leading: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Builder(
            // Use Builder widget to obtain a context within the scope of Scaffold
            builder: (BuildContext context) {
              return Container(
                width: 60,
                height: 60,
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Scaffold.of(context)
                        .openDrawer(); // Use Scaffold.of(context) within the Builder
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.h),
            child: CustomImageView(
              imagePath:profileImageUrl ,
              height: 45.adaptSize,
              width: 45.adaptSize,
              radius: BorderRadius.circular(
                28.h,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileView()));
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : appTheme.teal600,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 40),
            ListTile(
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the drawer
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text(
                'Upload Student\'s Data',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UploadStudentDataScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file, color: Colors.black),
              title: Text(
                'Upload Disease Data',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UploadDiseaseDataScreen()));
              },
            ),
            SizedBox(
              height: 450,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () async {
                // Show an alert dialog to confirm logout
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to logout ?",
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            // Clear SharedPreferences
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            await pref.clear();
                            // Navigate to LoginTab screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginTab()),
                              (route) => false,
                            );
                          },
                          child: Text(
                            "Yes",
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Dismiss the alert dialog
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "No",
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: pages[currentSelectedIndex](widget.userId),
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/person.svg",
              height: 27,
              width: 25,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/person.svg",
              height: 27,
              width: 25,
              colorFilter: ColorFilter.mode(
                activeColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Student Data",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/doctor.svg",
              height: 27,
              width: 25,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/doctor.svg",
              height: 27,
              width: 25,
              colorFilter: ColorFilter.mode(
                activeColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Doctors Data",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/noti.svg",
              height: 27,
              width: 25,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/noti.svg",
              height: 27,
              width: 25,
              colorFilter: ColorFilter.mode(
                activeColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Notifications",
          ),
        ],
      ),
    );
  }

  //  /// Section Widget
  // Widget _appBar(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 35.h),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         CustomImageView(
  //           imagePath: ImageConstant.imgImage6,
  //           height: 40.adaptSize,
  //           width: 40.adaptSize,
  //           margin: EdgeInsets.only(
  //             top: 9.v,
  //             bottom: 8.v,
  //           ),
  //         ),
  //         CustomImageView(
  //           imagePath: ImageConstant.imgEllipse3,
  //           height: 57.adaptSize,
  //           width: 57.adaptSize,
  //           radius: BorderRadius.circular(
  //             28.h,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
