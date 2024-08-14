import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:flutter/material.dart';

import 'on_boarding_view.dart';

class StartedView extends StatefulWidget {
  const StartedView({Key? key}) : super(key: key);

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  bool isChangeColor = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
        width: media.width,
        decoration: BoxDecoration(
          gradient: isChangeColor
              ? LinearGradient(
              colors: TColor.primaryG,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  "Diet & Fitness",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  "Everybody can get fit",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 16), // Added SizedBox instead of Spacer

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: RoundButton(
                    title: "Get Started",
                    type: isChangeColor
                        ? RoundButtonType.textGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      if (isChangeColor) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnBoardingView(),
                          ),
                        );
                      } else {
                        // change color
                        setState(() {
                          isChangeColor = true;
                        });
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
