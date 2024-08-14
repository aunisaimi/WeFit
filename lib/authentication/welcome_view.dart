import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:diet_app/screen/main_tab/main_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../common/RoundButton.dart';
import '../common/color_extension.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();


  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService authService = AuthService();

  Future<void> fetchUserData() async {
    try {
      // get the current user's id
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // fetch the user's doc from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists){
        // Extract and set user data to the respective TextEditingController
        setState(() {
          _emailController.text = userDoc['email'];
          _firstnameController.text = userDoc['fname'];
          _lastnameController.text = userDoc['lname'];
        });
        print("This is the current name: ${_firstnameController}");
        print("This is the current name: ${_emailController}");
      }
      else {
        print("Data not exist");
      }
    } catch(e){
      print("Error, please check : ${e}");
    }
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    print('${_emailController}');
    print('${_firstnameController}');
    print('${_lastnameController}');
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Container(
          width: media.width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: media.width * 0.1,
              ),
              Image.asset(
                "assets/img/couple.png",
                width: media.width * 0.75,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Text(
                "Welcome,${_firstnameController.text} ${_lastnameController.text}",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                "You are all set now, let’s reach your\ngoals together with us",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12),
              ),
              const Spacer(),

              RoundButton(
                  title: "Go To Home",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  MainTabView()));
                  }),

            ],
          ),
        ),

      ),
    );
  }
}