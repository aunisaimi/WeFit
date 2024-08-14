import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class MySettingsTile extends StatelessWidget {
  final String title;
  final Widget action;

  const MySettingsTile({
    super.key,
    required this.title,
    required this.action
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),

      // Padding inside
      padding: const EdgeInsets.all(25),

      // padding outside
      margin: const EdgeInsets.only(left: 25,right: 25,top: 10),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: TColor.gray
            ),
          ),
          action,
        ],
      )
    );
  }
}
