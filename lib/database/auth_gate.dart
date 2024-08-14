import 'package:diet_app/authentication/login_or_register.dart';
import 'package:diet_app/screen/main_tab/main_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData) {
            // user login
            return  MainTabView();
          }
          else {
            // user not login
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
