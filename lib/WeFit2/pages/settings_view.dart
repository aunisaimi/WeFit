import 'package:diet_app/WeFit2/components/my_settings_tile.dart';
import 'package:diet_app/WeFit2/helper/navigate_pages.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title:  Text(
          "S E T T I N G S",
          style: TextStyle(
              color: TColor.gray),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[200],
      ),
      body: Column(
        children: [
          // Block users tile
          MySettingsTile(
            title: "Blocked Users",
            action: GestureDetector(
              onTap: () => goBlockedUsersPage(context),
              child: Icon(
                Icons.arrow_forward,color: TColor.gray,
              ),
            )
          )
          // Account settings tile
        ],
      ),
    );
  }
}
