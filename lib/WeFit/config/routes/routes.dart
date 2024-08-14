// import 'dart:ffi';
//
// import 'package:diet_app/WeFit/screens/screens.dart';
// import 'package:diet_app/facebook/core/error_screen.dart';
// import 'package:diet_app/facebook/features/posts/presentation/screens/create_post_screen.dart';
// import 'package:diet_app/facebook/home/home_screenfb.dart';
// import 'package:flutter/cupertino.dart';
//
//
// class Routes {
//   static Route onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       // case CreateAccountScreen.routeName:
//       //   return _cupertinoRoute(
//       //     const CreateAccountScreen(),
//       //   );
//       case HomeScreen.routeName:
//         return _cupertinoRoute(
//           const HomeScreen(),
//         );
//       case CreatePostScreen.routeName:
//         return _cupertinoRoute(
//           const CreatePostScreen(),
//         );
//       // case CommentsScreen.routeName:
//       //   final postId = settings.arguments as String;
//       //   return _cupertinoRoute(
//       //     CommentsScreen(postId: postId),
//       //   );
//       // case ProfileScreen.routeName:
//       //   final userId = settings.arguments as String;
//       //   return _cupertinoRoute(
//       //     ProfileScreen(
//       //       userId: userId,
//       //     ),
//       //   );
//       // case CreateStoryScreen.routeName:
//       //   return _cupertinoRoute(
//       //     const CreateStoryScreen(),
//       //   );
//       // case StoryViewScreen.routeName:
//       //   final stories = settings.arguments as List<Story>;
//       //   return _cupertinoRoute(
//       //     StoryViewScreen(
//       //       stories: stories,
//       //     ),
//       //   );
//       // case ChatScreen.routeName:
//       //   final arguments = settings.arguments as Map<String, dynamic>;
//       //   final userId = arguments['userId'] as String;
//       //   return _cupertinoRoute(
//       //     ChatScreen(
//       //       userId: userId,
//       //     ),
//       //   );
//       // case ChatsScreen.routeName:
//       //   return _cupertinoRoute(
//       //     const ChatsScreen(),
//       //   );
//       default:
//         return _cupertinoRoute(
//           ErrorScreen(
//             error: 'Wrong Route provided ${settings.name}',
//           ),
//         );
//     }
//   }
//
//   static Route _cupertinoRoute(Widget view) => CupertinoPageRoute(
//     builder: (_) => view,
//   );
//
//   Routes._();
// }