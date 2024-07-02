import 'package:flutter/material.dart';

class CustomGenderDropdownField extends StatelessWidget {
  CustomGenderDropdownField({
    Key? key,
    this.alignment,
    this.width,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final String? value;
  final ValueChanged<String?> onChanged;

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
          value: value,
          onChanged: onChanged,
          items: [
            DropdownMenuItem(
              value: 'Male',
              child: Text(
                'Male',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Female',
              child: Text(
                'Female',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Other',
              child: Text(
                'Other',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ],
          decoration: dropdownDecoration,
          hint: Text(
            'Gender', // Hint text
            style: TextStyle(color: Colors.grey), // Hint text color
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
            color: Colors.blueGrey[400]!,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.blueGrey[400]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.blueGrey[400]!,
            width: 1,
          ),
        ),
        // Set background color to white
      );
}
