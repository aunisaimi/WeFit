import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class AnimationTry extends StatefulWidget {
  const AnimationTry({super.key});

  @override
  State<AnimationTry> createState() => _AnimationTryState();
}

class _AnimationTryState extends State<AnimationTry> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animation Dialogue'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(50),
          child: Column(
            children: [
              AnimatedButton(
                  text: "warning dialogue",
                  color: Colors.orange,
                  pressEvent: (){
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.topSlide,
                      showCloseIcon: true,
                      title: "Warning",
                      desc: "This is desc",
                      btnOkOnPress: (){},
                      btnCancelOnPress: (){}
                    ).show();
                  }),
              const SizedBox(height: 16),
              AnimatedButton(
                  text: "error dialogue",
                  color: Colors.red,
                  pressEvent: (){
                    AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.bottomSlide,
                        showCloseIcon: true,
                        title: "error",
                        desc: "This is desc",
                        btnOkOnPress: (){},
                        btnOkIcon: Icons.cancel,
                        btnOkColor: Colors.red
                    ).show();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
