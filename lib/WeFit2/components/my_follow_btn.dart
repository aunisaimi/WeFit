import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const MyFollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing
  });


  @override
  Widget build(BuildContext context) {
    // padding outside
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: MaterialButton(
          // padding inside
          padding: const EdgeInsets.all(25),
          onPressed: onPressed,
          color: isFollowing ?  TColor.primaryColor1 : TColor.primaryColor2,
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}
