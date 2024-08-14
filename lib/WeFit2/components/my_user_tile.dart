import 'package:diet_app/WeFit2/models/user.dart';
import 'package:diet_app/WeFit2/pages/profile.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class MyUserTile extends StatelessWidget {
  final UserProfile user;

  const MyUserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(uid: user.uid),
            ),
          );
        },
        child: ListTile(
          title: Row(
            children: [
              Text(
                user.fname,
                style: TextStyle(color: Colors.black),
              ),
              if (user.role == 'Trainer') ...[
                SizedBox(width: 5), // Add some spacing
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 16,
                ),
              ],
            ],
          ),
          subtitle: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "@${user.lname} ",
                  style: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
                if (user.role != null) ...[
                  TextSpan(
                    text: user.role!,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          leading: Icon(
            Icons.person,
            color: TColor.gray,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
