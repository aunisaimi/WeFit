

  import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final String id;
  final String postId;
  final String uid; // commenter's user id
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
  });

  // convert firestore data into a comment obj (use in app)
  factory Comment.fromDocument(DocumentSnapshot doc){
    final data = doc.data() as Map<String,dynamic>;
    return Comment(
        id: doc.id,
        postId: data['postId'],
        uid: data['uid'],
        name: data['name'],
        username: data['username'],
        message: data['message'],
        timestamp: data['timestamp'],
    );
  }

  // convert a comment into a map (to store in firebase)
  Map<String, dynamic> toMap(){
    return {
      'postId': postId,
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
    };
  }
}