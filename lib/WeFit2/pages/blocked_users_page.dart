import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  late DatabaseProvider databaseProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadBlockedUsers();
    });
  }

  Future<void> loadBlockedUsers() async {
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    await databaseProvider.loadBlockedUsers();
    print('Blocked users loaded: ${databaseProvider.blockedUsers}');
  }

  void _showUnblockConfirmationBox(String userId) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Unblock User"),
          content: const Text("Are you sure you want to unblock this user?"),
          actions: [
            TextButton(
              onPressed: () {
                print('Unblock cancelled for user: $userId');
                Navigator.pop(context);
            },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                print('Unblock confirmed for user: $userId');
                await databaseProvider.unblockUser(userId);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User Unblocked")));
              },
              child: const Text("Unblock"),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final blockedUsers = Provider.of<DatabaseProvider>(context).blockedUsers;

    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: Text(
            "Blocked Users",
            style: TextStyle(color: TColor.gray, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: blockedUsers.isEmpty
            ? const Center(
          child: Text("No Blocked Users.."),
        )
            : ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];

              return ListTile(
                title: Text(
                  '${user.fname} ${user.lname}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('@${user.lname}'),
                trailing: IconButton(
                    onPressed: () => _showUnblockConfirmationBox(user.uid),
                    icon: const Icon(Icons.block)),
              );
            }));
  }
}
