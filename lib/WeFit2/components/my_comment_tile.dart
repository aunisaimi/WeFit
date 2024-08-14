import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/WeFit2/models/comment.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCommentTile extends StatelessWidget {
  final Comment comment;
  final void Function()? onUserTap;

  const MyCommentTile({
    super.key,
    required this.comment,
    required this.onUserTap
  });

  // show options for comments
  void _showOptions(BuildContext context) {
    // check if the post is owned by the user or not
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnComment = comment.uid == currentUid;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            // this comment belongs to current user
            if (isOwnComment)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  // Handle delete action
                  Navigator.pop(context);

                  // Access the DatabaseProvider instance
                  final listeningProvider = Provider.of<DatabaseProvider>(context, listen:false);
                  final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

                  await Provider.of<DatabaseProvider>(context,listen: false)
                      .deleteComment(comment.id, comment.postId);
                },
              )

            // This comment does not belong to the user
            else ...[
              // report comment button
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.red),
                title: const Text('Report'),
                onTap: () {
                  // Handle report action
                  Navigator.pop(context);
                },
              ),

              // block user
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  // Handle block user action
                  Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding outside
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),

      // padding inside
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        // color of post tile
        color: Colors.white70,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section -> profile pic / name / username
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                // profile pic
                Icon(Icons.person, color: TColor.gray),

                const SizedBox(width: 10),

                // name
                Text(
                  comment.name,
                  style: TextStyle(
                      color: TColor.gray,
                      fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(width: 5),

                // username handle
                Text(
                  '@${comment.username}',
                  style: TextStyle(
                      color: TColor.gray
                  ),
                ),

                const Spacer(),

                // buttons -> more options
                GestureDetector(
                  onTap: () => _showOptions(context),
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
            comment.message,
            style: TextStyle(
                color: TColor.gray
            ),
          ),
        ],
      ),
    );
  }
}
