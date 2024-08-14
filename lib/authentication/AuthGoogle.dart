import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogle {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle sign in with google account
  Future<bool> signInWithGoogle(String role) async {
    bool result = false;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        int id;
        if (userCredential.additionalUserInfo!.isNewUser) {
          // Get New User ID
          int newUserId = await generateNewUserId();

          // add data to db
          await _firestore.collection('users').doc(user.uid).set({
            "bmi": "",
            'dateOfBirth': "",
            'email': user.email,
            'fname': user.displayName,
            "gender": "",
            "height": "",
            'lname': user.displayName,
            'profilePicture': user.photoURL,
            'weight': "",
          });
          id = newUserId;
        } else {
          if (user.email == null) {
            throw Exception("User email is null");
          }
          id = await getIDUserByEmail(user.email!);
        }
        result = true;
        // OneSignal.login(id.toString());
        // OneSignal login
      }
      return result;
    } catch (e, printStack) {
      print('Failed to Login with Email');
      print(printStack);
      return result;
    }
  }

  Future<int> getHighestUserId() async {
    QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('IDuser', descending: true)
        .limit(1)
        .get();

    if (users.docs.isNotEmpty) {
      // Parse the ID users as an integer and return
      return users.docs.first['IDuser'];
    } else {
      // No existing users, return a default value or handle accordingly
      return 0;
    }
  }

  Future<int> generateNewUserId() async {
    int highestUserId = await getHighestUserId();
    int newUserId = highestUserId + 1;
    return newUserId;
  }

  Future<int> getIDUserByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> users = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (users.docs.isNotEmpty) {
        return users.docs.first['IDuser'];
      } else {
        return 0;
      }
    } catch (e, printStack) {
      print('Error fetching IDuser by email: $e');
      print(printStack);
      return 0;
    }
  }
}
