import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:diet_app/screen/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  TextEditingController messageController = TextEditingController();

  Future<void> saveFeedbackData() async {
    try {
      // get the current users ID
      final userId = FirebaseAuth.instance.currentUser!.uid;
      // Generate a unique document ID for each feedback submission
      final feedbackDocRef = FirebaseFirestore.instance
          .collection('feedbacks')
          .doc();

      // save the feedback in firestore
      await feedbackDocRef.set({
        'userID': userId,
        'rating' : _rating,
        'dateTime' : DateTime.now(),
        'comment' : messageController.text,
        'status' : 1,
      });

      print("Successfully saved feedback");

    } catch(e, printStack){
      print('Error saving feedback data: $e');
      print(printStack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.primaryG,
          ),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScroller) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: TColor.lightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              title: Text(
                "Feedback Page",
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.more_horiz_rounded),
                  ),
                )
              ],
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/feedback2.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            )
          ],
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TColor.gray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                   Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        const Text(
                          "Rate Your Experience",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Are you satisfied with the application?",
                          style:TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        ),

                        const SizedBox(height: 10,),

                        buildStar(),
                        Divider(
                          color: TColor.gray, // Set the color of the divider
                          thickness: 2.0, // Set the thickness of the divider
                          height: 20.0, // Set the height of the divider
                          indent: 20.0, // Set the left indentation of the divider
                          endIndent: 20.0, // Set the right indentation of the divider
                        ),


                        const SizedBox(height: 20),

                        const Text(
                          "Let us know what can be improved",
                          style:TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: RoundTextField(
                            controller: messageController,
                              hitText: "Message",
                              icon: "assets/img/email.png",
                              obscureText: false),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColor.secondaryColor1,
                              elevation: 10,
                              shape: const StadiumBorder()
                            ),
                            child: Text(
                              "SEND",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: TColor.white,
                                fontSize: 16),
                            ),
                            onPressed: (){
                              if(messageController.text.trim().isNotEmpty){
                                saveFeedbackData();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => buildSuccessPage(),
                                  ),
                                );
                              }
                            },
                          ),
                        )
                        // Add any additional widgets here
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            // Handle the star tap
            setState(() {
              _rating = index + 1;
            });
          },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: TColor.secondaryColor2,
            size: 40.0,
          ),
        );
      }),
    );
  }

  Widget buildSuccessPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100.0,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Thanks for your feedback!',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                'We appreciate your feedback—it fuels our improvement process.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600
                ),
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()
                        ), (route) => false
                    );
                  },
                  child: const Text("Return")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
