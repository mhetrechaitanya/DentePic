// ignore_for_file: deprecated_member_use
import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/doctor/all%20steps/components/scanner_front.dart';
import 'package:Dentepic/screens/doctor/all%20steps/step_2/select_tooth_disease.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:flutter/material.dart';

class UploadTeethImagePage extends StatefulWidget {
  final Map<String, dynamic> studentInfo;
  const UploadTeethImagePage({Key? key, required this.studentInfo})
      : super(
          key: key,
        );

  @override
  ScannerFrontTabContainerPageState createState() =>
      ScannerFrontTabContainerPageState();
}

class ScannerFrontTabContainerPageState extends State<UploadTeethImagePage>
    with TickerProviderStateMixin {
  late TabController tabviewController;
  String? frontImagePath; // Path of the front image
  String? upperImagePath; // Path of the upper image
  String? lowerImagePath;

  void receiveImagePath(String label, String imagePath) {
    switch (label) {
      case 'Front':
        setState(() {
          frontImagePath = imagePath;
        });
        break;
      case 'Upper':
        setState(() {
          upperImagePath = imagePath;
        });
        break;
      case 'Lower':
        setState(() {
          lowerImagePath = imagePath;
        });
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    tabviewController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            // backgroundColor: appTheme.blue50,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? appTheme.blue50
                : Colors.black,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new))),
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
                                    'Step 1: Upload Teeth Image',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : appTheme.blue50,
                                    ),
                                  ),
                                  SizedBox(height: 30.v),
                                  // _buildStepContent(),
                                  SizedBox(
                                    height: 54.v,
                                    width: 324.h,
                                    child: TabBar(
                                      controller: tabviewController,
                                      labelPadding: EdgeInsets.zero,
                                      labelColor: Colors.white,
                                      unselectedLabelColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : appTheme.blue50,
                                      indicatorColor: Colors.white,
                                      tabs: [
                                        Tab(
                                          child: Text(
                                            "Front",
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            "Upper",
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            "Lower",
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 436.v,
                                    child: TabBarView(
                                      controller: tabviewController,
                                      children: [
                                        ScannerFrontPage(
                                          lable: 'Front',
                                          studentId: widget.studentInfo['id'],
                                          imagePathCallback: (path) =>
                                              receiveImagePath('Front', path),
                                        ),
                                        ScannerFrontPage(
                                          lable: 'Upper',
                                          studentId: widget.studentInfo['id'],
                                          imagePathCallback: (path) =>
                                              receiveImagePath('Upper', path),
                                        ),
                                        ScannerFrontPage(
                                          lable: 'Lower',
                                          studentId: widget.studentInfo['id'],
                                          imagePathCallback: (path) =>
                                              receiveImagePath('Lower', path),
                                        )
                                      ],
                                    ),
                                  )
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
            if (frontImagePath != null &&
                upperImagePath != null &&
                lowerImagePath != null) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 500),
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin:
                            const Offset(1.0, 0.0), // Offset for right to left
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return SelectDiseasesStep(
                      studentInfo: widget.studentInfo,
                      frontImagePath: frontImagePath,
                      upperImagePath: upperImagePath,
                      lowerImagePath: lowerImagePath,
                    );
                  },
                ),
              );
            } else {
              Dialogs.showSnackbar(context,
                  "Please select images for Front, Upper, and Lower before proceeding.");
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

  /// Section Widget
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
            padding: EdgeInsets.only(
              right: 32.h,
              bottom: 2.v,
            ),
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
}
