// import 'dart:convert';

// ignore_for_file: unused_local_variable

import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/auth/login/login_tab.dart';
import 'package:Dentepic/screens/doctor/home/home_page.dart';
import 'package:Dentepic/screens/doctor/profile_view_doctor.dart';
import 'package:Dentepic/services/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

const Color inActiveIconColor = Color(0xFFB6B6B6);
Color activeColor = appTheme.blue50;

class DoctorBottom extends StatefulWidget {
  final String userId;

  const DoctorBottom({Key? key, required this.userId}) : super(key: key);

  static String routeName = "/";

  @override
  State<DoctorBottom> createState() => _InitScreenState();
}

class _InitScreenState extends State<DoctorBottom> {
  int currentSelectedIndex = 0;

  late List<Widget Function(String)> pages; // Declare pages as a late variable

  @override
  void initState() {
    super.initState();
    // Initialize pages using userId
    pages = [
      (userId) => DoctorHomeScreen(),
      (userId) => ProfileViewDoctor(),
      (userId) => ProfileViewDoctor(),
    ];
     PermissionHandler().requestPermissions();
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
        backgroundColor: Colors.transparent,
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
        // Padding(
        //     padding: EdgeInsets.only(left: 20.h, top: 20.h),
        //     child: SizedBox(
        //       width: 100,
        //       height: 100,
        //       child: CustomImageView(
        //       imagePath: ImageConstant.imgEllipse3,
        //       height: 50,
        //       width: 40,
        //       radius: BorderRadius.circular(
        //         28.h,
        //       ),
        //       onTap: () async {
        //         SharedPreferences pref= await SharedPreferences.getInstance();
        //         pref.clear();
        //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginTab()));
        //       },
        //     ),
        //     )
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[300],
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
            // SizedBox(
            //   height: 450,
            // ),
            ListTile(
              leading: Icon(Icons.logout,color: Colors.black),
              title: Text('Logout',style: TextStyle(color: Colors.black),),
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
                      content: Text("Are you sure you want to logout?",
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          )),
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
                          child: Text("Yes",
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              )),
                        ),
                        TextButton(
                          onPressed: () {
                            // Dismiss the alert dialog
                            Navigator.of(context).pop();
                          },
                          child: Text("No",
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              )),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.logout,color: Colors.black),
            //   title: Text('Ssend Notification',style: TextStyle(color: Colors.black),),
            //   onTap: () async { NotificationService()
            //   .showNotification(title: 'Welcome To Dentepic', body: 'Hello there! Get ready to experience Dentepic\'s amazing features.', id: 0);},
            // ),
          ],
        ),
      ),
      // ),

      body: pages[currentSelectedIndex](widget.userId),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DoctorBottom(
                    userId: '',
                  )));
        },
        child: Icon(
          Icons.home,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          size: 32,
        ),
        backgroundColor: appTheme.blue50,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/Group.svg",
              height: 27,
              width: 25,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              "assets/icons/Group.svg",
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
            icon: Image.asset(
              ImageConstant.imgEllipse3,
              height: 30,
              width: 30,
            ),
            activeIcon: Image.asset(
              ImageConstant.imgEllipse3,
              height: 32,
              width: 32,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
