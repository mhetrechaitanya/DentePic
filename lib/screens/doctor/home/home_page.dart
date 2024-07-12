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
  int totalStudentsCount = 0;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    fetchDoctorDetailsAndStudents();
  }

  void _onSearchChanged() {
    setState(() {
      filteredStudents = students.where(
        (student) => student['full_name'].toLowerCase().contains(
          searchController.text.toLowerCase(),
        ),
      ).toList();
    });
  }

  Future<void> fetchDoctorDetailsAndStudents() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String doctorId = pref.getString('id').toString();

    // Fetch doctor details
    DocumentSnapshot doctorSnapshot =
        await firestore.collection('doctors').doc(doctorId).get();
    doctorName = doctorSnapshot['fullName'] ?? 'Not Found';
    instituteName = doctorSnapshot['assignedInstitute'] ?? '';

    // Fetch students data
    if (instituteName.isNotEmpty) {
      QuerySnapshot snapshot = await firestore
          .collection('students')
          .where('institute', isEqualTo: instituteName)
          .get();

      List<Map<String, dynamic>> fetchedstudents = [];
      completedStudentsCount = 0;
      totalStudentsCount = snapshot.docs.length;

      for (var document in snapshot.docs) {
        Map<String, dynamic> studentData = document.data() as Map<String, dynamic>;
        studentData['id'] = document.id;

        if (studentData['checkupStatus'] == true) {
          completedStudentsCount++;
        } else {
          fetchedstudents.add(studentData);
        }
      }

      students = fetchedstudents;
      filteredStudents = fetchedstudents;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: ColorSchemes.appGradient,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : appTheme.blue50,
                  ),
                )
              : _buildDoctorHomeScreen(),
        ),
      ),
    );
  }

  Widget _buildDoctorHomeScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 25.v),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.h),
            child: CustomSearchView(
              controller: searchController,
              hintText: "Search by student's name",
              hintStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey
                    : Colors.white,
              ),
              autofocus: false,
              textStyle: CustomTextStyles.titleSmallGray200,
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
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
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,
                    ),
                  ),
                  Text(
                    "Today’s Status",
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 31.v),
          _buildCampStatusTile(context, filteredStudents),
          SizedBox(height: 37.v),
          instituteName.isEmpty
              ? _buildNoInstituteAssigned()
              : filteredStudents.isNotEmpty
                  ? _buildStudentsList(context)
                  : _buildAllStudentsChecked(),
        ],
      ),
    );
  }

  Widget _buildCampStatusTile(
      BuildContext context, List<Map<String, dynamic>> students) {
    return Container(
      width: 359.h,
      margin: EdgeInsets.symmetric(horizontal: 30.h),
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 13.v),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
        color: Theme.of(context).brightness == Brightness.light
            ? appTheme.teal600
            : appTheme.blue50,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 9.h),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.black,
                  size: 23,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.h, top: 14.v, bottom: 7.v),
                  child: Text(
                    instituteName.isEmpty
                        ? 'Camp Status'
                        : "Check-up Patients:  $completedStudentsCount/$totalStudentsCount",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
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
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.v),
        ],
      ),
    );
  }

  Widget _buildNoInstituteAssigned() {
    return Padding(
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
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAllStudentsChecked() {
    return Padding(
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
            "All Students Checkup Completed..!",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context) {
    return Column(
      children: [
        _buildHeadingRow(context),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filteredStudents.length,
          separatorBuilder: (context, index) => SizedBox(height: 10.v),
          itemBuilder: (context, index) {
            Map<String, dynamic> student = filteredStudents[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadTeethImagePage(
                      studentInfo: student,
                    ),
                  ),
                );
              },
              child: _buildStudentRow(
                context,
                dynamicText1: (index + 1).toString(),
                dynamicText2: student['full_name'] ?? 'Unknown',
                dynamicText3: student['age']?.toString() ?? 'N/A',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeadingRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 29.h, right: 35.h),
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
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.h, bottom: 1.v),
            child: Text(
              "Name",
              style: theme.textTheme.labelMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          Spacer(),
          Text(
            "Age",
            style: theme.textTheme.labelMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              fontSize: 12,
            ),
          ),
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
            : appTheme.blue50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.v),
            child: Text(
              dynamicText1,
              style: CustomTextStyles.titleMediumBlack.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.h, top: 1.v),
            child: Text(
              dynamicText2,
              style: CustomTextStyles.titleMediumBlack.copyWith(
                color: theme.colorScheme.shadow.withOpacity(1),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(top: 1.v, right: 1.h),
            child: Text(
              dynamicText3,
              style: CustomTextStyles.titleMediumBlack.copyWith(
                color: theme.colorScheme.shadow.withOpacity(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
