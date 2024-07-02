import 'package:Dentepic/screens/auth/login/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:Dentepic/core/app_export.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({Key? key})
      : super(
          key: key,
        );

  @override
  LoginTabState createState() => LoginTabState();
}

class LoginTabState extends State<LoginTab> with TickerProviderStateMixin {
  late TabController tabviewController;

  @override
  void initState() {
    super.initState();
    tabviewController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
      // child: Column(
      //   children: [
      child: Column(
        children: [
          SizedBox(height: 37.v),
          CustomImageView(
            imagePath: ImageConstant.imgImage3,
            height: 180.v,
          ),
          SizedBox(height: 53.v),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Welcome To Dentepic",
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 41.v),
                Container(
                  height: 54.v,
                  // width: 380.h,
                  margin: EdgeInsets.symmetric(horizontal: 20.h),
                  child: TabBar(
                    controller: tabviewController,
                    labelPadding: EdgeInsets.zero,
                    labelColor: appTheme.black900,
                    labelStyle: TextStyle(
                      fontSize: 17.fSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelColor: appTheme.teal600,
                    unselectedLabelStyle: TextStyle(
                      fontSize: 17.fSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: appTheme.teal600,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25.h),
                        topLeft: Radius.circular(25.h),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appTheme.teal600.withOpacity(0.25),
                          spreadRadius: 2.h,
                          blurRadius: 2.h,
                          offset: Offset(
                            0,
                            2,
                          ),
                        ),
                      ],
                    ),
                    tabs: [
                      Tab(
                        child: Text(
                          "Admin",
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Doctor",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 500.v,
                  child: TabBarView(
                    controller: tabviewController,
                    children: [
                      AdminLoginPage(),
                      AdminLoginPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        //   ),
        // ],
      ),
    )));
  }

  /// Section Widget
  Widget _buildTabBarView(BuildContext context) {
    return SizedBox(
      height: 600.v,
      child: TabBarView(
        controller: tabviewController,
        children: [
          AdminLoginPage(),
          AdminLoginPage(),
        ],
      ),
    );
  }
}
