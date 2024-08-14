import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/database/DatabaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screen/on_boarding/on_boarding_view.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //final AuthRepository _authRepository = AuthRepository();

  // Sign In
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  void handleLoginSuccess(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const OnBoardingView()));
  }

  Future<void> verifyEmail() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      print("Email verification sent to: ${user.email}");
    } else {
      print("No user currently signed in");
    }
  }

  Future<User?> registerUserWithEmailandPassword(String name, String email,
      String password, double weight, int height) async {
    try {
      // check if all required fields are provided
      if (name.isNotEmpty || email.isNotEmpty || password.isNotEmpty) {
        throw Exception("All fields are required");
      }

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
          email: email,
          password: password);

      // call database service to update user data
      await DatabaseServices().updateUserData(email, height, weight);

      // After create user, create a new document for users in user collection
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'height': 0, //height,
        'weight': 0, //weight,
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error during registration: ${e.message}");
      return null;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  String getCurrentUid(){
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception("No user currently signed in");
    }
  }
}
