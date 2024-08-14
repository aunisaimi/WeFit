import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit2/database_service/database_service.dart';
import 'package:diet_app/authentication/AuthGoogle.dart';
import 'package:diet_app/authentication/complete_profile_view.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:diet_app/screen/home/home_view.dart';
import 'package:diet_app/screen/on_boarding/on_boarding_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'login/login.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _bioController = TextEditingController();
  bool isCheck = false;
  bool isPasswordVisible = false;
  String? emailError;
  String? passwordError;

  // register method
  void userSignUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try to register
    try {
      // validate email
      emailError = validateEmail(_emailController.text);
      if (emailError != null) {
        showErrorMessage(emailError!);
        return; // don't proceed with register if email is invalid
      }

      // validate password
      passwordError = validatePassword(_passwordController.text);
      if (passwordError != null) {
        showErrorMessage(passwordError!);
        return;
      }

      // create a new user in Firebase authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // save user info in the database
      await _databaseService.saveUserInfoInFirebase(
        lname: _lastnameController.text,
        email: _emailController.text,
      );

      AuthGoogle authGoogle = new AuthGoogle();

      // get new user ID
      int newUserId = await authGoogle.generateNewUserId();

      // create a new document in Firestore for users
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'IDuser': newUserId,
        'email': _emailController.text,
        'lname': _lastnameController.text,
        'fname': _firstnameController.text,
        'bio': _bioController.text,
        // 'height': _selectHeight,
        // 'weight': _selectWeight,
      });

      // navigate to next page if success
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CompleteProfileView()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.message ?? "An unknown error occurred");
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage("Please try again. Error: $e");
    }
  }

  // Error message
  void showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register Failed'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Pop loading circle after showing the error message
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  bool isValidEmail(String email) {
    // Define a regular expression pattern for a valid email address
    final pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';

    // Create a regular expression object
    final regex = RegExp(pattern);

    // Use the regex to match the email address
    return regex.hasMatch(email);
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: media.width * 0.05),
                Text(
                  "Hey There!",
                  style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),

                Text(
                  "Create Account",
                  style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),

                SizedBox(height: media.width * 0.05),

                RoundTextField(
                  controller: _firstnameController,
                  hitText: "First Name",
                  icon: "assets/img/user_text.png",
                  obscureText: false,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  controller: _lastnameController,
                  hitText: "Last Name",
                  icon: "assets/img/user_text.png",
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  controller: _emailController,
                  hitText: "Email",
                  icon: "assets/img/email.png",
                  obscureText: false,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  controller: _passwordController,
                  hitText: "Password",
                  icon: "assets/img/lock.png",
                  obscureText: !isPasswordVisible,
                  rightIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: TColor.gray,
                    ),
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isCheck = !isCheck;
                        });
                      },
                      icon: Icon(
                        isCheck
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank_outlined,
                        color: TColor.gray,
                        size: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "By continuing, you accept our Privacy Policy and\nTerm of Use",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: media.width * 0.04),

                RoundButton(
                  title: "Register",
                  onPressed: userSignUp,
                ),

                SizedBox(height: media.width * 0.04),


                SizedBox(height: media.width * 0.04),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(currentUserId: '',),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        'Login',
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: media.width * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
