import 'package:diet_app/WeFit/data/data(dummy).dart';
import 'package:diet_app/WeFit2/components/my_drawer_tile.dart';
import 'package:diet_app/WeFit2/pages/profile.dart';
import 'package:diet_app/WeFit2/pages/search_page.dart';
import 'package:diet_app/WeFit2/pages/settings_view.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  // access to auth service
  final _auth = AuthService();

  //log out
  void logout(){
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // app logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: TColor.secondaryColor2,
                ),
              ),

              // Divider line
              Divider(
                indent: 25,
                endIndent: 25,
                color: TColor.secondaryColor2,
              ),

              const SizedBox(height: 10),

              // home list tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: (){
                  // pop menu drawer
                  Navigator.pop(context);
                },
              ),

              // Profile tile
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: (){
                  String currentUid = AuthService().getCurrentUid();
                  // pop menu drawer
                  Navigator.pop(context);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ProfilePage(uid: currentUid) // cek nnti
                  //     )
                  // );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: _auth.getCurrentUid()) // cek nnti
                      )
                  );
                },
              ),

              // search list tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: (){
                  // pop menu drawer
                  Navigator.pop(context);
                  // debug print
                  print("Navigating to search page...");
                  // go to search page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()
                      )
                  );
                },
              ),

              // settings list tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: (){
                  // pop menu drawer
                  Navigator.pop(context);
                  // debug print
                  print("Navigating to settings page...");
                  // go to settings page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsView()
                      )
                  );
                },
              ),
              // logout

              const Spacer(),

              MyDrawerTile(
                  title: "L O G O U T",
                  icon: Icons.logout,
                  onTap: logout)
            ],
          ),
        ),
      ),
    );
  }
}
