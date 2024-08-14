// import 'package:diet_app/WeFit/models/user_model.dart';
// import 'package:meta/meta.dart';
//
// class Post {
//   final User user;
//   final String caption;
//   final String timeAgo;
//   final String imageUrl;
//   final int likes;
//   final int comments;
//   final int shares;
//
//   const Post({
//     required this.user,
//     required this.caption,
//     required this.timeAgo,
//     required this.imageUrl,
//     required this.likes,
//     required this.comments,
//     required this.shares,
//   });
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit/models/user_model.dart';
import 'package:diet_app/model/UserModel.dart';
import 'package:meta/meta.dart';

class Post {
  final UserModel user;
  final String caption;
  final Timestamp timestamp;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  String profilePicture;

  Post({
    required this.user,
    required this.caption,
    required this.timestamp,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.profilePicture,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      user: UserModel.fromMap(doc['user']),
      caption: doc['content'],
      timestamp: doc['timestamp'],
      imageUrl: doc['imageUrl'],
      likes: doc['likes'],
      comments: doc['comments'],
      shares: doc['shares'],
      profilePicture:doc.get('profilePicture'),
    );
  }
}
