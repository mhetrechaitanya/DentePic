import 'package:flutter/material.dart';
import '../core/app_export.dart';

class CustomBloodDropdownField extends StatelessWidget {
  CustomBloodDropdownField({
    Key? key,
    this.alignment,
    this.width,
    this.value,
    required this.onChanged,
    this.defaultBloodGroup,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? defaultBloodGroup;

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
              value: 'A+',
              child: Text('A+', style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
            DropdownMenuItem(
              value: 'A-',
              child: Text('A-',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
            DropdownMenuItem(
              value: 'B+',
              child: Text('B+',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
            DropdownMenuItem(
              value: 'B-',
              child: Text('B-',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
            DropdownMenuItem(
              value: 'AB+',
              child: Text('AB+',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
            DropdownMenuItem(
              value: 'AB-',
              child: Text('AB-',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
            DropdownMenuItem(
              value: 'O+',
              child: Text('O+',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
            DropdownMenuItem(
              value: 'O-',
              child: Text('O-',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,),),
            ),
          ],
          decoration: dropdownDecoration,
          hint: Text(
            'Select Blood Group',
            style: TextStyle(color: Colors.grey),
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
      );
}
