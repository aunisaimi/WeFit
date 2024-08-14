import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:diet_app/screen/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  TextEditingController messageController = TextEditingController();

  Future<void> saveContactData() async{
    try{

      // get the current users ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Generate a unique document ID for each submission
      // final conDocRef = FirebaseFirestore.instance.collection('contacts').doc();

      // update the contacts document in firestore
      await FirebaseFirestore.instance.collection('contacts').add({
        'userID': userId,
        'dateTime' : DateTime.now(),
        'comment' : messageController.text,
        'status' : 1,
      });

      print("-------------------------Successfully saved data-------------------------------");

    } catch(e){
      print('Error saving data: $e');

    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
                "Contact Us",
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
                  "assets/img/welcome.png",
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
                          "Need Help?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // const SizedBox(height: 20),
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: RoundTextField(
                              controller: messageController,
                              hitText: "Tell us how we can help",
                              icon: "assets/img/menu_support.png",
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
                                saveContactData();
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
                'Thanks for your contact!',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Color(0xF6F5F5FF),
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'We will do our best to help you! Thank you for supporting us',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xF6F5F5FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
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
