import 'package:Dentepic/core/app_export.dart';
import 'package:flutter/material.dart';

class StudentsdataItemWidget extends StatelessWidget {
  final String schoolCollege;
  final int numOfStudents;
  final String doctorAssigned;

  const StudentsdataItemWidget({
    Key? key,
    required this.schoolCollege,
    required this.numOfStudents,
    required this.doctorAssigned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 12.v),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "School/ College:",
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.black
            ),
          ),
          SizedBox(height: 2.v),
          Text(
            schoolCollege,
            style: CustomTextStyles.titleSmallGray200?.copyWith(
              color: Colors.black
            ),
          ),
          SizedBox(height: 6.v),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "No. of Students: ",
                  style: CustomTextStyles.titleSmallfff5f5f5?.copyWith(
              color: Colors.black
            ),
                ),
                TextSpan(
                  text: numOfStudents.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black
            ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.v),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Doctor Assigned: ",
                  style: CustomTextStyles.titleSmallfff5f5f5?.copyWith(
              color: Colors.black
            ),
                ),
                TextSpan(
                  text: doctorAssigned,
                  style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black
            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
