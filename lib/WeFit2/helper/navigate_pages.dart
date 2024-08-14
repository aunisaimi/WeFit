// go to user page

import 'package:diet_app/WeFit2/pages/blocked_users_page.dart';
import 'package:diet_app/WeFit2/pages/homepage.dart';
import 'package:diet_app/WeFit2/pages/post_page.dart';
import 'package:diet_app/WeFit2/pages/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diet_app/WeFit2/models/post.dart';

void goUserPage(BuildContext context, String uid){
  // navigate to the page
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(uid: uid)
      )
  );
}

void goPostPage(BuildContext context, Post post) async {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostPage(post: post)
      )
  );
}

void goBlockedUsersPage(BuildContext context){
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BlockedUsersPage()
      )
  );
}

void goHomePage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage()
      ),
          (route) => route.isFirst
  );

}