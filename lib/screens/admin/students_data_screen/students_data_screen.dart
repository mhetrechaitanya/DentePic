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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder<Map<String, int>>(
          future: fetchStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show circular indicator while loading
              return Center(
                child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,),
              );
            } else if (snapshot.hasError) {
              // Handle error
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Handle empty data
              return Center(
                child: Text('No data available'),
              );
            } else {
              // Once data is fetched, show the students data
              return _buildStudentsData(snapshot.data!);
            }
          },
        ),
      ),
    );
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

  Widget _buildStudentsData(Map<String, int> students) {
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
                  _buildStudentsDataList(students),
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

          return StudentsdataItemWidget(
            schoolCollege: college,
            numOfStudents: numOfStudents,
            doctorAssigned: "not",
          );
        },
      ),
    );
  }
}
