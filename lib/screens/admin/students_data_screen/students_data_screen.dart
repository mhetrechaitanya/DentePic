import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/widgets/custom_search_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/studentsdata_item_widget.dart';
import 'package:flutter/material.dart';

class StudentsDataScreen extends StatefulWidget {
  StudentsDataScreen({Key? key}) : super(key: key);

  @override
  _StudentsDataScreenState createState() => _StudentsDataScreenState();
}

class _StudentsDataScreenState extends State<StudentsDataScreen> {
  TextEditingController searchController = TextEditingController();
  Map<String, int> _allStudents = {};
  Map<String, int> _filteredStudents = {};
  Map<String, String> _assignedDoctors = {};
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    fetchStudentsAndDoctors();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredStudents = Map.fromEntries(
        _allStudents.entries.where(
          (entry) => entry.key.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
        ),
      );
    });
  }

  Future<void> fetchStudentsAndDoctors() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, int> students = await fetchStudents();
    Map<String, String> doctors = await fetchAssignedDoctors();
    setState(() {
      _allStudents = students;
      _filteredStudents = students;
      _assignedDoctors = doctors;
      _isLoading = false;
    });
  }

  Future<Map<String, int>> fetchStudents() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference studentsCollection = firestore.collection('students');
    QuerySnapshot snapshot = await studentsCollection.get();

    Map<String, int> instituteMap = {};
    snapshot.docs.forEach((DocumentSnapshot document) {
      String institute = document['institute'] ?? '';
      instituteMap.update(institute, (value) => value + 1, ifAbsent: () => 1);
    });

    return instituteMap;
  }

  Future<Map<String, String>> fetchAssignedDoctors() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference institutesCollection =
        firestore.collection('institutes');
    QuerySnapshot snapshot = await institutesCollection.get();

    Map<String, String> doctorMap = {};
    snapshot.docs.forEach((DocumentSnapshot document) {
      String institute = document['name'] ?? '';
      String doctor = document['doctor_assigned'] ?? 'not';
      if (doctor.isEmpty) doctor = 'Not Assigned';
      doctorMap[institute] = doctor;
    });

    return doctorMap;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            : _buildStudentsData(),
      ),
    );
  }

  Widget _buildStudentsData() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          SizedBox(height: 25.v),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.h),
            child: CustomSearchView(
              controller: searchController,
              hintText: "Search by school/college",
              hintStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey // Grey color for light theme
                    : Colors.white, // White color for dark theme
              ),
              autofocus: false,
              textStyle: CustomTextStyles.titleSmallGray200,
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white // Grey color for light theme
                  : Colors.black,
            ),
          ),
          SizedBox(height: 24.v),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 36.h),
              child: Text(
                "Students Data",
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          SizedBox(height: 15.v),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStudentsDataList(_filteredStudents),
                  SizedBox(height: 340.v),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsDataList(Map<String, int> students) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.h),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 20.v,
          );
        },
        itemCount: students.length,
        itemBuilder: (context, index) {
          String college = students.keys.elementAt(index);
          int numOfStudents = students.values.elementAt(index);
          String doctorAssigned = _assignedDoctors[college] ?? 'not';

          return StudentsdataItemWidget(
            schoolCollege: college,
            numOfStudents: numOfStudents,
            doctorAssigned: doctorAssigned,
          );
        },
      ),
    );
  }
}
