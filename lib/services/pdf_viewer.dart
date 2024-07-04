// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class MyPdfViewer extends StatefulWidget {
//   final String file;
//   const MyPdfViewer({super.key, required this.file});

//   @override
//   State<MyPdfViewer> createState() => _MyPdfViewerState();
// }

// class _MyPdfViewerState extends State<MyPdfViewer> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: const Text("PDF View"),
//         ),
//         body:
//             // link fron internet
//             SfPdfViewer.file(File(widget.file))
//         // SfPdfViewer.asset("asset/proposal.pdf"),
//         );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MyPdfViewer extends StatefulWidget {
  final String file;
  const MyPdfViewer({Key? key, required this.file}) : super(key: key);

  @override
  State<MyPdfViewer> createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  late File _pdfFile;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final bytes = File(widget.file).readAsBytesSync();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/my_pdf_file.pdf');
    await file.writeAsBytes(bytes);
    setState(() {
      _pdfFile = file;
    });
  }

  void _sharePdf() {
    Share.shareUri([_pdfFile.path] as Uri);
    }

  void _downloadPdf() async {
    final bytes = await _pdfFile.readAsBytes();
    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/my_pdf_file.pdf');
    await file.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF downloaded to ${file.path}'),
      duration: Duration(seconds: 3),
    ));
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("PDF View"),
      ),
      body: _pdfFile != null
          ? SfPdfViewer.file(_pdfFile)
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _downloadPdf();
        },
        icon: Icon(Icons.share),
        label: Text('Share'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
