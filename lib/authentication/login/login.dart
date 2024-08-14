import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/authentication/AuthGoogle.dart';
import 'package:diet_app/authentication/forgot_password.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:diet_app/screen/home/home_view.dart';
import 'package:diet_app/screen/main_tab/main_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginView extends StatefulWidget {
  final String currentUserId;
  final void Function()? onTap;

  const LoginView({
    Key? key,
    this.onTap,
    required this.currentUserId}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthGoogle _authGoogle = AuthGoogle();
  bool isPasswordVisible = false;

  Future<String?> getCurrentUserId() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists){

      }
      print('Print userID: $userId');
      return userId;
    }
    catch (e){
      print('Error getting current userId: $e');
      return null;
    }
  }

  String? _currentUserId;

  @override
  void initState(){
    super.initState();
    getCurrentUserId().then((userId) {
      setState(() {
        _currentUserId = userId;
      });
    });
  }

  // login method:
  void userLogin(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signInWithEmailPassword(
          _emailController.text,
          _passwordController.text);

      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'email', _emailController.text.trim(),
        );
      }

      // Navigate to MainTabView after successfully login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainTabView(),
        ),
      );
    } catch (e) {
      // show error message
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          )
      );
    }
  }

  // show error message to user
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TColor.primaryColor1,
          title: const Text(
            "Login Failed :(",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  bool isCheck = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: media.width * 0.06),
                Text(
                  "Hey there,",
                  style: TextStyle(color: TColor.gray, fontSize: 16),
                ),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: TColor.primaryColor1,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  controller: _emailController,
                  hitText: "Email",
                  icon: "assets/img/email.png",
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextField(
                  controller: _passwordController,
                  hitText: "Password",
                  icon: "assets/img/lock.png",
                  obscureText: true,
                  rightIcon: TextButton(
                    onPressed: () {},
                    child: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      // child: Image.asset(
                      //   "assets/img/show_password.png",
                      //   width: 20,
                      //   height: 20,
                      //   fit: BoxFit.contain,
                      //   color: TColor.gray,
                      // ),
                    ),
                  ),
                ),
                SizedBox(height: media.width * 0.06),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                       child: Text(
                         "Forgot your password?",
                         style: TextStyle(
                           color: TColor.gray,
                           fontSize: 12,
                           decoration: TextDecoration.underline,
                         ),
                       ),
                      onPressed: () {
                         Navigator.push(
                             context,
                             MaterialPageRoute(
                                 builder: (context) => const ForgotPassword()
                             ),
                         );
                      },
                    ),
                  ],
                ),
                const Spacer(),
                RoundButton(
                  title: "Login",
                  onPressed: () => userLogin(context), // Pass the context here
                ),

                SizedBox(height: media.width * 0.1),



                // Row(
                //   // crossAxisAlignment: CrossAxisAlignment.,
                //   children: [
                //     Expanded(
                //       child: Container(
                //         height: 1,
                //         color: TColor.gray.withOpacity(0.5),
                //       ),
                //     ),
                //
                //     Text(
                //       "  Or  ",
                //       style: TextStyle(color: TColor.black, fontSize: 12),
                //     ),
                //     Expanded(
                //       child: Container(
                //         height: 1,
                //         color: TColor.gray.withOpacity(0.5),
                //       ),
                //     ),
                //   ],
                // ),
                //
                // SizedBox(height: media.width * 0.04),
                //
                // SignInButton(
                //     Buttons.google,
                //     text: "Sign up with Google",
                //     onPressed: () async {
                //       bool result = await _authGoogle.signInWithGoogle("user");
                //       if(result){
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) =>
                //                 HomeView(remainingCalories: 2500)
                //             //HomeView.loginWithGoogle(true),
                //           ),
                //         );
                //       }
                //     }
                // ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     GestureDetector(
                //       onTap: () {},
                //       child: Container(
                //         width: 50,
                //         height: 50,
                //         alignment: Alignment.center,
                //         decoration: BoxDecoration(
                //           color: TColor.white,
                //           border: Border.all(
                //             width: 1,
                //             color: TColor.gray.withOpacity(0.4),
                //           ),
                //           borderRadius: BorderRadius.circular(15),
                //         ),
                //
                //         // child: Image.asset(
                //         //   "assets/img/google.png",
                //         //   width: 20,
                //         //   height: 20,
                //         // ),
                //       ),
                //     ),
                //
                //     SizedBox(width: media.width * 0.04),
                //
                //   ],
                // ),

                SizedBox(height: media.width * 0.04),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don’t have an account yet? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Register",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
