
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String fname;
  String lname;
  String height;
  String weight;
  String profilePicture;
  String email;
  String career;
  String bio;
  String role;
  //String coverImage;

  UserModel({
    required this.uid,
    required this.fname,
    required this.lname,
    required this.height,
    required this.weight,
    required this.profilePicture,
    required this.email,
    required this.career,
    required this.bio,
    required this.role,
    //required this.coverImage,
});

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    return UserModel(
      uid:doc.id,
      fname:doc.get('fname'),
      lname:doc.get('lname'),
      email:doc.get('email'),
      height:doc.get('height')?.toString() ?? '',
      weight: doc.get('weight')?.toString() ?? '',
      profilePicture:doc.get('profilePicture'),
      career: doc.get('career'),
      bio:doc.get('bio'),
      role:doc.get('role'),
      //coverImage:doc.get('coverImage'),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      fname: data['fname'],
      lname: data['lname'],
      email: data['email'],
      height: data['height']?.toString() ?? '',
      weight: data['weight']?.toString() ?? '',
      profilePicture: data['profilePicture'],
      career: data['career'],
      bio: data['bio'],
      role: data['role'],
    );
  }

  Map<String,dynamic> toMap(){
    return {
      'uid': uid,
      'fname': fname,
      'lname': lname,
      'email': email,
      'height': height,
      'weight': weight,
      'profilePicture': profilePicture,
      'career': career,
      'bio': bio,
      'role': role,
    };
  }
}