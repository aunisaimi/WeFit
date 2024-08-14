/*
displays :
- individual post
- comments on the post
 */

import 'package:diet_app/WeFit2/components/my_comment_tile.dart';
import 'package:diet_app/WeFit2/components/my_post_tile.dart';
import 'package:diet_app/WeFit2/database_service/database_provider.dart';
import 'package:diet_app/WeFit2/helper/navigate_pages.dart';
import 'package:diet_app/WeFit2/models/post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context,listen: false);

  @override
  Widget build(BuildContext context) {

    // listen to all comments for this post
    final allComments = listeningProvider.getComments(widget.post.id);
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[200],
      ),

      // body
      body: ListView(
        children: [
          // post
          MyPostTile(
              post: widget.post,
              onUserTap: () => goUserPage(context, widget.post.uid),
              onPostTap: (){},
          ),
          
          // comments on this post
          allComments.isEmpty
              ? 
          // no comments yet
          const Center(
            child: Text("No Comments Yet ..."),) 
              :
          ListView.builder(
              itemCount: allComments.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context,index){
            // get each comment
            final comment = allComments[index];

            // return as comment title UI
            return MyCommentTile(
                comment: comment,
                onUserTap: () => goUserPage(context, comment.uid)
            );
          })
        ],
      ),
    );
  }
}
