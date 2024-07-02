import 'package:flutter/material.dart';
import 'package:Dentepic/core/app_export.dart';

class CustomTextStyles {
  // Assuming you have an instance of appTheme
  // final appTheme appTheme = appTheme();

  static get titleMediumBlue50 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blue50,
      );
  
  

  static get titleMediumErrorContainerSemiBold16 =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.errorContainer.withOpacity(1),
        fontSize: 16.fSize,
        fontWeight: FontWeight.w600,
      );

  static get bodySmallErrorContainer => theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.errorContainer.withOpacity(1),
      );

  static get bodyMediumBluegray900 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.blueGray900,
        fontSize: 14.fSize,
      );

  static get titleMediumGray500 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray500,
      );

  static get titleMediumGray20002 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray20002,
        fontSize: 16.fSize,
        fontWeight: FontWeight.w500,
      );

  static get titleMediumBlack => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.black900,
      );

  static get titleMediumErrorContainer => theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.errorContainer.withOpacity(1),
        fontWeight: FontWeight.w500,
      );

  static get titleMediumOnPrimaryContainer =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
      );

  static get titleMediumTeal600 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.teal600,
      );

  static get titleSmallfff5f5f5 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.gray100,
      );

  static get titleSmallGray200 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.gray800,
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );

  static get titleSmallwhiteA700 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.whiteA700,
        fontWeight: FontWeight.w700,
        fontSize: 14.fSize,
      );

  static get titleMediumErrorContainerMedium =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.errorContainer.withOpacity(1),
        fontSize: 18.fSize,
        fontWeight: FontWeight.w500,
      );

  // static get titleMediumCustomColor => theme.textTheme.titleMedium!.copyWith(
  //       color: appTheme.customColor,
  //     );
}

