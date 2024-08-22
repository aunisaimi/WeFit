/*
to seperate the firestore data handling and the UI of our app

- the db service class handles data to and from firebase
- the db provider class processes the data to display in our app
- to properly manage the different states of the app
- easy to manage

 */

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit2/database_service/database_service.dart';
import 'package:diet_app/WeFit2/models/comment.dart';
import 'package:diet_app/WeFit2/models/post.dart';
import 'package:diet_app/WeFit2/models/user.dart';
import 'package:diet_app/database/DatabaseService.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:flutter/cupertino.dart';

class DatabaseProvider extends ChangeNotifier {

  /*
  SERVICE
   */
  // get the db and auth service
  final _auth = AuthService();
  final _db = DatabaseService();

  /*
  USER PROFILE
   */
  // get user profile given uid

  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

/*

POSTS

 */

// local list of posts
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

// get posts
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

// post message
  Future<void> postMessage(String message) async {
    // post msg to firebase
    await _db.postMessageInFirebase(message);

    // reload data from firebase
    await loadAllPosts();
  }

// fetch all posts
  Future<void> loadAllPosts() async {
    _allPosts = [
      Post(id: '1',
        uid: 'user1',
        name: 'Test User',
        username: 'testuser',
        message: 'This is a test post',
        timestamp: Timestamp.now(),
        likeCount: 10,
        likedBy: [], ),
      // Add more static posts if needed

    ];

    // get all posts from firebase
    final allPosts = await _db.getAllPostsFromFirebase();
    print('Fetched ${allPosts.length} posts from Firebase.');

    // get blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();
    print('Blocked user IDs: $blockedUserIds');

    // filter out blocked users & update locally
    _allPosts = allPosts.where(
            (post) => !blockedUserIds.contains(post.uid))
        .toList();
    print('Posts after filtering: ${_allPosts.length}');

    // update local data
    // _allPosts = allPosts;

    // filter out the following post
    loadFollowingPosts();

    // initialize local like data
    initializeLikeMap();

    // update UI
    notifyListeners();
  }

// filter and return posts given uid
  List<Post> filterUserPosts(String uid){
    return _allPosts.where((post) => post.uid == uid).toList();
  }

// delete post
  Future<void> deletePost(String postId) async {
    // delete from firebase
    await _db.deletePostFromFirebase(postId);
    // reload data from firebase
    await loadAllPosts();

  }

  // load following posts -> posts from users that the current one follows
  Future<void> loadFollowingPosts() async {
    // get current uid
    String currentUid = _auth.getCurrentUid();

    // get lists of uids that current user follows (from firebase)
    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);

    // filter all posts to be the ones for the following tab
    _followingPosts = _allPosts
        .where(
            (post) => followingUserIds
            .contains(post.uid))
        .toList();

    // update ui
    notifyListeners();
  }


