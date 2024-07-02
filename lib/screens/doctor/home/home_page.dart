import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/screens/doctor/all%20steps/step_1/upload_teeth_img.dart';
import 'package:Dentepic/widgets/custom_search_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHomeScreen extends StatefulWidget {
  DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  DoctorHomeScreenState createState() => DoctorHomeScreenState();
}

class DoctorHomeScreenState extends State<DoctorHomeScreen> {
  TextEditingController searchController = TextEditingController();
  String doctorName = ''; // Initialize with actual doctor's name
  String instituteName = '';
  int completedStudentsCount = 0;

  Future<void> fetchDoctorDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String doctorId =
        pref.getString('id').toString(); // Set the actual doctor's ID here
    DocumentSnapshot doctorSnapshot =
        await firestore.collection('doctors').doc(doctorId).get();
    setState(() {
      doctorName = doctorSnapshot['fullName'] ??
          'Not Found'; // Assuming 'fullName' is the field in doctor document
      instituteName = doctorSnapshot['assignedInstitute'] ??
          ''; // Assuming 'assignedInstitute' is the field in doctor document
    });
  }

  Future<List<Map<String, dynamic>>> fetchStudents() async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // String doctorId =
    //     pref.getString('id').toString();
    // DocumentSnapshot doctorSnapshot =
    //     await firestore.collection('doctors').doc(doctorId).get();
    // String assignedInstitute = doctorSnapshot['assignedInstitute']??'';

    // Now, fetch students of the assigned institute
    QuerySnapshot snapshot = await firestore
        .collection('students')
        .where('institute', isEqualTo: instituteName)
        .where('checkupStatus', isEqualTo: false)
        .get();

    List<Map<String, dynamic>> students = [];
    completedStudentsCount = 0;
    snapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> studentData =
          document.data() as Map<String, dynamic>;
      studentData['id'] =
          document.id.toString(); // Add the document ID to the student data
      students.add(studentData);

      // Count completed students
      if (studentData['checkupStatus'] == true) {
        completedStudentsCount++;
      }
    });

    return students;
  }

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : appTheme.blue50),
              );
            } else if (snapshot.hasError) {
              // Handle error
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              // Once data is fetched, show the students data
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 25.v),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.h),
                      child: CustomSearchView(
                        controller: searchController,
                        hintText: "Search by school/college",
                        hintStyle: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey // Grey color for light theme
                                  : Colors.white, // White color for dark theme
                        ),
                        autofocus: false,
                        textStyle: CustomTextStyles.titleSmallGray200,
                        fillColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white // Grey color for light theme
                                : Colors.black,
                      ),
                    ),
                    SizedBox(height: 24.v),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello Dr. $doctorName,",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : appTheme.blue50),
                            ),
                            Text(
                              "Today’s Status ",
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : appTheme.blue50),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 31.v),
                    _buildCampStatusTile(context, snapshot.data ?? []),
                    SizedBox(height: 37.v),
                    instituteName.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 40),
                                Lottie.asset(
                                  'assets/lotties/Animation - 1718981723245.json',
                                  width: 100,
                                  height: 100,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Institute Not Assigned Yet..!",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : snapshot.hasData && snapshot.data!.isNotEmpty
                            ? Column(
                                children: [
                                  _buildHeadingRow(context),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 10.v),
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> student =
                                          snapshot.data![index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UploadTeethImagePage(
                                                studentInfo: student,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildStudentRow(
                                          context,
                                          dynamicText1: (index + 1).toString(),
                                          dynamicText2:
                                              student['full_name'] ?? 'Unknown',
                                          dynamicText3:
                                              student['age']?.toString() ??
                                                  'N/A',
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 40,
                                    ),
                                    // Icon(
                                    //   Icons.warning,
                                    //   color: Colors.black,
                                    //   size: 40,
                                    // ),
                                    Lottie.asset(
                                      'assets/lotties/Animation - 1718981723245.json',
                                      width: 100,
                                      height: 100,
                                      // fit: BoxFit.fill,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Institute Not Assigned Yet..!",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ],
                                )),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCampStatusTile(
      BuildContext context, List<Map<String, dynamic>> students) {
    int totalStudentsCount = students.length;
    return Container(
      width: 359.h,
      margin: EdgeInsets.symmetric(horizontal: 30.h),
      padding: EdgeInsets.symmetric(
        horizontal: 10.h,
        vertical: 13.v,
      ),
      decoration: AppDecoration.fillTeal.copyWith(
          borderRadius: BorderRadiusStyle.roundedBorder13,
          color: Theme.of(context).brightness == Brightness.light
              ? appTheme.teal600
              : appTheme.blue50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 9.h,
              // right: 79.h,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.black,
                  size: 23,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15.h,
                    top: 14.v,
                    bottom: 7.v,
                  ),
                  child: Text(
                    instituteName.isEmpty
                        ? 'Camp Status'
                        : "Check-up Patients:  $completedStudentsCount/$totalStudentsCount",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 9.v),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(left: 9.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 23,
                  ),
                  Expanded(
                    child: Container(
                      width: 263.h,
                      margin: EdgeInsets.only(left: 15.h),
                      child: Text(
                        instituteName.isEmpty ? 'Not Assigned' : instituteName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 5.v)
        ],
      ),
    );
  }

  Widget _buildHeadingRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 29.h,
        right: 35.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 1.v),
            child: Text(
              "Roll no.",
              style: theme.textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 12),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20.h,
              bottom: 1.v,
            ),
            child: Text(
              "Name",
              style: theme.textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 12),
            ),
          ),
          Spacer(),
          Text(
            "Age",
            style: theme.textTheme.labelMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _buildStudentRow(
    BuildContext context, {
    required String dynamicText1,
    required String dynamicText2,
    required String dynamicText3,
  }) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.fromLTRB(36.h, 21.v, 36.h, 22.v),
      decoration: AppDecoration.blackBorder.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? appTheme.teal600
              : appTheme.blue50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.v),
            child: Text(
              dynamicText1,
              style: CustomTextStyles.titleMediumBlack
                  .copyWith(color: Colors.black),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 25.h,
              top: 1.v,
            ),
            child: Text(
              dynamicText2,
              style: CustomTextStyles.titleMediumBlack.copyWith(
                color: theme.colorScheme.shadow.withOpacity(1),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(
              top: 1.v,
              right: 1.h,
            ),
            child: Text(
              dynamicText3,
              style: CustomTextStyles.titleMediumBlack.copyWith(
                color: theme.colorScheme.shadow.withOpacity(1),
              ),
            ),
          )
        ],
      ),
    );
  }
}
