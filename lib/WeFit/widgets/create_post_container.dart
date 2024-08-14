import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit/config/palette.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:diet_app/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'widgets.dart';

class CreatePostContainer extends StatefulWidget {
  final UserModel currentUser;

  const CreatePostContainer({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<CreatePostContainer> createState() => _CreatePostContainerState();
}

class _CreatePostContainerState extends State<CreatePostContainer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  Future<DocumentSnapshot<Map<String, dynamic>>>? userDataFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController txtDate = TextEditingController();
  TextEditingController txtWeight = TextEditingController();
  TextEditingController txtHeight = TextEditingController();
  TextEditingController initialCalories = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _postController = TextEditingController();
  String profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    print('${_emailController}');
    print('${_firstnameController}');
    print('${_lastnameController}');
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // get the current user's ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // fetch the users document from firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // extract and set user data to respective TextEditingController()
        setState(() {
          _emailController.text = userDoc['email'];
          _firstnameController.text = userDoc['fname'];
          profilePictureUrl = userDoc['profilePicture'] ?? ''; // Fetch profile picture URL
        });
        print("This is the current email: ${userDoc['email']}");
        print("This is the current name: ${userDoc['fname']}");
      } else {
        print('Data not exist');
      }
    } catch (e) {
      print('Error, please check the error: $e');
    }
  }

  Future<void> _createPost() async {
    String postContent = _postController.text.trim();
    print('Post Content: $postContent');

    if(postContent.isNotEmpty){
      final postCollection = FirebaseFirestore.instance
          .collection('posts');

      await postCollection.add({
        'userId': widget.currentUser.toMap(),
        'userName': widget.currentUser.fname,
        'userProfilePic': widget.currentUser.profilePicture,
        'content': _postController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'shares': 0,
      });

      _postController.clear();
      print('Post Added Successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post added successfully')),
      );
    } else {
      print('Post Content is Empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post content cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 5.0 : 0.0),
      elevation: isDesktop ? 1.0 : 0.0,
      shape: isDesktop
          ? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0))
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                ProfileAvatar(
                  imageUrl: profilePictureUrl.isNotEmpty
                      ? profilePictureUrl
                      : 'https://www.gravatar.com/avatar/placeholder', // Default image URL
                ),
                const SizedBox(width: 8.0),
                 Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'What\'s on your mind?',
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _createPost,
                  color: Palette.facebookBlue,
                )
              ],
            ),
            const Divider(height: 10.0, thickness: 0.5),
            Container(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => print('Live'),
                    icon: const Icon(
                      Icons.videocam,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Live',
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white, // Customize background color if needed
                    ),
                  ),
                  const VerticalDivider(width: 8.0),
                  TextButton.icon(
                    onPressed: () => print('Photo'),
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.green,
                    ),
                    label: const Text(
                      'Photo',
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white, // Customize background color if needed
                    ),
                  ),
                  const VerticalDivider(width: 8.0),
                  TextButton.icon(
                    onPressed: () => print('Room'),
                    icon: const Icon(
                      Icons.video_call,
                      color: Colors.purpleAccent,
                    ),
                    label: const Text(
                      'Room',
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white, // Customize background color if needed
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
