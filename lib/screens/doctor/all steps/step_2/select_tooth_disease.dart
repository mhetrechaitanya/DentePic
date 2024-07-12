import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/doctor/all%20steps/components/selecttoothpage.dart';
import 'package:flutter/material.dart';

class SelectDiseasesStep extends StatefulWidget {
  final Map<String, dynamic> studentInfo;
  final String? frontImagePath, upperImagePath, lowerImagePath;
  const SelectDiseasesStep(
      {Key? key,
      required this.studentInfo,
      required this.frontImagePath,
      required this.upperImagePath,
      required this.lowerImagePath})
      : super(
          key: key,
        );

  @override
  ScannerFrontTabContainerPageState createState() =>
      ScannerFrontTabContainerPageState();
}

class ScannerFrontTabContainerPageState extends State<SelectDiseasesStep>
    with TickerProviderStateMixin {
  late TabController tabviewController;
  @override
  void initState() {
    super.initState();
    tabviewController = TabController(length: 2, vsync: this);
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
              SizedBox(height: 10.v),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 36.v),
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
                                    'Step 2: Select Tooth & Diseases',
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
                                            "Adult",
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            "Child",
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 500.v,
                                    child: TabBarView(
                                      controller: tabviewController,
                                      children: [
                                        SelectToothPage(
                                          studentInfo: widget.studentInfo,
                                          frontImagePath: widget.frontImagePath,
                                          upperImagePath: widget.upperImagePath,
                                          lowerImagePath: widget.lowerImagePath,
                                        ),
                                        SelectToothPage(
                                          studentInfo: widget.studentInfo,
                                          frontImagePath: widget.frontImagePath,
                                          upperImagePath: widget.upperImagePath,
                                          lowerImagePath: widget.lowerImagePath,
                                        )
                                      ],
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
}
