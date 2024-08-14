import 'package:cached_network_image/cached_network_image.dart';
import 'package:diet_app/WeFit/config/palette.dart';
import 'package:diet_app/WeFit/models/models.dart';
import 'package:diet_app/WeFit/widgets/profile_avatar.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/model/UserModel.dart';
import 'package:flutter/material.dart';

class Stories extends StatelessWidget {
  final UserModel currentUser;
  final List<Story> stories;

  const Stories({
    Key? key,
    required this.currentUser,
    required this.stories
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: TColor.white,
      child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 8,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: 1 + stories.length,
          itemBuilder: (BuildContext context, int index){
            if (index == 0){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _StoryCard(
                    isAddStory: true,
                    currentUser: currentUser
                ),
              );
            }
            final Story story = stories[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _StoryCard(story: story),
            );
          }),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final bool isAddStory;
  final UserModel? currentUser;
  final Story? story;

  const _StoryCard({
    Key? key,
    this.isAddStory = false,
    this.currentUser,
    this.story
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: isAddStory ?
            currentUser!.profilePicture
                : story!.imageUrl,
            height: double.infinity,
            width: 110.0,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: double.infinity,
          width: 110.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              TColor.primaryColor2.withOpacity(0.4),
              TColor.primaryColor1.withOpacity(0.1),
            ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
        ),
        Positioned(
          top: 8.0,
          left: 8.0,
          child: isAddStory ? Container(
            height: 40.0,
            width: 40.0,
            decoration: BoxDecoration(
              color: TColor.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add),
              iconSize: 30,
              color: TColor.primaryColor1,
              onPressed: () => print('Add to Story'),
            ),
          ) : ProfileAvatar(
            imageUrl: story!.user.imageUrl,
            hasBorder: story!.isViewed,
          ),
        ),
        Positioned(
          bottom: 8.0,
          left: 8.0,
          right: 8.0,
          child: Text(
            isAddStory ? 'Add to Story' : story!.user.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
