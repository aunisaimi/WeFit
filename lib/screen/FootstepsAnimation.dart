// import 'package:flutter/material.dart';
//
// class FootstepsAnimation extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 100,
//       right: 110,
//       width: 150,
//       height: 150,
//       child: Image.asset(
//         'assets/img/cat_walking.gif',
//         height: 100,
//         fit: BoxFit.cover,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class FootstepsAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      // Adjust the position based on the screen dimensions
      top: screenHeight * 0.1,   // 10% from the top of the screen
      right: screenWidth * 0.35,  // 10% from the right of the screen
      width: screenWidth * 0.3,  // 30% of the screen width
      height: screenHeight * 0.2, // 30% of the screen height
      child: Image.asset(
        'assets/img/cat_walking.gif',
        fit: BoxFit.cover,
      ),
    );
  }
}
