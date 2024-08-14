import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  final String text;

  const MyBioBox({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding outside
      margin: EdgeInsets.symmetric(horizontal: 25,vertical: 5),

      // padding inside
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: TColor.white,
        // curve corners
        borderRadius: BorderRadius.circular(8)
      ),


      child: Text(text.isNotEmpty ? text : "Empty Bio.."),
    );
  }
}
