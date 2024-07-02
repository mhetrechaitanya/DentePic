import 'package:flutter/material.dart';
import '../core/app_export.dart';

class CustomDropdownField extends StatelessWidget {
  CustomDropdownField({
    Key? key,
    this.alignment,
    this.width,
    this.value,
    required this.onChanged,
    this.doctorItem = 'Doctor',
    this.adminItem = 'Admin',
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String doctorItem;
  final String adminItem;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: dropdownFieldWidget(context),
          )
        : dropdownFieldWidget(context);
  }

  Widget dropdownFieldWidget(BuildContext context) => SizedBox(
        width: width ?? double.maxFinite,
        child: DropdownButtonFormField<String>(
          style: TextStyle(
                            color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500
                          ),
          value: value,
          onChanged: onChanged,
          items: [
            DropdownMenuItem(
              value: doctorItem,
              child: Text(doctorItem),
            ),
            DropdownMenuItem(
              value: adminItem,
              child: Text(adminItem),
            ),
          ],
          decoration: dropdownDecoration,
           hint: Text(
            'You Are', // Hint text
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 15), // Hint text color
          ),
        ),
      );

  InputDecoration get dropdownDecoration => InputDecoration(
        filled: true,
        fillColor: Colors.white, 
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        // Set background color to white
      );
}
