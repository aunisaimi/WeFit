import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit2/components/my_input_alert_box.dart';
import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/WeFit2/helper/time_formatter.dart';
import 'package:diet_app/WeFit2/models/post.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Uint8List? _image;
  final imagePicker = ImagePicker();
  String role = '';
  String profilePicture = '';
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

  @override
  void initState(){
    super.initState();
    _loadComments();
    _fetchUserProfilePicture();
    fetchUserData();
    fetchUserRole();
  }

  Future<void> fetchUserData() async {
    try {
      // get current user id
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // fetch users document from firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Extract and set user data to the respective TextEditingController
        setState(() {
          role = userDoc['role'];
        });
        print("Fetched role: ${userDoc['role']}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void fetchUserRole() async {
    String fetchedRole = await fetchRoleByUid(widget.post.uid);
    setState(() {
      role = fetchedRole;
    });
  }

  Future<String> fetchRoleByUid(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return userDoc['role'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print("Error fetching role by uid: $e");
      return 'Unknown';
    }
  }

  Future<void> _fetchUserProfilePicture() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.post.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          profilePicture = userDoc['profilePicture'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user profile picture: $e");
    }
  }

  Future<void> updateUserData() async {
    try {
      // get current user id
      final userId = FirebaseAuth.instance.currentUser!.uid;
      print("This is image picture: ${_image}");

      //update user doc in firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'profilePicture': profilePicture,
      });
    } catch (e) {
      print(e);
    }
  }


  void _showOptions() {
    // check if the post is owned by the user or not
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currentUid;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            // this post belongs to current user
            if (isOwnPost)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  // Handle delete action
                  Navigator.pop(context);

                  // Access the DatabaseProvider instance
                  final listeningProvider = Provider.of<DatabaseProvider>(context, listen:false);
                  final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

                  await databaseProvider.deletePost(widget.post.id);
                },
              )

            // This post does not belong to the user
            else ...[
              // report post button
              ListTile(
                leading: const Icon(
                    Icons.flag,
                    color: Colors.red
                ),
                title: const Text('Report'),
                onTap: () {
                  // Handle report action
                  Navigator.pop(context);
                  // action
                  _reportPostConfirmationBox();
                },
              ),

              // block user
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  // Handle block user action
                  Navigator.pop(context);
                  //action
                  _blockUserConfirmationBox();
                },
              ),
            ],

            // cancel button
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text("Cancel"),
              onTap: () =>
                Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // report post confirmation
  void _reportPostConfirmationBox() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Report Message"),
          content: const Text("Are you sure want to report this message?"),
          actions: [
            // cancel
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
            ),

            // report
            TextButton(
                onPressed: () async {
                  // report user
                  await databaseProvider.reportUser(
                      widget.post.id,
                      widget.post.uid);

                  // close box
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                      const SnackBar(
                          content: Text("Message Reported")
                      )
                  );},
              child: const Text("Report"),
            ),
          ],
        ));
  }

  // block post user confirmation
  void _blockUserConfirmationBox() async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Block User"),
          content: const Text("Are you sure want to block this user?"),
          actions: [
            // cancel
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            // block
            TextButton(
              onPressed: () async {
                // block user
                await databaseProvider.blockUser(widget.post.uid);

                // close box
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                    const SnackBar(
                        content: Text("User Blocked")
                    )
                );},
              child: const Text("Block"),
            ),
          ],
        ));
  }

  /*

  LIKES

   */

  // user tapped like or unlike
  void _toggleLikePost() async {
    try {
      final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await databaseProvider.toggleLike(widget.post.id);

    } catch (e,printStack){
      print("error occurred here: $e");
      print("check here bruv: $printStack");
    }
  }

  /*

  COMMENT

   */

  // comment text controller
  final _commentController = TextEditingController();

  // open comment box -> user wants to type new comment
  void _openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: _commentController,
            hintText: "Type a comment . . ",
            onPressed: () async {
              // add post in db
              await _addComment();
              //Navigator.of(context).pop(); // Close the dialog after adding the comment
            },
            onPressedText: "Post",
        )
    );
  }

  // user tapped post to add comment
  Future<void> _addComment() async {
    //final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    if (_commentController.text.trim().isEmpty) return;

    try {
      await databaseProvider.addComment(
          widget.post.id,
          _commentController.text.trim());

      _commentController.clear();// Clear the text field after posting the comment
      _loadComments();
    } catch (e) {
      // Handle any errors here
      print(e);
    }
  }

  // load comments
  Future<void> _loadComments() async {
    //final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    await databaseProvider.loadComments(widget.post.id);
  }

  /*

  SHOW OPTIONS

  Case 1: This post belongs to current user
  - delete
  - cancel

  Case 2: This post does not belongs to current user
  - report
  - block
  - cancel

   */


  @override
  Widget build(BuildContext context) {
    // does the current user like this post?
    //final listeningProvider = Provider.of<DatabaseProvider>(context, listen: false);
    bool likedByCurrentUser = listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    // listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);

    // listen to comment count
    int commentCount = listeningProvider.getComments(widget.post.id).length;
    print('Comment count: $commentCount');

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        // padding outside
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),

        // padding inside
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          // color of post tile
          color: TColor.white,
          borderRadius: BorderRadius.circular(8),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Top Section -> profile pic / name / username
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  // profile pic
                  profilePicture.isNotEmpty
                      ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      profilePicture,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(Icons.person, color: TColor.gray),

                  const SizedBox(width: 10),

                  // name
                  Text(
                    widget.post.name,
                    style: TextStyle(
                        color: TColor.gray,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(width: 5),

                  // username handle
                  Text(
                    '@${widget.post.name}${widget.post.username}',
                    style: TextStyle(
                        color: TColor.gray
                    ),
                  ),

                  const SizedBox(width: 5),

                  // role
                  if(role == 'Trainer')
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 16,
                    ),


                  const Spacer(),

                  // buttons -> more options
                  GestureDetector(
                    onTap: _showOptions,
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: TColor.gray,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // message
            Text(
              widget.post.message,
              style: TextStyle(
                  color: TColor.gray
              ),
            ),

            const SizedBox(height: 20),

            // buttons -> like + comment
            Row(
              children: [

                // LIKE SECTION
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      // like button
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child: likedByCurrentUser
                            ?
                        const Icon(
                            Icons.favorite,
                            color: Colors.red)
                            :
                        Icon(
                          Icons.favorite_border_rounded,
                          color: TColor.gray,),
                      ),

                      const SizedBox(width: 5),

                      // like count
                      Text(
                        likeCount.toString(),
                        style: TextStyle(
                          color: TColor.gray
                        ),
                      ),
                    ],
                  ),
                ),

                // COMMENT SECTION
                Row(
                  children: [
                    // comment button
                    GestureDetector(
                      onTap: _openNewCommentBox,
                      child: Icon(
                          Icons.comment,
                          color: TColor.gray,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // comment count
                    Text(
                      commentCount != 0 ? commentCount.toString() : '',
                      style: TextStyle(
                        color: TColor.gray
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // timestamp
                Text(
                  formatTimestamp(widget.post.timestamp),
                  style: TextStyle(
                      color: TColor.gray
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
