// import 'dart:js_interop_unsafe';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class DatabaseServices {
//   final String? uid;
//   DatabaseServices({this.uid});
//
//   final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
//   final CollectionReference groupCollection = FirebaseFirestore.instance.collection("groups");
//
//   // static Future<int> followersNum(String userId) async {
//   //   QuerySnapshot followersSnapshot = await followersRef
//   //       .doc(userId)
//   //       .collection('Followers')
//   //       .get();
//   //   return followersSnapshot.docs.length;
//   // }
//   //
//   // static Future<int> followingNum(String userId) async {
//   //   QuerySnapshot followingSnapshot = await followingRef.
//   //   doc(userId)
//   //       .collection('Following')
//   //       .get();
//   //   return followingSnapshot.docs.length;
//   // }
//
//  // static void updateUserData(UserModel user){
//  //    usersRef.doc(user.id).update({
//  //      'name': user.name,
//  //      'bio':user.bio,
//  //      'profilePicture':user.profilePicture,
//  //      'coverImage': user.coverImage,
//  //    });
//  // }
//
//   Future updateUserData(String email, int height, double weight) async {
//
//     return await userCollection.doc(uid).set({
//       "email":email,
//       "profilePicture": "",
//       "height": height,
//       "weight": weight
//     });
//   }
//
//  // static Future<QuerySnapshot> searchUsers (String name) async {
//  //    Future<QuerySnapshot> users = usersRef
//  //        .where('name', isGreaterThanOrEqualTo: name)
//  //        .where('name', isLessThan: name + 'z')
//  //        .get();
//  //
//  //    return users;
//  // }
//  //
//  // static void followUser(String currentUserId, String visitedUserId) {
//  //    followingRef
//  //        .doc(currentUserId)
//  //        .collection('Following')
//  //        .doc(visitedUserId)
//  //        .set({});
//  //
//  //    followersRef
//  //        .doc(visitedUserId)
//  //        .collection('Followers')
//  //        .doc(currentUserId)
//  //        .set({});
//  // }
//
//   // static void unfollowUser(String currentUserId, String visitedUserId) {
//   //   followingRef
//   //       .doc(currentUserId)
//   //       .collection('Following')
//   //       .doc(visitedUserId)
//   //       .get()
//   //       .then((doc){
//   //         if(doc.exists){
//   //           doc.reference.delete();
//   //         }
//   //   });
//   //
//   //   followersRef
//   //       .doc(visitedUserId)
//   //       .collection('Followers')
//   //       .doc(currentUserId)
//   //       .get()
//   //       .then((doc){
//   //     if(doc.exists){
//   //       doc.reference.delete();
//   //     }
//   //   });
//   // }
//   //
//   // static Future<bool> isFollowingUser(String currentUserId, String visitedUserId) async {
//   //   DocumentSnapshot followingDoc = await followersRef
//   //       .doc(visitedUserId)
//   //       .collection('Followers')
//   //       .doc(currentUserId)
//   //       .get();
//   //
//   //   return followingDoc.exists;
//   // }
//   //
//   // static createPost(Post post){
//   //   postRef.doc(post.authorId).set({'postTime':post.timestamp});
//   //   postRef.doc(post.authorId).collection('userPosts').add({
//   //     'text': post.text,
//   //     'image': post.image,
//   //     'authorId': post.authorId,
//   //     'timestamp': post.timestamp,
//   //     'likes': post.likes,
//   //     'reposts': post.reposts,
//   //   }).then((doc) async {
//   //     QuerySnapshot followerSnapshot = await followersRef
//   //         .doc(post.authorId)
//   //         .collection('Followers')
//   //         .get();
//   //
//   //     for (var docSnapshot in followerSnapshot.docs) {
//   //       feedRefs.doc(docSnapshot.id).collection('userFeed').doc(doc.id).set({
//   //         'text': post.text,
//   //         'image': post.image,
//   //         'authorId': post.authorId,
//   //         'timestamp': post.timestamp,
//   //         'likes': post.likes,
//   //         'reposts': post.reposts,
//   //       });
//   //     }
//   //   });
//   // }
//   //
//   // static Future<List> getUserPosts(String userId) async {
//   //  QuerySnapshot userPostsSnap = await postRef
//   //      .doc(userId)
//   //      .collection('userPosts')
//   //      .orderBy('timestamp',descending: true)
//   //      .get();
//   //
//   //  List<Post> userPosts = userPostsSnap.docs.map((doc) => Post.fromDoc(doc))
//   //      .toList();
//   //
//   //   return userPosts;
//   // }
//
//   // static Future<List<Post>> getUserPosts(String userId) async {
//   //   QuerySnapshot userPostsSnap = await feedRefs
//   //       .doc(userId)
//   //       .collection('userPosts')
//   //       .orderBy('timestamp', descending: true)
//   //       .get();
//   //
//   //   List<Post> userPosts =
//   //   userPostsSnap.docs.map((doc) => Post.fromDoc(doc)).toList();
//   //
//   //   return userPosts;
//   // }
//
//   // static Future<List> getHomePosts(String currentUserId) async {
//   //   QuerySnapshot homePosts = await feedRefs
//   //       .doc(currentUserId)
//   //       .collection('userFeed')
//   //       .orderBy('timestamp', descending: true)
//   //       .get();
//   //
//   //   List<Post> followingPosts = homePosts.docs.map((doc)=> Post.fromDoc(doc))
//   //       .toList();
//   //
//   //   return followingPosts;
//   // }
//   //
//   // static void likePost(String currentUserId, Post post){
//   //   DocumentReference postDocProfile = postRef
//   //       .doc(post.authorId)
//   //       .collection('userPosts')
//   //       .doc(post.id);
//   //   postDocProfile.get().then((doc) {
//   //     if(doc.exists){
//   //       Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
//   //       if(data != null){
//   //         int? likes = data['likes'] as int?;
//   //         if(likes != null){
//   //           postDocProfile.update({'likes': likes + 1});
//   //         }
//   //       }
//   //     }
//   //   });
//
//     // DocumentReference postDocProfile = postRef
//     //     .doc(post.authorId)
//     //     .collection('userPosts')
//     //     .doc(post.id);
//     //
//     // postDocProfile.get().then((doc){
//     //   int likes = doc.data().['likes'];
//     //   postDocProfile.update({'likes': likes+1});
//     // });
//
//     // DocumentReference postDocFeed = feedRefs.doc(currentUserId)
//     //     .collection('userFeed').doc(post.id);
//     // postDocFeed.get().then((doc){
//     //   if(doc.exists){
//     //     int likes = doc.data()['likes'];
//     //     postDocFeed.update({'likes': likes + 1});
//     //   }
//     // });
//
//     DocumentReference postDocFeed = feedRefs.doc(currentUserId)
//         .collection('userFeed').doc(post.id);
//     postDocFeed.get().then((doc){
//       if(doc.exists){
//         Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?; // Handle potential null value
//         if (data != null) {
//           int? likes = data['likes'] as int?;
//           if (likes != null){
//             postDocFeed.update({'likes': likes + 1});
//           }
//           // Add an identifier for the field name
//         }
//       }
//     });
//
//     likesRef.doc(post.id).collection('postLikes').doc(currentUserId).set({});
//   }
//
//   static void unlikePost(String currentUserId, Post post){
//     DocumentReference postDocProfile = postRef
//         .doc(post.authorId)
//         .collection('userPosts')
//         .doc(post.id);
//
//     postDocProfile.get().then((doc){
//       if(doc.exists){
//         var data = doc.data();
//         if(data is Map<String, dynamic>) {
//           int? likes = data['likes'];  // null-aware operator used
//           if(likes != null){
//             postDocProfile.update({'likes': likes -1});
//           }
//         }
//       }
//     });
//
//     DocumentReference postDocFeed = feedRefs.doc(currentUserId)
//         .collection('userFeed').doc(post.id);
//     postDocFeed.get().then((doc){
//       if(doc.exists){
//         var data = doc.data();
//         if(data is Map<String, dynamic>) {
//           int likes = data['likes'];  // null-aware operator used
//           if(likes != null){
//             postDocFeed.update({'likes': likes - 1});
//           }
//         }
//       }
//     });
//
//     likesRef
//         .doc(post.id)
//         .collection('postLikes')
//         .doc(currentUserId)
//         .get().then((doc){
//           if(doc.exists){
//             doc.reference.delete();
//           }
//     });
//   }
//
//   static Future<bool> isLikePost(String currentUserId, Post post) async {
//     DocumentSnapshot userDoc = await likesRef
//         .doc(post.id)
//         .collection('postLikes')
//         .doc(currentUserId)
//         .get();
//     return userDoc.exists;
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection("groups");

  Future updateUserData(String email, int height, double weight) async {

    return await userCollection.doc(uid).set({
      "email":email,
      "profilePicture": "",
      "height": height,
      "weight": weight
    });
  }
}