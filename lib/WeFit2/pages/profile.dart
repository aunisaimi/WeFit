import 'dart:typed_data';

import 'package:diet_app/WeFit2/components/my_bio_box.dart';
import 'package:diet_app/WeFit2/components/my_follow_btn.dart';
import 'package:diet_app/WeFit2/components/my_input_alert_box.dart';
import 'package:diet_app/WeFit2/components/my_post_tile.dart';
import 'package:diet_app/WeFit2/components/my_profile_stats.dart';
import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/WeFit2/helper/navigate_pages.dart';
import 'package:diet_app/WeFit2/pages/follow_list_page.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Uint8List? _image;
  final imagePicker = ImagePicker();
  String profilePicture = '';
  late Future<UserModel?> _userModelFuture;
  final bioTextController = TextEditingController();
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isCurrentUser = false;
  late final DatabaseProvider databaseProvider;


  @override
  void initState() {
    super.initState();
    print("Initializing ProfilePage with UID: ${widget.uid}");
    _userModelFuture = _fetchUserModel();
    _isCurrentUser = widget.uid == FirebaseAuth.instance.currentUser?.uid;
    _checkIfFollowing();
    fetchUserData();
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    databaseProvider.loadUserFollowers(widget.uid);
    databaseProvider.loadUserFollowing(widget.uid);
    _loadProfileData();
    _fetchFollowState();
  }

  Future<void> _fetchFollowState() async {
    //final provider = context.read<DatabaseProvider>();
    _isFollowing = await databaseProvider.isFollowing(widget.uid);
    setState(() {});
  }


  Future<void> _loadProfileData() async {
    final targetUserId = widget.uid; // Replace with the appropriate userId
    await context.read<DatabaseProvider>().refreshFollowStatus(targetUserId);
    await context.read<DatabaseProvider>().loadUserFollowingProfiles(targetUserId);
    await context.read<DatabaseProvider>().loadUserFollowerProfiles(targetUserId);
  }

  Future<void> _checkIfFollowing() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    bool isFollowing = await databaseProvider.isFollowing(widget.uid);
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  Future<void> uploadImageAndSave() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }
      final profile = 'profile_pictures/${user.uid}.png';

      // upload image to cloud storage
      final UploadTask task = _storage.ref().child(profile).putData(_image!);

      // get the download url of the uploaded image
      final TaskSnapshot snapshot = await task;
      final imageUrl = await snapshot.ref.getDownloadURL();

      // update user's firestore doc with the image url
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profilePicture': imageUrl});

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text('Profile picture uploaded and updated.'),
        ),
      );
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _image = Uint8List.fromList(imageBytes);
      });
    } else {
      print('Image source not found');
    }
  }

  Future<UserModel?> _fetchUserModel() async {
    try {
      if (widget.uid.isEmpty) {
        print("Error: UID is empty");
        return null;
      }

      print("Fetching data for user: ${widget.uid}");
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        print("User document data: ${userDoc.data()}");
        UserModel userModel = UserModel.fromDoc(userDoc);
        // Assuming UserModel has a 'role' field
        return userModel;

      } else {
        print("User document does not exist for UID: ${widget.uid}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  void _showEditBioBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: bioTextController,
        hintText: "Edit Bio...",
        onPressed: saveBio,
        onPressedText: "Save",
      ),
    );
  }

  Future<void> saveBio() async {
    setState(() {
      _isLoading = true;
    });

    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    await databaseProvider.updateBio(bioTextController.text);

    setState(() {
      _userModelFuture = _fetchUserModel();
      _isLoading = false;
    });

    bioTextController.clear();
  }

  Future<void> _toggleFollow() async {
    if (_isFollowing) {
      await databaseProvider.unfollowUser(widget.uid);
    } else {
      await databaseProvider.followUser(widget.uid);
    }
    await _fetchFollowState();
  }

  // Future<void> _toggleFollow() async {
  //   final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
  //   if (_isFollowing) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Unfollow"),
  //         content: const Text("Are you sure you want to unfollow?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.pop(context);
  //               // Perform unfollow
  //               await databaseProvider.unfollowUser(widget.uid);
  //               setState(() {
  //                 _isFollowing = false;
  //               });
  //             },
  //             child: const Text("Yes"),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     await databaseProvider.followUser(widget.uid);
  //     setState(() {
  //       _isFollowing = true;
  //     });
  //   }
  // }

  Future<void> fetchUserData() async {
    try {
      // get current user id
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // fetch users document from firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        // Extract and set user data to the respective TextEditingController
        setState(() {
          profilePicture = userDoc['profilePicture'] ?? '';
        });
        print("this is current profile picture: ${userDoc['profilePicture']}");
      }
      else {
        print("User document does not exist for UID: ${widget.uid}");
      }
    } catch (e) {
      print(e);
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

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);

    // listen to followers & following count
   // final followerCount = listeningProvider.getFollowerCount(widget.uid);
    //final followingCount = listeningProvider.getFollowingCount(widget.uid);

    final followerCount = databaseProvider.getFollowerCount(widget.uid);
    final followingCount = databaseProvider.getFollowingCount(widget.uid);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        title: FutureBuilder<UserModel?>(
          future: _userModelFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Error fetching user data');
            } else if (snapshot.hasData) {
              UserModel? userModel = snapshot.data;
              return Text(userModel != null ? userModel.fname : 'No user data');
            } else {
              return const Text('No user data');
            }
          },
        ),
        backgroundColor: Colors.grey[200],
        leading: IconButton(
            onPressed: () => goHomePage(context),
            icon: const Icon(
                Icons.arrow_back_ios_new_rounded
            )
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: _userModelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data'));
          } else if (snapshot.hasData) {
            UserModel userModel = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: Text(
                    '@${userModel.lname}${userModel.fname}',
                    style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              _image != null
                                  ?
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.memory(
                                  _image!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : (profilePicture.isNotEmpty
                                  ?
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  profilePicture,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  :
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.asset(
                                  "assets/img/logo.png",
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              )),
                              if (_isCurrentUser)
                                Positioned(
                                  bottom: -10,
                                  left: 75,
                                  child: IconButton(
                                    onPressed: () {
                                      pickImage(ImageSource.gallery);
                                    },
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      color: TColor.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // display role
                          if (snapshot.data?.role == 'Trainer')
                            const Text(
                              "T R A I N E R",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20),
                            )
                          // else if (snapshot.data?.role == 'Trainee')
                          //   const Text(
                          //     "T R A I N E E",
                          //     style: TextStyle(
                          //         color: Colors.blue,
                          //         fontSize: 20),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                MyProfileStats(
                  postCount: allUserPosts.length,
                  followerCount: followerCount,
                  followingCount: followingCount,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowListPage(uid: widget.uid),
                    ),
                  ),
                ),
                if (FirebaseAuth.instance.currentUser?.uid != widget.uid)
                  MyFollowButton(
                    onPressed: _toggleFollow,
                    isFollowing: _isFollowing,
                  ),
                if (_isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "BIO",
                          style: TextStyle(color: TColor.gray),
                        ),
                        GestureDetector(
                          onTap: _showEditBioBox,
                          child: Icon(
                            Icons.settings,
                            color: TColor.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!_isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "BIO",
                          style: TextStyle(color: TColor.gray),
                        ),
                        const SizedBox(width: 40),  // Empty space instead of settings icon
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                MyBioBox(text: userModel.bio),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 25),
                  child: Text(
                    "Posts",
                    style: TextStyle(color: TColor.gray),
                  ),
                ),
                allUserPosts.isEmpty
                    ?
                const Center(
                  child: Text("No posts yet.."),
                )
                    :
                ListView.builder(
                  itemCount: allUserPosts.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final post = allUserPosts[index];
                    return MyPostTile(
                      post: post,
                      onUserTap: () {},
                      onPostTap: () => goPostPage(context, post),
                    );
                  },
                ),
              ],
            );
          } else {
            return const Center(child: Text('No user data found'));
          }
        },
      ),
    );

  }
}