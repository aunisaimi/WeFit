import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;

  const MyDrawerTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
            color: TColor.gray
        ),
      ),
      leading: Icon(
          icon,
          color: TColor.gray),
      onTap: onTap,
    );
  }
}
