import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit/config/palette.dart';
import 'package:diet_app/WeFit/data/data(dummy).dart';
import 'package:diet_app/WeFit/widgets/circle_button.dart';
import 'package:diet_app/WeFit/widgets/create_post_container.dart';
import 'package:diet_app/WeFit/widgets/post_container.dart';
import 'package:diet_app/WeFit/widgets/stories.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:diet_app/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../widgets/rooms.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  UserModel? currentUserModel;

  TextEditingController txtDate = TextEditingController();
  TextEditingController txtWeight = TextEditingController();
  TextEditingController txtHeight = TextEditingController();
  TextEditingController initialCalories = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          currentUserModel = UserModel.fromDoc(userDoc);
          _emailController.text = currentUserModel!.email;
          _firstnameController.text = currentUserModel!.fname;
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

  @override
  Widget build(BuildContext context) {
    if (currentUserModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: TColor.white,
            title: const Text(
              'WeFit',
              style: TextStyle(
                  color: Palette.facebookBlue,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.2),
            ),
            centerTitle: false,
            floating: true,
            actions: [
              CircleButton(
                icon: Icons.search,
                iconSize: 30.0,
                onPressed: () => print('Search'),
              ),
              CircleButton(
                icon: MdiIcons.facebookMessenger,
                iconSize: 30.0,
                onPressed: () => print('Messenger'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  CreatePostContainer(currentUser: currentUserModel!),
                  Rooms(onlineUsers: onlineUsers),
                  Stories(currentUser: currentUserModel!, stories: stories),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('An error occurred: ${snapshot.error}')),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text('No posts available')),
                );
              }

              final posts = snapshot.data!.docs
                  .map((doc) => Post.fromDoc(doc))
                  .toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Posts(post: posts[index]);
                  },
                  childCount: posts.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
