import 'package:flutter/material.dart';
import 'package:Dentepic/core/app_export.dart';

class AppDecoration {
  // Fill decorations
  static BoxDecoration get fillBlue => BoxDecoration(
        color: appTheme.blue50,
      );

  static BoxDecoration get fillwhite => BoxDecoration(
        color: appTheme.whiteA700,
        borderRadius: BorderRadius.circular(10)

      );

  // Outline decorations
  static BoxDecoration get outlineGrayCe => BoxDecoration(
        color: theme.colorScheme.onPrimary.withOpacity(0.53),
        border: Border(
          top: BorderSide(
            color: appTheme.gray400Ce,
            width: 4.h,
          ),
        ),
      );
    static BoxDecoration get blackBorder => BoxDecoration(
        color: theme.colorScheme.onPrimary.withOpacity(0.53),
        border: Border(
          top: BorderSide(
            color: appTheme.black900,
            width: 0.5.h,
          ),
        ),
      );
  static BoxDecoration get fillTeal => BoxDecoration(
        color: appTheme.teal600,
      );
    static BoxDecoration get outlineErrorContainer => BoxDecoration(
        color: appTheme.whiteA700,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.errorContainer.withOpacity(1),
            width: 1.h,
          ),
        ),
      );
  // Outline decorations
  static BoxDecoration get outlineGrayCe2 => BoxDecoration(
        color: appTheme.whiteA700,
        border: Border(
          top: BorderSide(
            color: appTheme.gray400Ce,
            width: 4.h,
          ),
        ),
      );
   static BoxDecoration get outlinewhiteA700 => BoxDecoration(
        color: appTheme.blue50,
        border: Border(
          top: BorderSide(
            color: appTheme.whiteA700,
            width: 1.h,
          ),
        ),
      );


  static BoxDecoration get fillPrimaryContainer => BoxDecoration(
        color: theme.colorScheme.primaryContainer,
      );

  static BoxDecoration get fillwhiteA => BoxDecoration(
        color: appTheme.whiteA700,
      );

  static BoxDecoration get outlineErrorContainer1 => BoxDecoration();
  static BoxDecoration get outlineGray400ce => BoxDecoration(
        color: appTheme.whiteA700,
        border: Border(
          top: BorderSide(
            color: appTheme.gray400ce,
            width: 4.h,
          ),
        ),
      );

  static BoxDecoration get outlinewhiteA => BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: appTheme.whiteA700.withOpacity(0.93),
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: Offset(
              0,
              0,
            ),
          ),
        ],
      );


}

class BorderRadiusStyle {
  // Custom borders
  static BorderRadius get customBorderBL13 => BorderRadius.vertical(
        bottom: Radius.circular(13.h),
      );

  // Rounded borders
  static BorderRadius get roundedBorder29 => BorderRadius.circular(
        29.h,
      );

  static BorderRadius get roundedBorder13 => BorderRadius.circular(
        13.h,
      );
  static BorderRadius get roundedBorder28 => BorderRadius.circular(
        28.h,
      );
   static BorderRadius get roundedBorder44 => BorderRadius.circular(
        44.h,
      );


}

// Comment/Uncomment the below code based on your Flutter SDK version.

// For Flutter SDK Version 3.7.2 or greater.

double get strokeAlignInside => BorderSide.strokeAlignInside;

double get strokeAlignCenter => BorderSide.strokeAlignCenter;

double get strokeAlignOutside => BorderSide.strokeAlignOutside;

