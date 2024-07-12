// ignore_for_file: unused_label

import 'package:Dentepic/core/app_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
  bool isLoading = false;
  Map<String, dynamic>? doctorData;
  int totalStudents = 0;
  int checkUpCompletedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
    fetchInstitutes();
  }

  Future<void> fetchDoctorDetails() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference doctorRef =
        firestore.collection('doctors').doc(widget.doctorId);
    DocumentSnapshot snapshot = await doctorRef.get();

    if (snapshot.exists) {
      setState(() {
        doctorData = snapshot.data() as Map<String, dynamic>?;
        // Fetch the institute's student data if the doctor has an assigned institute
        if (doctorData!['assignedInstitute'] != null) {
          fetchInstituteStudentData(doctorData!['assignedInstitute']);
        } else {
          isLoading = false;
        }
      });
    } else {
      setState(() {
        doctorData = null;
        isLoading = false;
      });
    }
  }

  Future<void> fetchInstituteStudentData(String instituteName) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore
        .collection('students')
        .where('institute', isEqualTo: instituteName)
        .get();

    setState(() {
      totalStudents = snapshot.docs.length;
      checkUpCompletedCount =
          snapshot.docs.where((doc) => doc['checkupCompleted'] == true).length;
      isLoading = false;
    });
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
      if (selectedInstitute == doctorData!['assignedInstitute']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor is already assigned to this institute.')),
        );
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference doctorRef =
          firestore.collection('doctors').doc(widget.doctorId);
      DocumentReference instituteRef =
          firestore.collection('institutes').doc(selectedInstitute);

      try {
        // Update doctor document
        await doctorRef.update({
          'status': 'AS',
          'assignedInstitute': selectedInstitute,
        });

        // Update institute document
        await instituteRef.update({
          'assignedDoctor': {
            'id': widget.doctorId,
            'fullName': doctorData!['fullName'],
            'email': doctorData!['email'],
          },
        });

        setState(() {
          doctorData!['assignedInstitute'] = selectedInstitute;
          isLoading = true;
        });
        fetchInstituteStudentData(selectedInstitute!);
      } catch (e) {
        print('Error assigning institute: $e');
      }
    }
  }

  Future<void> removeAssignedInstitute(String doctorId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference doctorRef = firestore.collection('doctors').doc(doctorId);

    try {
      // Update the doctor document
      await doctorRef.update({
        'assignedInstitute': FieldValue.delete(),
        'status': 'AV',
      });

      // Remove assigned doctor from institute document
      if (doctorData!['assignedInstitute'] != null) {
        DocumentReference instituteRef = firestore
            .collection('institutes')
            .doc(doctorData!['assignedInstitute']);
        await instituteRef.update({
          'assignedDoctor': FieldValue.delete(),
        });
      }

      setState(() {
        doctorData!['assignedInstitute'] = null;
        totalStudents = 0;
        checkUpCompletedCount = 0;
      });
    } catch (e) {
      print('Error updating doctor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : appTheme.blue50,
              ),
            )
          : doctorData == null
              ? Center(child: Text('Doctor not found'))
              : _buildDoctorDetails(context, doctorData!),
    );
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
              ? _buildAssignInstitute(institutes)
              : _buildAssignedInstituteInfo(
                  assignedInstitute, totalStudents, checkUpCompletedCount),
          SizedBox(height: 20.v),
        ],
      ),
    );
  }

  Widget _buildUserProfile(
      BuildContext context, Map<String, dynamic> doctorInfo) {
    return Container(
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
                  'Dr. ' + '${doctorInfo['fullName'].toString()}',
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
                  doctorInfo['status'].toString(),
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
                  doctorInfo['email'].toString(),
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
              SizedBox(height: 10.v),
              Text(
                'Checkup Completed: $checkUpCompletedCount',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              SizedBox(height: 10.v),
              Text(
                'Checkup Remaining: ${totalStudents - checkUpCompletedCount}',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
              ),
              SizedBox(height: 20.v),
              Center(
                child: SizedBox(
                  width: 150.h,
                  height: 150.h,
                  child: _buildPieChart(totalStudents, checkUpCompletedCount),
                ),
              ),
              SizedBox(height: 40.v),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      removeAssignedInstitute(widget.doctorId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Remove',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignInstitute(List<String> institutes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            'Assign Institute:',
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
              SizedBox(height: 20.v),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: assignInstitute,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Assign',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(int totalStudents, int checkUpCompletedCount) {
  final remainingCount = totalStudents - checkUpCompletedCount;
  final data = [
    charts.Series(
      id: 'CheckupStatus',
      data: [
        {'status': 'Completed', 'count': checkUpCompletedCount},
        {'status': 'Remaining', 'count': remainingCount}
      ],
      domainFn: (datum, _) => datum['status'] as String,
      measureFn: (datum, _) => (datum['count'] as num?) ?? 0,
      colorFn: (datum, _) => charts.ColorUtil.fromDartColor(
        datum['status'] == 'Completed'
            ? Colors.blue
            : Colors.red,
      ),
      labelAccessorFn: (datum, _) => '${datum['status']}: ${datum['count']}',
    )
  ];

    return charts.PieChart(
      data,
      animate: true,
      animationDuration: Duration(seconds: 1),
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 60,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.inside,
          ),
        ],
      ),
    );
  }
}

