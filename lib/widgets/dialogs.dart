import 'package:Dentepic/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,),),
        backgroundColor:Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50 ,
        behavior: SnackBarBehavior.floating));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) =>  Center(child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,)));
  }

  static void showSavingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) =>  Center(
                child: Column(
              children: [
                 Text('Saving...',style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,),),
                const SizedBox(height: 16),
                 CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : appTheme.blue50,),
              ],
            )));
  }
}
