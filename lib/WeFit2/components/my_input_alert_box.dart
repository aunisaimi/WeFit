/*
alert box dialog + textfield that allow user to type in.
 */

import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // curve corners
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),

      // color
      backgroundColor: TColor.white,

      content: TextField(
        controller: textController,
        maxLength: 1000,
        maxLines: 3,

        decoration: InputDecoration(
          // border when textfield is selected
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TColor.gray),
            borderRadius: BorderRadius.circular(12)
          ),

          // border when textfield is selected
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: TColor.primaryColor1),
              borderRadius: BorderRadius.circular(12)
          ),

          // hint text
          hintText: hintText,
          hintStyle: TextStyle(color:Colors.grey),

          // colour inside textfield
          fillColor: TColor.lightGray,
          filled: true,

          // counterstyle
          counterStyle: TextStyle(color: Colors.grey),
        ),
      ),

      // Buttons
      actions: [
        // cancel
        TextButton(
            onPressed: (){
              // close the box
              Navigator.pop(context);

              // clear the controller
              textController.clear();
            },
            child: const Text('Cancel'),
        ),

        // yes
        TextButton(
            onPressed: (){
              // close the box
              Navigator.pop(context);

              // execute function
              onPressed!();

              // clear the controller
              textController.clear();
            },
            child: Text(onPressedText),
        ),
      ],
    );
  }
}
