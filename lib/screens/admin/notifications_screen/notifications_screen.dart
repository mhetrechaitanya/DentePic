import 'package:Dentepic/core/app_export.dart';
import 'package:Dentepic/services/pdf_viewer.dart';
import 'package:Dentepic/widgets/custom_search_view.dart';
import 'package:flutter/services.dart';
import 'widgets/notifications_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
    // fetchStudentsReport('');
    loadFonts();
  }

  Future<void> loadFonts() async {
    robotoRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    robotoBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  }

  Future<void> fetchInstitutes() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('institutes').get();
    setState(() {
      institutes = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  // Future<void> fetchStudents() async {
  //   if (selectedInstitute == null) return;
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('students')
  //       .where('institute', isEqualTo: selectedInstitute)
  //       .get();
  //   setState(() {
  //     students = snapshot.docs
  //         .map((doc) => doc.data() as Map<String, dynamic>)
  //         .toList();

  //     filteredStudents = students;
  //   });
  // }
  Future<void> fetchStudents() async {
    if (selectedInstitute == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('institute', isEqualTo: selectedInstitute)
        .get();

    setState(() {
      students = snapshot.docs.map((doc) {
        // Convert document data to a Map and add an 'id' field
        Map<String, dynamic> studentData = doc.data() as Map<String, dynamic>;
        studentData['id'] = doc.id;
        return studentData;
      }).toList();

      // Initially, filteredStudents is the same as studentsR
      filteredStudents = students;
    });
  }

  Future<Map<String, dynamic>> fetchStudentsReport(String studentID) async {
    // if (selectedInstitute == null) return;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentID)
        .get();
    // setState(() {
    Map<String, dynamic> studentData = snapshot.data() as Map<String, dynamic>;
    // filteredStudents = students;
    // });
    // print("lafsuhksdh;gkshdf;ghsd;ghoisdfhg[oie]");

    // print(snapshot.data());
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

  Future<Uint8List> _fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  void generatePdf(String studentId) async {
    Map<String, dynamic> studentsData = await fetchStudentsReport(studentId);
    final pdf = pw.Document();
    final frontImage = await _fetchImageBytes(studentsData['Front']);
    final lowerImage = await _fetchImageBytes(studentsData['Lower']);
    final upperImage = await _fetchImageBytes(studentsData['Upper']);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Student Information',
                style: pw.TextStyle(fontSize: 24, font: robotoRegular)),
            pw.SizedBox(height: 16),
            pw.Text('Name: ${studentsData['full_name']}',
                style: pw.TextStyle(font: robotoRegular)),
            pw.Text('Email: ${studentsData['email']}',
                style: pw.TextStyle(font: robotoRegular)),
            pw.Text('Blood Group: ${studentsData['blood_group']}',
                style: pw.TextStyle(font: robotoRegular)),
            pw.Text('Gender: ${studentsData['gender']}',
                style: pw.TextStyle(font: robotoRegular)),
            pw.Text('Age: ${studentsData['age']}',
                style: pw.TextStyle(font: robotoRegular)),
            pw.Text('Mobile Number: ${studentsData['mobile']}',
                style: pw.TextStyle(font: robotoRegular)),
            pw.SizedBox(height: 24),
            pw.Text('Images',
                style: pw.TextStyle(fontSize: 24, font: robotoRegular)),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Container(
                    child: pw.Image(
                      pw.MemoryImage(frontImage),
                      width: 80,
                      height: 80,
                    ),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(25))),
                pw.Container(
                    child: pw.Image(
                      pw.MemoryImage(lowerImage),
                      width: 80,
                      height: 80,
                    ),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(25))),
                pw.Container(
                    child: pw.Image(
                      pw.MemoryImage(upperImage),
                      width: 80,
                      height: 80,
                    ),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(25))),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text('Teeth Information',
                style: pw.TextStyle(fontSize: 24, font: robotoRegular)),
            pw.SizedBox(height: 16),
            for (var tooth in studentsData['teeth'])
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment. spaceBetween,
                    children: [
                      pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,

                        children: [
                          pw.Text('Tooth ID: ${tooth['toothId']}',
                              style: pw.TextStyle(font: robotoRegular)),
                          pw.Text('Name: ${tooth['disease']}',
                              style: pw.TextStyle(font: robotoRegular)),
                          pw.Text('Description: ${tooth['description']}',
                              style: pw.TextStyle(font: robotoRegular)),
                        ],
                      ),
                      pw.Container(
                          child: pw.Image(
                            pw.MemoryImage(upperImage),
                            width: 80,
                            height: 80,
                          ),
                          decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(25))),
                    ],
                  ),
                  // pw.Image(pw.MemoryImage()),
                  pw.SizedBox(height: 16),
                ],
              ),
            pw.SizedBox(height: 24),
            pw.Text('Treatment',
                style: pw.TextStyle(fontSize: 24, font: robotoRegular)),
            pw.SizedBox(height: 16),
            pw.Text(studentsData['treatment'],
                style: pw.TextStyle(font: robotoRegular)),
          ],
        ),
      ),
    );

    // Save the PDF and open it
    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/student_${studentsData['full_name']}.pdf');
    await file.writeAsBytes(await pdf.save());

    if (await file.exists()) {
      _openFile(context, file.path);
    } else {
      print('File does not exist');
    }
  }

  Future<void> _openFile(BuildContext context, String filePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyPdfViewer(file: filePath),
      ),
    );
  }

//   Future<Map<String, String>> fetchStoredImages(String studentId) async {
//   try {
//     CollectionReference toothImageCollection = FirebaseFirestore
//         .instance
//         .collection('students')
//         .doc(studentId)
//         .collection('toothImage');

//     DocumentSnapshot docSnapshot = await toothImageCollection.doc('images').get();

//     if (docSnapshot.exists) {
//       // Document exists, fetch the data
//       Map<String, dynamic> imageData = docSnapshot.data() as Map<String, dynamic>;

//       // Ensure that required fields exist and are not null
//       String frontUrl = imageData['Front'] ?? '';
//       String lowerUrl = imageData['Lower'] ?? '';
//       String upperUrl = imageData['Upper'] ?? '';

//       // Constructing the result map as { 'front': 'url', 'lower': 'url', 'upper': 'url' }
//       Map<String, String> imageUrls = {
//         'front': frontUrl,
//         'lower': lowerUrl,
//         'upper': upperUrl,
//       };

//       return imageUrls;
//     } else {
//       // Document does not exist
//       print('No images found for student with ID: $studentId');
//       return {};
//     }
//   } catch (e) {
//     print('Error fetching images: $e');
//     return {};
//   }
// }

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
