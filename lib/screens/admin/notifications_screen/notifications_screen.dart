import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/services/pdf_service.dart';
import 'package:Dentepic/widgets/custom_search_view.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import '../../../services/file_handle_api.dart';
import 'widgets/notifications_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;

class NotificationsScreen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<NotificationsScreen> {
  String? selectedInstitute;
  List<String> institutes = [];
  List<Map<String, dynamic>> students = [];
  // List<Map<String, dynamic>> studentsData = [];
  List<Map<String, dynamic>> filteredStudents = [];
  TextEditingController searchController = TextEditingController();
  pw.Font? robotoRegular;
  pw.Font? robotoBold;

  @override
  void initState() {
    super.initState();
    fetchInstitutes();
  }

  Future<void> fetchInstitutes() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('institutes').get();
    setState(() {
      institutes = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> fetchStudents() async {
    if (selectedInstitute == null) return;
    Dialogs.showProgressBar(context);
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('institute', isEqualTo: selectedInstitute)
        .get();

    setState(() {
      students = snapshot.docs.map((doc) {
        Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;
        studentData['id'] = doc.id;
        return studentData;
      }).toList();
      filteredStudents = students;
    });
    Navigator.pop(context);
  }

  Future<Map<String, dynamic>> fetchStudentsReport(String studentID) async {
    // if (selectedInstitute == null) return;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentID)
        .get();
    Map<String, dynamic> studentData = snapshot.data() as Map<String, dynamic>;
    return studentData;
  }

  void searchStudents(String query) {
    setState(() {
      filteredStudents = students
          .where((student) =>
              student['full_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void generatePdf(String studentId) async {
    Dialogs.showProgressBar(context);
    Map<String, dynamic> studentsData = await fetchStudentsReport(studentId);
    print(studentsData);
    if (studentsData['checkupStatus'] == true) {
      PdfApi pdf = PdfApi();
      final pdfFile = await pdf.generate(studentsData);
      FileHandleApi.openFile(pdfFile);
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.warning,
                  size: 55,
                  color: Colors.black,
                ),
                // SizedBox(height: 10),
                // Text('Alert'),
              ],
            ),
            content: Text(
              'The student\'s test has not been done yet.',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                hint: Text('Select Institute'),
                value: selectedInstitute,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: appTheme.blueGray400,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: appTheme.blueGray400,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: appTheme.blueGray400,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedInstitute = value;
                    fetchStudents();
                  });
                },
                items: institutes.map((String institute) {
                  return DropdownMenuItem<String>(
                    value: institute,
                    child: Text(institute),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 20,
              ),
              CustomSearchView(
                controller: searchController,
                hintText: "Search Student",
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
                onChanged: searchStudents,
              ),
              SizedBox(
                height: 20,
              ),
              _buildNotifications(context, filteredStudents)
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildNotifications(
      BuildContext context, List<Map<String, dynamic>> filteredStudents) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.h),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filteredStudents.length,
        separatorBuilder: (
          context,
          index,
        ) {
          return SizedBox(
            height: 8.v,
          );
        },
        itemBuilder: (context, index) {
          final student = filteredStudents[index];
          return GestureDetector(
            onTap: (() {
              generatePdf(student['id']);
            }),
            child: NotificationsItemWidget(
              student: student,
            ),
          );
        },
      ),
    );
  }
}
