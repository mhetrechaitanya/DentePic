// ignore_for_file: unused_label

import 'package:Dentepic/core/app_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({Key? key, required this.doctorId})
      : super(key: key);

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  String? selectedInstitute;
  List<String> institutes = [];
 

  @override
  void initState() {
    super.initState();
    fetchInstitutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchDoctorDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('Doctor not found'));
          } else {
            Map<String, dynamic>? doctorData =
                snapshot.data!.data()! as Map<String, dynamic>?;
            print(doctorData!);
            return _buildDoctorDetails(context, doctorData);
          }
        },
      ),
    );
  }

  

  Future<DocumentSnapshot> fetchDoctorDetails() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // print(widget.doctorId);
    DocumentReference doctorRef =
        firestore.collection('doctors').doc(widget.doctorId);
    DocumentSnapshot snapshot = await doctorRef.get();
    return snapshot;
  }

  Future<void> fetchInstitutes() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('institutes').get();
    setState(() {
      institutes = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  Future<void> assignInstitute() async {
    if (selectedInstitute != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference doctorRef =
          firestore.collection('doctors').doc(widget.doctorId);
      await doctorRef.update({
        'status': 'AS',
        'assignedInstitute': selectedInstitute,
      });
      Navigator.of(context).pop(true);
    }
  }

  Future<void> removeAssignedInstitute(String doctorId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference doctorRef = firestore.collection('doctors').doc(doctorId);

    try {
      // Update the doctor document
      await doctorRef.update({
        'assignedInstitute': FieldValue.delete(), // Remove assigned institute
        'status': 'AV' // Set status to Available
      });

      print(
          'Assigned institute removed and status set to AV for doctor $doctorId');
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating doctor: $e');
    }
  }

  Widget _buildDoctorDetails(
      BuildContext context, Map<String, dynamic> doctorData) {
    String assignedInstitute = doctorData['assignedInstitute'] ?? '';

    return Padding(
      padding: EdgeInsets.all(10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(context, doctorData),
          SizedBox(height: 10.v),
          assignedInstitute == ''
              ? _buildAssigneInstitute(institutes)
              : _buildAssignedInstituteInfo(
                  assignedInstitute, 0, 0),
          SizedBox(height: 20.v),
        ],
      ),
    );
  }

  Widget _buildUserProfile(
      BuildContext context, Map<String, dynamic> studentInfo) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.symmetric(
        horizontal: 32.h,
        vertical: 15.v,
      ),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Name",
                style: CustomTextStyles.titleMediumGray20002,
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Text(
                  'Dr. ' + '${studentInfo['fullName'].toString()}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.v),

          // Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Status",
                style: CustomTextStyles.titleMediumGray20002,
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Text(
                  studentInfo['status'].toString(),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.v),

          // Email Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Email",
                style: CustomTextStyles.titleMediumGray20002,
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Text(
                  studentInfo['email'].toString(),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedInstituteInfo(
      String assignedInstitute, int totalStudents, int checkUpCompletedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            'Assigned Institute:',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10.v),
        Container(
          padding: EdgeInsets.all(16.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.h),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignedInstitute,
                style:
                    theme.textTheme.titleLarge?.copyWith(color: Colors.black),
              ),
              SizedBox(height: 10.v),
              Text(
                'Total Students: $totalStudents',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Checkup Completed: ${checkUpCompletedCount}',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Checkup Remaining: ${totalStudents - checkUpCompletedCount}',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: SizedBox(
                  width: 150.h,
                  height: 150.h,
                  child: CircularProgressIndicator(
                    value: 50,
                    strokeWidth: 30.h,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        removeAssignedInstitute(widget.doctorId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              'Remove',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            )
                          ],
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneInstitute(List<String> institutes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            'Assigne Institute:',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10.v),
        Container(
          padding: EdgeInsets.all(16.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.h),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Institute to Assign: ',
                style:
                    theme.textTheme.titleLarge?.copyWith(color: Colors.black),
              ),
              SizedBox(height: 10.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  hint: Text('Select Institute'),
                  value: selectedInstitute,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  borderRadius: BorderRadius.circular(12),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      selectedInstitute = newValue!;
                    });
                  },
                  items: institutes.map((institute) {
                    return DropdownMenuItem<String>(
                      value: institute,
                      child: Text(institute),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: assignInstitute,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              'Assign',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            )
                          ],
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
