
import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  final Map pObj;
  const OnBoardingPage({super.key, required this.pObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return

      SizedBox(
        width: media.width,
        height: media.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              pObj["image"].toString(),
              //width: media.width,
              fit: BoxFit.contain,
            ),

            SizedBox(height: media.width * 0.25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                pObj["title"].toString(),
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 45,
                    fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 15,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                pObj["subtitle"].toString(),
                style: TextStyle(
                    color: TColor.gray,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
  }
}