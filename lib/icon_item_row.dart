import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'color_extension.dart';

class IconItemRow extends StatelessWidget {
  final String title;
  final Widget icon;
  final String value;
  const IconItemRow(
      {
      required this.title,
      required this.icon,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          icon,
          const SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: TextStyle(
                color: TColor.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Icon(Icons.arrow_forward_ios,color: Colors.white,size: 15,)
        ],
      ),
    );
  }
}

class IconItemSwitchRow extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool value;
  final Function(bool) didChange;

  const IconItemSwitchRow(
      {
      required this.title,
      required this.icon,
      required this.didChange,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          icon,
          const SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Spacer(),
          const SizedBox(
            width: 8,
          ),
          CupertinoSwitch(value: value, onChanged: didChange, thumbColor: Colors.black,)
        ],
      ),
    );
  }
}
