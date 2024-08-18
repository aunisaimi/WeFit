import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit2/components/my_drawer.dart';
import 'package:diet_app/WeFit2/components/my_input_alert_box.dart';
import 'package:diet_app/WeFit2/components/my_post_tile.dart';
import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/WeFit2/helper/navigate_pages.dart';
import 'package:diet_app/WeFit2/models/post.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../StepCounterService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Uint8List? _image;
  final imagePicker = ImagePicker();
  String profilePicture = '';
  // providers
  late final listeningProvider =
    Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
    Provider.of<DatabaseProvider>(context, listen: false);

  // controller
  final _messageController = TextEditingController();
  StepCounterService stepCounterService = StepCounterService();

  // show post msg dialog box
  void _openPostMessageBox(){
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: _messageController,
            hintText: "What's on your mind?",
            onPressed: () async {
              // post msg to db
              await postMessage(_messageController.text);
            },
            onPressedText: "Post")
    );
  }

  // user wants to post msg
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  // on startup
  @override
  void initState(){
    super.initState();
    loadAllPosts();
    fetchUserData();
  }

  // load all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
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
          profilePicture = userDoc['profilePicture'];
        });
        print("this is current profile picture: ${userDoc['profilePicture']}");
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
    // controller tab. -> for you and following
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        drawer: MyDrawer(),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'H O M E',
            style: TextStyle(
                color: TColor.gray
            ),
          ),
          backgroundColor: Colors.grey[200],
          foregroundColor: TColor.gray,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Colors.grey[700],
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: TColor.secondaryColor1,
            tabs: [
              Tab(text: "For You"),
              Tab(text: "Following"),
            ],
          ),
        ),
      
        // floating action button
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.add),
        ),
      
        // Body: List all posts
        //body: _buildPostList(listeningProvider.allPosts),
        body: TabBarView(
            children: [
              _buildPostList(listeningProvider.allPosts),
              _buildPostList(listeningProvider.followingPosts),
            ]),
      ),
    );
  }

  // build list UI given a list of posts
  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ?
    // post list is empty
    const Center(
      child: Text("Nothing here.."),
    )
        :
    // post list is not empty
    ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context,index){
        // get each individual post
        final post = posts[index];
        // return Post Tile UI
        return MyPostTile(
          post: post,
          onUserTap: () => goUserPage(context, post.uid),
          onPostTap: () => goPostPage(context, post),
        );
      },
    );
  }
}
