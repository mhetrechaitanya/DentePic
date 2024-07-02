import 'package:Dentepic/core/app_export.dart';
import 'package:flutter/material.dart';

class NotificationsItemWidget extends StatelessWidget {
  final Map<String, dynamic> student;

  const NotificationsItemWidget({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.h,
        vertical: 16.v,
      ),
      decoration: AppDecoration.fillTeal.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder13,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   height: 43.adaptSize,
              //   width: 43.adaptSize,
              //   decoration: BoxDecoration(
              //     color: appTheme.blueGray100,
              //     borderRadius: BorderRadius.circular(
              //       21.h,
              //     ),
              //   ),
              // ),
              Container(
                width: 200.h,
                margin: EdgeInsets.only(
                  left: 11.h,
                  top: 2.v,
                  bottom: 2.v,
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${student['full_name']} ",
                        style: CustomTextStyles.titleSmallfff5f5f5,
                      ),
                      TextSpan(
                        text: "${student['email']}",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          Icon(
            Icons.download,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          )
          // CustomImageView(
          //   imagePath: ImageConstant.imgLock,
          //   height: 29.v,
          //   margin: EdgeInsets.only(
          //     top: 7.v,
          //     right: 3.h,
          //     bottom: 7.v,
          //   ),
          // ),
        ],
      ),
    );
  }
}
