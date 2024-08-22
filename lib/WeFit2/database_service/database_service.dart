import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit2/models/comment.dart';
import 'package:diet_app/WeFit2/models/post.dart';
import 'package:diet_app/WeFit2/models/user.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  // get instance of firestore db and auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*
  USER PROFILE
   */

  // -> Save User Info
  Future<void> saveUserInfoInFirebase({required String lname, required String email}) async {
    // get current users id
    String uid = _auth.currentUser!.uid;

    // extract username from email
    String fname = email.split('@')[0];

    // create a user profile
    UserProfile user = UserProfile(
      uid: uid,
      lname: lname,
      email: email,
      fname: fname,
      bio: '',
      role: '',
    );

    // convert user into a map so that we can store in firebase
    final userMap = user.toMap();

    // save user info in firebase
    await _db.collection("users").doc(uid).set(userMap);
    print("User info saved for UID: $uid");
  }

  // Get User Info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      // retrieve user doc from firebase using the uid as the document ID
      DocumentSnapshot userDoc = await _db
          .collection("users")
          .doc(uid)
          .get();

      if (userDoc.exists) {
        // convert doc to user profile
        return UserProfile.fromDocument(userDoc);
      } else {
        print("User document does not exist for UID: $uid");
        return null;
      }
    } catch (e, printStack) {
      print("Check $printStack and error occurred: $e");
      return null;
    }
  }

  // update user bio
  Future<void> updateUserBioInFirebase(String bio) async {
    // get current uid
    String uid = _auth.currentUser!.uid;

    // update user's bio in Firestore
    try {
      await _db.collection('users').doc(uid).update({'bio': bio});
    } catch (e, printStack) {
      print('Error occurred: $e and check $printStack');
    }
  }

  /*
  POST MESSAGE
   */

  // Post a message
  Future<void> postMessageInFirebase(String message) async {
    try {
      // get current user id
      String uid = _auth.currentUser!.uid;
      print("Current user UID: $uid");

      // use the uid to get user's profile
      UserProfile? user = await getUserFromFirebase(uid);
      if (user != null) {
        print("Retrieved user profile: ${user.toMap()}");
      } else {
        print("User profile is null for UID: $uid");
      }

      if (user == null) {
        throw Exception('User not found');
      }

      // create a new post
      Post newPost = Post(
        id: '',
        uid: uid,
        name: user.fname,
        username: user.lname,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );

      // convert post obj -> map
      Map<String, dynamic> newPostMap = newPost.toMap();
      print("New post map: $newPostMap");

      // add to firebase
      await _db.collection("Posts").add(newPostMap);
      print("Post added for UID: $uid");
    } catch (e, printStack) {
      print('Error Occurred: $e');
      print('Fix accordingly: $printStack');
    }
  }

  // Delete a post
  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
    } catch(e,printStack){
      print('Error happened: $e');
      print('Check here: $printStack');
    }
  }

  // Get all post
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Posts")
          .orderBy('timestamp',descending: true)
          .get();

      print("Fetched ${snapshot.docs.length} posts.");


      // return as a list of posts
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

    } catch (e,printStack) {
      print("Error occurred: $e");
      print("Check error here -> $printStack");
      return [];
    }
  }

  /*
  LIKES
   */

  // like a post
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      // get current uid
      String uid = _auth.currentUser!.uid;

      // go to doc for this post
      DocumentReference postDoc = _db.collection("Posts").doc(postId);

      // execute Like
      await _db.runTransaction((transaction) async {
        // get post data
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);
        // get lists of users who like the post
        List<String> likedBy =
        List<String>.from(postSnapshot['likedBy'] ?? []);
        // get like count
        int currentLikeCount = postSnapshot['likes'];
        // if user has not liked this post yet -> then like
        if (!likedBy.contains(uid)){
          // add user to like list
          likedBy.add(uid);
          // increment like count
          currentLikeCount++;
        }

        // if user has already liked this post yet -> then unlike
        else {
          // remove user from like list
          likedBy.remove(uid);
          // decrement like count
          currentLikeCount--;
        }

        // update in firebase
        transaction.update(postDoc, {
          'likes': currentLikeCount,
          'likedBy': likedBy,
        });
      });

    } catch (e,printStack){
      print("error happened lol: $e");
      print("Like error here: $printStack");
    }
  }

  /*
  COMMENTS
   */

  // add comment to a post
  Future<void> addCommentInFirebase(String postId, message) async {
    try {
      // get current user
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      // create a new comment
      Comment newComment = Comment(
        id: '' , // auto generate by firestore
        postId: postId,
        uid: uid,
        name: user!.fname,
        username: user!.lname,
        message: message,
        timestamp: Timestamp.now(),
      );

      // convert comment to map
      Map<String,dynamic> newCommentMap = newComment.toMap();

      // to store in firebase
      await _db.collection("Comments").add(newCommentMap);
    } catch(e,printStack){
      print("Error at comment part: $e");
      print("check here: $printStack");
    }
  }

  // delete a comment from a post
  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection("Comments").doc(commentId).delete();
    }catch(e,printStack){
      print("Error at delete comment part: $e");
      print("check here: $printStack");
    }
  }

  // fetch comment for a post
  Future<List<Comment>> getCommentsFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Comments")
          .where("postId", isEqualTo: postId)
          .get();

      // Debug: Print the number of documents returned by the query
      print('QuerySnapshot for postId $postId: ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        print('No comments found for postId: $postId');
      }

      // Debug: Print each document's data
      snapshot.docs.forEach((doc) {
        print('Comment doc data: ${doc.data()}');
      });

      // Map Firestore documents to Comment objects
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e, printStack) {
      print("Error at fetch comment part: $e");
      print("check here: $printStack");
      return [];
    }
  }

  /*
  ACCOUNT STUFF
   */

  // report post
  Future<void> reportUserInFirebase(String postId, userId) async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    // create a report map
    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // update in firestore
    await _db.collection("Reports").add(report);
  }

  // block user
  Future<void> blockUserInFirebase(String userId) async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    // add this user to the blocked list
    await _db
        .collection("users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(userId)
        .set({});
  }

  // unblock user
  Future<void> unblockUserInFirebase(String blockedUserId) async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    // add this user to the blocked list
    await _db
        .collection("users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(blockedUserId)
        .delete();
  }

  // get list of blocked user ids
  Future<List<String>> getBlockedUidsFromFirebase() async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    // get data of blocked users
    final snapshot = await _db
        .collection("users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .get();

    // return as a list
    return snapshot.docs.map((doc) => doc.id).toList();

  }

  /*

  FOLLOW

   */

  // Follow user
  Future<void> followUserInFirebase(String currentUserId, String targetUserId) async {
    // Add the target user to the current user's following list
    await _db
        .collection("users")
        .doc(currentUserId)
        .collection("Following")
        .doc(targetUserId)
        .set({});

    // Add the current user to the target user's followers list
    await _db
        .collection("users")
        .doc(targetUserId)
        .collection("Followers")
        .doc(currentUserId)
        .set({});
  }
  // Future<void> followUserInFirebase(String uid, String targetUserId) async {
  //   // get the current uid
  //   final currentUserId = _auth.currentUser!.uid;
  //
  //   // add target user to current users following
  //   await _db
  //       .collection("users")
  //       .doc(currentUserId)
  //       .collection("Following")
  //       .doc(uid)
  //       .set({});
  //
  //   // add current user to the target user's followers
  //   await _db
  //       .collection("users")
  //       .doc(uid)
  //       .collection("Followers")
  //       .doc(currentUserId)
  //       .set({});
  // }

  // unfollow user

  Future<void> unFollowUserInFirebase(String currentUserId, String targetUserId) async {
    // Remove the target user from the current user's following list
    await _db
        .collection("users")
        .doc(currentUserId)
        .collection("Following")
        .doc(targetUserId)
        .delete();

    // Remove the current user from the target user's followers list
    await _db
        .collection("users")
        .doc(targetUserId)
        .collection("Followers")
        .doc(currentUserId)
        .delete();
  }

  // Future<void> unFollowUserInFirebase(String uid, String targetUserId) async {
  //   // get the current uid
  //   final currentUserId = _auth.currentUser!.uid;
  //
  //   // remove current user from target user's following
  //   await _db
  //       .collection("users")
  //       .doc(currentUserId)
  //       .collection("Following")
  //       .doc(uid)
  //       .set({});
  //
  //   // remove current user from target user's follower
  //   await _db
  //       .collection("users")
  //       .doc(currentUserId)
  //       .collection("Following")
  //       .doc(currentUserId)
  //       .delete();
  // }

  // get a user's followers: list of uids
  Future<List<String>> getFollowerUidsFromFirebase(String uid) async {
    // get the followers from firebase
    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("Followers")
        .get();

    // return as a nice simple list of uids
    //return snapshot.docs.map((doc) => doc.id).toList();
    return snapshot.docs
        .map((doc) => doc.id)
        .where((id) => id != uid)
        .toList();
  }

  // get a user's followings: list of uids
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    // get the followings from firebase
    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("Following")
        .get();

    // return as a nice simple list of uids
    return snapshot.docs
        .map((doc) => doc.id)
        .where((id) => id != uid)
        .toList();
  }

  /*

  SEARCH

   */

  // search users by name
  Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("users")
          .where("fname",isGreaterThanOrEqualTo: searchTerm)
          .where("fname",isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();

    } catch (e,printStack){
      print("error: $e");
      print("Check search error: $printStack");
      return [];
    }
  }
}