/*
 LIKES
 */

  // local map to track like counts for each post
  Map<String, int> _likeCounts ={
    // for each post id: like count
  };

  // local list to track posts liked by current user
  List<String> _likedPosts = [];

  // does current user like this post?
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  // get like count of a post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  // initialize like map locally
  void initializeLikeMap (){
    // get current user id
    final currentUserID = _auth.getCurrentUid();

    // clear liked posts (for when new user signs in, clear local data)
    _likedPosts.clear();

    // for each post get like data
    for (var post in _allPosts){
      // update like count map
      _likeCounts[post.id] = post.likeCount;

      // if the current user already like this post
      if (post.likedBy.contains(currentUserID)){
        // add this post id to local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  // toggle like
  Future<void> toggleLike(String postId) async {
    // store original values in case it fails
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    // perform like / unliked
    if(_likedPosts.contains(postId)){
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    // update UI locally
    notifyListeners();

    // attempt like in database
    try {
      await _db.toggleLikeInFirebase(postId);
    }
    // revert back to initial state if update fails
    catch(e){
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;

      // update UI again
      notifyListeners();
    }
  }

  /*

  COMMENTS

   */

  // local list of comments
  final Map<String,List<Comment>> _comments = {};

  // get comments locally
  List<Comment> getComments(String postId) {
    print('Getting comments for $postId: ${_comments[postId]}'); // Add this line
    return _comments[postId] ?? [];
  }

  // fetch comment from database for a post
  Future<void> loadComments(String postId) async {
    try {
      final allComments = await _db.getCommentsFromFirebase(postId);

      _comments[postId] = allComments;

      notifyListeners();

      print('Comments loaded: ${_comments[postId]}');

    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  // add a comment
  Future<void> addComment(String postId, message) async {
    // add comment in firebase
    await _db.addCommentInFirebase(postId, message);

    // reload
    await loadComments(postId);
  }

  // delete a comment
  Future<void> deleteComment(String commentId,postId) async {
    // delete comment in firebase
    await _db.deleteCommentInFirebase(commentId);
    //reload comment
    await loadComments(postId);
  }

  /*

  ACCOUNT STUFF

   */

  // local list of blocked users
  List<UserProfile> _blockedUsers = [];

  // get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUsers;

  // fetched the blocked users
  Future<void> loadBlockedUsers() async {
    // get list of blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    // get full user details using uid
    final blockedUsersData = await Future.wait(
        blockedUserIds.map((id) => _db.getUserFromFirebase(id)));

    // return as a list
    _blockedUsers = blockedUsersData.whereType<UserProfile>().toList();

    // update UI
    notifyListeners();
  }

  // block user
  Future<void> blockUser(String userId) async {
    // perform block in firebase
    await _db.blockUserInFirebase(userId);

    // reload blocked user
    await loadBlockedUsers();

    // reload posts
    await loadAllPosts();

    // update UI
    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String blockedUserId) async {
    // perform block in firebase
    await _db.unblockUserInFirebase(blockedUserId);

    // reload blocked user
    await loadBlockedUsers();

    // reload posts
    await loadAllPosts();

    // update UI
    notifyListeners();
  }

  // report user & post
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserInFirebase(postId, userId);
  }

  /*

  FOLLOW

   */

  // local map
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String,int> _followerCount = {};
  final Map<String,int> _followingCount = {};

  // final Map<String, List<UserProfile>> _followersProfile = {};
  // final Map<String, List<UserProfile>> _followingProfile = {};

  // get counts for followers & following locally: given uid
  // int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  // int getFollowingCount(String uid) => _followingCount[uid] ?? 0;
  int getFollowerCount(String uid) => _followers[uid]?.length ?? 0;
  int getFollowingCount(String uid) => _following[uid]?.length ?? 0;

  // load followers
  Future<void> loadUserFollowers(String uid) async {
    final followerIds = await _db.getFollowerUidsFromFirebase(uid);
    _followers[uid] = followerIds.where((id) => id != uid).toList(); // Exclude current user
    notifyListeners();
  }
  // Future<void> loadUserFollowers(String uid) async {
  //   final followerIds = await _db.getFollowerUidsFromFirebase(uid);
  //   //_followersProfile[uid] = await _fetchUserProfiles(followerIds);
  //   _followers[uid] = followerIds;
  //   notifyListeners();
  // }

  // load following
  Future<void> loadUserFollowing(String uid) async {
    _following.remove(uid); // Clear cache
    final followingIds = await _db.getFollowingUidsFromFirebase(uid);
    // Filter out the current user if they are mistakenly in the following list
    _following[uid] = followingIds
        .where((followingId) => followingId != uid)
        .toList();

    print("Filtered Following List for user $uid: ${_following[uid]}");

    notifyListeners();
  }
  // Future<void> loadUserFollowing(String uid) async {
  //   final followingIds = await _db.getFollowingUidsFromFirebase(uid);
  //   //_followingProfile[uid] = await _fetchUserProfiles(followingIds);
  //   _following[uid] = followingIds;
  //   notifyListeners();
  // }

  Future<List<UserProfile>> _fetchUserProfiles(List<String> uids) async {
    List<UserProfile> profiles = [];
    for (String uid in uids) {
      UserProfile? profile = await _db.getUserFromFirebase(uid);
      if (profile != null) {
        profiles.add(profile);
      }
    }
    return profiles;
  }

  // Future<void> followUser(String targetUserId) async {
  //   final currentUserId = _auth.getCurrentUid();
  //
  //   // Add targetUserId to the list of following users
  //   await _db.followUserInFirebase(currentUserId, targetUserId);
  //
  //   // Update local state
  //   _following[currentUserId] ??= [];
  //   _following[currentUserId]!.add(targetUserId);
  //   _followingCount[currentUserId] = (_followingCount[currentUserId] ?? 0) + 1;
  //
  //   notifyListeners();
  // }

  // Follow a user
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    if (currentUserId == targetUserId) return;

    // Add to Firebase
    await _db.followUserInFirebase(currentUserId, targetUserId);

    // Update local state
    _following[currentUserId] ??= [];
    _following[currentUserId]!.add(targetUserId);

    _followers[targetUserId] ??= [];
    _followers[targetUserId]!.add(currentUserId);

    notifyListeners();
  }

  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    if (currentUserId == targetUserId) return;

    // Remove from Firebase
    await _db.unFollowUserInFirebase(currentUserId, targetUserId);

    // Update local state
    _following[currentUserId]?.remove(targetUserId);
    _followers[targetUserId]?.remove(currentUserId);

    notifyListeners();
  }

  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _following[currentUserId]?.contains(uid) ?? false;
  }

  // Method to refresh follow status when visiting a profile
  Future<void> refreshFollowStatus(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();
    final followingIds = await _db.getFollowingUidsFromFirebase(currentUserId);

    _following[currentUserId] = followingIds;

    final followerIds = await _db.getFollowerUidsFromFirebase(targetUserId);
    _followers[targetUserId] = followerIds;

    notifyListeners();
  }

  /*

  SEARCH

   */

  // lists of search result
  List<UserProfile> _searchResults = [];

  // get list of search results
  List<UserProfile> get searchResult => _searchResults;

  // method to search for a user
  Future<void> searchUsers(String searchTerm) async {
    try {
      // search users in firebase
      final results  = await _db.searchUsersInFirebase(searchTerm);

      // update local data
      _searchResults = results;

      // update UI
      notifyListeners();
    }
    catch(e,printStack){
      print("error: $e");
      print("Check search error here: $printStack");
    }
  }

  /*

  MAP OF PROFILES

  given uid:
  - list of follower profiles
  - list of following profiles

   */

  final Map<String, List<UserProfile>>  _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  // get list of follower profiles for a given user
  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];

  // get list of following profiles for a given user
  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  // load follower profiles for a given uid
  Future<void> loadUserFollowerProfiles(String uid) async {
    try {
      // get list of follower uids from firebase
      final followerIds = await _db
          .getFollowerUidsFromFirebase(uid);

      // create list of user profile
      List<UserProfile> followerProfiles = [];

      // go through each follower id
      for (String followerId in followerIds) {
        // get user profile from firebase with this uid
        UserProfile? followerProfile = await _db
            .getUserFromFirebase(followerId);

        // add to follower profile
        if(followerProfile != null){
          followerProfiles.add(followerProfile);
        }
      }

      // update local data
      _followersProfile[uid] = followerProfiles;

      // update ui
      notifyListeners();

    } catch (e,stackTrace){
      print(e);
      print("Failed to load follower profiles here: $stackTrace");
    }
  }

  // load following profiles for a given uid
  Future<void> loadUserFollowingProfiles(String uid) async {
    try {
      // get list of following uids from firebase
      // final followingIds = await _db
      //     .getFollowerUidsFromFirebase(uid);
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      // create list of user profile
      List<UserProfile> followingProfiles = [];

      // go through each following id
      for (String followingId in followingIds) {
        // get user profile from firebase with this uid
        UserProfile? followingProfile = await _db
            .getUserFromFirebase(followingId);

        // add to following profile
        if(followingProfile != null){
          followingProfiles.add(followingProfile);
        }
      }

      // update local data
      _followingProfile[uid] = followingProfiles;
      //_followersProfile[uid] = followingProfiles;

      // update ui
      notifyListeners();

    } catch (e,stackTrace){
      print(e);
      print("check error here: $stackTrace");
    }
  }
}