import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String lname;
  final String email;
  final String fname;
  final String bio;
  final String role;

  UserProfile({
    required this.uid,
    required this.lname,
    required this.email,
    required this.fname,
    required this.bio,
    required this.role,
});

  /*

  firebase -> app

  convert firestore document to a user profile (use in app)

   */

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data is null');
    }

    return UserProfile(
      uid: doc.id,
      lname: data['lname'] ?? '',
      email: data['email'] ?? '',
      fname: data['fname'] ?? '',
      bio: data['bio'] ?? '',
      role: data['role'],
    );
  }
  /*

  app -> firebase

  convert a user profile to a map (to store in firebase)

   */

Map<String,dynamic> toMap(){
  return {
    'uid': uid,
    'lname': lname,
    'email': email,
    'fname': fname,
    'bio': bio,
    'role': role,
  };
}

}