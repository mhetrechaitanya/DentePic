import 'dart:io';
import 'package:flutter/services.dart';
import 'file_handle_api.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:http/http.dart' as http;

class PdfApiDr {

  Future<File> generate(
      Map<String, dynamic> studentInfo,
      String? frontImagePath,
      String? upperImagePath,
      String? lowerImagePath,
      List<Map<String, dynamic>> selectedTeethData,
      String treatmentDescription) async {
    final robotoRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final robotoBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    // final frontImage = await frontImagePath!.readAsBytes();
    // final lowerImage = lowerImagePath;
    // final upperImage = upperImagePath;
    final frontImageFile = File(frontImagePath.toString());
    final lowerImageFile = File(lowerImagePath.toString());
    final upperImageFile = File(upperImagePath.toString());

    // Reading image bytes
    final frontImage = await frontImageFile.readAsBytes();
    final lowerImage = await lowerImageFile.readAsBytes();
    final upperImage = await upperImageFile.readAsBytes();
    final pdf = pw.Document();
      // Chunk the teeth data into rows of three
    List<List<Map<String, dynamic>>> teethChunks = chunkList(selectedTeethData, 3);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text('Student Dental Report',
                  style: pw.TextStyle(fontSize: 16, font: robotoBold)),
            ),
            pw.SizedBox(height: 20),
            pw.Padding(
              padding: pw.EdgeInsets.all(0),
              child: pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
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
                        child: pw.Text('${studentInfo['full_name']}',
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
                        child: pw.Text('${studentInfo['email']}',
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
                        child: pw.Text('${studentInfo['blood_group']}',
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
                        child: pw.Text('${studentInfo['gender']}',
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
                        child: pw.Text('${studentInfo['age']}',
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
                        child: pw.Text('${studentInfo['mobile']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 0),
              child: pw.Text('Teeth Images', style: pw.TextStyle(fontSize: 14, font: robotoBold,)),
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Container(
                    child: pw.Image(pw.MemoryImage(frontImage),
                        width: 80, height: 80, fit: pw.BoxFit.cover),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(25))),
                pw.Container(
                    child: pw.Image(pw.MemoryImage(lowerImage),
                        width: 80, height: 80, fit: pw.BoxFit.cover),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(25))),
                pw.Container(
                    child: pw.Image(pw.MemoryImage(upperImage),
                        width: 80, height: 80, fit: pw.BoxFit.cover),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(25))),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Teeth Information',
                style: pw.TextStyle(fontSize: 14, font: robotoBold)),
            pw.SizedBox(height: 8),
              for (var chunk in teethChunks)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: chunk.map((tooth) {
                  return pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Tooth: ${tooth['toothId']}',
                            style: pw.TextStyle(font: robotoRegular)),
                        pw.Text('Description: ${tooth['description']}',
                            style: pw.TextStyle(font: robotoRegular)), 
                      ],
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 20),
            pw.Text('Treatment',
                style: pw.TextStyle(fontSize: 14, font: robotoBold)),
            pw.SizedBox(height: 10),
            pw.Text(treatmentDescription,
                style: pw.TextStyle(font: robotoRegular)),
          ],
        ),
      ),
    );

    return FileHandleApi.saveDocument(
        name: 'student_${studentInfo['full_name']}.pdf', pdf: pdf);
  }
   List<List<Map<String, dynamic>>> chunkList(List<Map<String, dynamic>> list, int chunkSize) {
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
