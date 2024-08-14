import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/screen/settings/ContactUsPage.dart';
import 'package:diet_app/screen/settings/feedback_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        // leading: InkWell(
        //   onTap: () {Navigator.pop(context);},
        //   child: Container(
        //     margin: const EdgeInsets.all(8),
        //     height: 40,
        //     width: 40,
        //     alignment: Alignment.center,
        //     decoration: BoxDecoration(
        //       color: TColor.lightGray,
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: const Icon(Icons.arrow_back_ios_new_rounded),
        //   ),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackPage()
                    )
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: TColor.secondaryG,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Feedback",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ContactUsPage()
                    )
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: TColor.secondaryG,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Contact Us",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
