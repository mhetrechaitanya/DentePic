import 'dart:io';
import 'package:flutter/services.dart';
import 'file_handle_api.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

class PdfApi {
  Future<Uint8List> _fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<File> generate(Map<String, dynamic> studentsData) async {

    final robotoRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    // final robotoBold =
    //     pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    final frontImage = await _fetchImageBytes(studentsData['Front']);
    final lowerImage = await _fetchImageBytes(studentsData['Lower']);
    final upperImage = await _fetchImageBytes(studentsData['Upper']);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Student Information',
                style: pw.TextStyle(fontSize: 24, font: robotoRegular)),
            pw.SizedBox(height: 16),
            pw.Padding(
              padding: pw.EdgeInsets.all(16),
              child: pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(3),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Name',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${studentsData['full_name']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Email',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${studentsData['email']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Blood Group',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${studentsData['blood_group']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Gender',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${studentsData['gender']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Age',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${studentsData['age']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Mobile Number',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${studentsData['mobile']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // pw.Text('Name: ${studentsData['full_name']}',
            //     style: pw.TextStyle(font: robotoRegular)),
            // pw.Text('Email: ${studentsData['email']}',
            //     style: pw.TextStyle(font: robotoRegular)),
            // pw.Text('Blood Group: ${studentsData['blood_group']}',
            //     style: pw.TextStyle(font: robotoRegular)),
            // pw.Text('Gender: ${studentsData['gender']}',
            //     style: pw.TextStyle(font: robotoRegular)),
            // pw.Text('Age: ${studentsData['age']}',
            //     style: pw.TextStyle(font: robotoRegular)),
            // pw.Text('Mobile Number: ${studentsData['mobile']}',
            //     style: pw.TextStyle(font: robotoRegular)),
            // pw.SizedBox(height: 24),
            // pw.Text('Images',
            //     style: pw.TextStyle(fontSize: 24, font: robotoRegular)),
            // pw.SizedBox(height: 16),
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
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
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

    return FileHandleApi.saveDocument(name: 'student_${studentsData['full_name']}.pdf', pdf: pdf);
  }
}
