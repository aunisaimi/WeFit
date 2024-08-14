/*

This file will display num of following, followers and posts

 */

import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class MyProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;

  const MyProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // text style for count
    var textStyleForCount = TextStyle(
      fontSize: 20,
      color: TColor.gray,
    );

    // text style for text
    var textStyleForText = TextStyle(
      color: TColor.primaryColor1,
        fontWeight: FontWeight.bold
    );

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // posts
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(postCount.toString(),style: textStyleForCount,),
                Text("Posts",style: textStyleForText,)
              ],
            ),
          ),

          // followers
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followerCount.toString(),style: textStyleForCount,),
                Text("Followers",style: textStyleForText),
              ],
            ),
          ),

          // following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followingCount.toString(),style: textStyleForCount),
                Text("Following",style: textStyleForText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
