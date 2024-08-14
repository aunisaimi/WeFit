import 'package:diet_app/WeFit2/components/my_user_tile.dart';
import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/WeFit2/models/user.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;

  const FollowListPage({super.key, required this.uid});

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  late final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  // on startup
  @override
  void initState(){
    super.initState();

    // load follower list
    loadFollowerList();

    // load following list
    loadFollowingList();
  }

  // load followers
  Future<void> loadFollowerList() async {
    await databaseProvider.loadUserFollowerProfiles(widget.uid);
    print("Followers for ${widget.uid}:"
        " ${databaseProvider.getListOfFollowersProfile(widget.uid)}");
  }

  // load following
  Future<void> loadFollowingList() async {
    await databaseProvider.loadUserFollowingProfiles(widget.uid);
    print("Following for ${widget.uid}:"
        " ${databaseProvider.getListOfFollowingProfile(widget.uid)}");
  }

  @override
  Widget build(BuildContext context) {
    // listen to followers and following
    // final followers = listeningProvider.getListOfFollowersProfile(widget.uid);
    // final following = listeningProvider.getListOfFollowingProfile(widget.uid);
    final followers = Provider.of<DatabaseProvider>(context).getListOfFollowersProfile(widget.uid);
    final following = Provider.of<DatabaseProvider>(context).getListOfFollowingProfile(widget.uid);

    // tab controller
    return DefaultTabController(
      length: 2,
      // scaffold
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          foregroundColor: TColor.secondaryColor1,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Colors.grey[700],
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: TColor.secondaryColor1,
            tabs: [
              Tab(text: "Followers"),
              Tab(text: "Following"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(followers, "No Followers"),
            _buildUserList(following, "No Following"),
          ],
        ),
      ),
    );
  }

  // BUILD USER LIST, GIVEN LIST OF PROFILES
  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ?
    Center(
      child: Text(emptyMessage),
    )
        :
    ListView.builder(
      itemCount: userList.length,
      itemBuilder: (context, index) {
        final user = userList[index];
        return MyUserTile(user: user);
      },
    );
  }
}
