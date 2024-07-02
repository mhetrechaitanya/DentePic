import 'dart:developer';

import 'package:Dentepic/model/user.dart';
import 'package:Dentepic/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//uploading students manual data

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static UserModel me = UserModel(
    uid: user.uid,
    displayName: user.displayName.toString(),
    email: user.email.toString(),
    photoURL: user.photoURL.toString(),
  );

  // to return current user
  static User get user => auth.currentUser!;

  static Future<bool> storeStudentDataToDB(
    context,
    String fullName,
    String? gender,
    String? bloodGroup,
    String institute,
    String age,
    String email,
    String mobile,

  ) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define the collection reference
      CollectionReference students = firestore.collection('students');

      // Add a new document with a generated ID
      await students.add({
        'full_name': fullName,
        'email': email,
        'gender': gender,
        'blood_group': bloodGroup,
        'institute': institute,
        'age': age,
        'mobile': mobile,
        'checkupStatus': false,
      });

      print("Student data stored successfully!");
      Dialogs.showSnackbar(context, "Successfully added student");
      return true;
    } catch (error) {
      print("Failed to store student data: $error");
      Dialogs.showSnackbar(context, "Failed to store student data: $error");
      return false;
    }
  }

//uploading disease manual data

  static Future<bool> uploadDiseaseDataToDB(
    context,
    String diseaseName,
    String description,
  ) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define the collection reference
      CollectionReference diseases = firestore.collection('diseases');

      // Add a new document with a generated ID
      await diseases.add({
        'diseaseName': diseaseName,
        'description': description,
      });

      print("Disease data stored successfully!");
      Dialogs.showSnackbar(context, "Successfully added disease");
      return true;
    } catch (error) {
      print("Failed to store disease data: $error");
      Dialogs.showSnackbar(context, "Failed to store disease data: $error");
      return false;
    }
  }

//Saving Student Data By Excel Sheet
  static Future<void> readCsvAndStoreInFirebase(BuildContext context) async {
    // Pick CSV file
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    // Check if file is picked
    if (result == null) return;

    // Get file path and name
    final filePath = result.files.first.path!;
    final fileName = result.files.first.name;

    // Show alert dialog to confirm file upload
    bool confirmUpload = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Upload',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Do you want to upload the following file?',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
              SizedBox(height: 8),
              Text(
                fileName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // No button tapped
              },
              child: Text('No',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Yes button tapped
              },
              child: Text('Yes',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
            ),
          ],
        );
      },
    );

    if (!confirmUpload) return;

    // Show saving dialog while saving data
    Dialogs.showProgressBar(context);

    try {
      // Open file for reading
      final input = File(filePath).openRead();

      // Transform CSV data into a list of maps
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      // Define the Firestore collection reference
      CollectionReference studentsCollection =
          FirebaseFirestore.instance.collection('students');
      CollectionReference institutesCollection =
          FirebaseFirestore.instance.collection('institutes');

      // Iterate through the list of maps and add each student to Firestore
      for (var studentData in fields) {
        String instituteName = studentData[4]!;

        // Check if the institute exists
        QuerySnapshot instituteSnapshot = await institutesCollection
            .where('name', isEqualTo: instituteName)
            .get();

        if (instituteSnapshot.docs.isEmpty) {
          // Add new institute with status 'not assigned'
          await institutesCollection.add({
            'name': instituteName,
            'status': 'not assigned',
            'doctor_assigned': '',
          });
        }

        // Add student data to 'students' collection
        await studentsCollection.add({
          'full_name': studentData[0]!,
          'email': studentData[1]!,
          'gender': studentData[2]!,
          'blood_group': studentData[3]!,
          'institute': instituteName,
          'age': studentData[5]!,
          'mobile': studentData[6]!,
          'checkupStatus': false,

          // Add other fields as needed
        });
      }

      // Hide saving dialog and show success message after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Hide saving dialog
        Dialogs.showSnackbar(context, "Successfully added students");
      });
    } catch (error) {
      // Hide saving dialog and show error message after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Hide saving dialog
        print('Error importing data: $error');
        Dialogs.showSnackbar(context, "Failed to store students data: $error");
      });
    }
  }

  static Future<void> readCsvAndStoreDiseaseInFirebase(
      BuildContext context) async {
    // Pick CSV file
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    // Check if file is picked
    if (result == null) return;

    // Get file path and name
    final filePath = result.files.first.path!;
    final fileName = result.files.first.name;

    // Show alert dialog to confirm file upload
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Upload',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Do you want to upload the following file?',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
              SizedBox(height: 8),
              Text(
                fileName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // No button tapped
              },
              child: Text('No',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Yes button tapped
              },
              child: Text('Yes',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  )),
            ),
          ],
        );
      },
    ).then((value) async {
      if (value == true) {
        // Show saving dialog while saving data
        Dialogs.showProgressBar(context);

        try {
          // Open file for reading
          final input = File(filePath).openRead();

          // Transform CSV data into a list of maps
          final fields = await input
              .transform(utf8.decoder)
              .transform(const CsvToListConverter())
              .toList();

          // Define the Firestore collection reference
          CollectionReference studentsCollection =
              FirebaseFirestore.instance.collection('diseases');

          // Iterate through the list of maps and add each student to Firestore
          fields.forEach((studentData) async {
            await studentsCollection.add({
              'diseaseName': studentData[0]!,
              'description': studentData[1]!,

              // Add other fields as needed
            });
          });

          // Hide saving dialog and show success message after 2 seconds
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop(); // Hide saving dialog
            Dialogs.showSnackbar(context, "Successfully added diseases data");
          });
        } catch (error) {
          // Hide saving dialog and show error message after 2 seconds
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop(); // Hide saving dialog
            print('Error importing data: $error');
            Dialogs.showSnackbar(
                context, "Failed to store diseases data: $error");
          });
        }
      }
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    // for accessing firebase messaging (Push Notification)
  }

  // for getting current user info
  static Future<UserModel> getSelfInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        return UserModel.fromMap(userData.data()!);
      } else {
        // User data doesn't exist in Firestore, handle this case accordingly
        throw Exception('User data not found in Firestore');
      }
    } else {
      // User is not logged in, handle this case accordingly
      throw Exception('User is not logged in');
    }
  }
}
