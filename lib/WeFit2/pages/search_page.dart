import 'package:diet_app/WeFit2/components/my_user_tile.dart';
import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  // provider
  late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search users..",
            hintStyle: TextStyle(
              color: TColor.gray,
            ),
            border: InputBorder.none,
          ),

          // search will begin after new character begin
          onChanged: (value){
            // search users
            if(value.isNotEmpty){
              databaseProvider.searchUsers(value);
            }

            // clear result
            else{
              databaseProvider.searchUsers("");
            }
          },
        ),
      ),
      body: listeningProvider.searchResult.isEmpty
          ?
      const Center(
        child: Text("No Users Found"),
      )
          :
      ListView.builder(
        itemCount: listeningProvider.searchResult.length,
        itemBuilder: (context, index) {
          // get user from search result
          final user = listeningProvider.searchResult[index];
          print("User found: ${user.uid}, ${user.fname}, ${user.lname}"); // Debugging statement
          return MyUserTile(user: user);
        },
      ),

    );
  }
}
