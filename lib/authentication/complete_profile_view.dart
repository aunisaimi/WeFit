import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/authentication/what_your_goal_view.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({Key? key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  TextEditingController txtDate = TextEditingController();
  TextEditingController txtWeight = TextEditingController();
  TextEditingController txtHeight = TextEditingController();
  String? selectedRole;
  String? selectedGender;
  String? selectedCareer;
  String? ageErrorMessage;

  Future<void> updateUserProfile(double initialCalories) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        // Update Firestore document with user profile information
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({
          'dateOfBirth': txtDate.text,
          'weight': txtWeight.text,
          'height': txtHeight.text,
          'gender': selectedGender,
          'career': selectedCareer,
          'initialCalories': initialCalories,
          'role': selectedRole,
        });
        print('User profile updated successfully!');
      } else {
        print('User not signed in.');
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  int calculateAge(String date) {
    DateTime birthDate = DateFormat('MM/dd/yyyy').parse(date);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double getInitialCalories(String gender, String career, int age) {
    if (career == 'Teenager') {
      return age <= 19 ? 1600 : 2400;
    } else if (career == 'Athlete Teenager') {
      return 5000;
    } else if (career == 'Office') {
      if (gender == 'Male') {
        return 2050; // Average between 2000 and 2100
      } else {
        return 1700; // Average between 1600 and 1800
      }
    } else if (career == 'Strenuous') {
      if (gender == 'Male') {
        return 3000; // Average between 2500 and 3500
      } else {
        return 2400; // Average between 2000 and 2800
      }
    }
    return 0.0;
  }

  void validateAndProceed() {
    int age = calculateAge(txtDate.text);
    if (age < 16) {
      setState(() {
        ageErrorMessage = "Age must be 16 or older";
      });
    } else {
      setState(() {
        ageErrorMessage = null;
      });
      double initialCalories = getInitialCalories(selectedGender!, selectedCareer!, age);
      updateUserProfile(initialCalories);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WhatYourGoalView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/img/complete_profile.png",
                  width: media.width,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: media.width * 0.05),
                Text(
                  "Let's Complete Your Profile",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),

                SizedBox(height: media.width * 0.05),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Image.asset(
                                "assets/img/gender.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: TColor.gray,
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedGender,
                                  items: ["Male", "Female"].map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          color: TColor.gray,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                  isExpanded: true,
                                  hint: Text(
                                    "Choose Gender",
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      SizedBox(height: media.width * 0.04),
                      Container(
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Image.asset(
                                "assets/img/p_achi.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: TColor.gray,
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCareer,
                                  items: [
                                    "Office",
                                    "Strenuous",
                                    "Teenager",
                                    "Athlete Teenager"
                                  ].map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          color: TColor.gray,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCareer = value;
                                    });
                                  },
                                  isExpanded: true,
                                  hint: Text(
                                    "Choose Career",
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                          ],
                        ),
                      ),
                      SizedBox(height: media.width * 0.04),
                      Container(
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 50,
                              width: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Image.asset(
                                "assets/img/role.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: TColor.gray,
                              ),
                            ),
                            Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedRole,
                                    items: ["Trainer", "Trainee"].map((name) {
                                      return DropdownMenuItem<String>(
                                          value: name,
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              color: TColor.gray,
                                              fontSize: 14,
                                            ),
                                          ),
                                      );
                                    }).toList(),
                                    onChanged: (value){
                                      setState(() {
                                        selectedRole = value;
                                      });
                                    },
                                    isExpanded:true,
                                    hint: Text(
                                      "Choose Role",
                                      style: TextStyle(
                                        color:TColor.gray,
                                        fontSize: 12,
                                      ),
                                    )
                                  ),
                                ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      SizedBox(height: media.width * 0.04),
                      RoundTextField(
                        controller: txtDate,
                        hitText: "Date of Birth (MM/dd/yyyy)",
                        icon: "assets/img/menu_schedule.png",
                        obscureText: false,
                        //textInputType: TextInputType.datetime,
                      ),
                      if (ageErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            ageErrorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      SizedBox(height: media.width * 0.04),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: RoundTextField(
                      //         controller: txtWeight,
                      //         hitText: "Your Weight",
                      //         icon: "assets/img/menu_weight.png",
                      //         obscureText: false,
                      //        // textInputType: TextInputType.number,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Container(
                      //       width: 50,
                      //       height: 50,
                      //       alignment: Alignment.center,
                      //       decoration: BoxDecoration(
                      //         gradient: LinearGradient(
                      //           colors: TColor.secondaryG,
                      //         ),
                      //         borderRadius: BorderRadius.circular(15),
                      //       ),
                      //       child: const Text(
                      //         "KG",
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: media.width * 0.04),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: RoundTextField(
                      //         controller: txtHeight,
                      //         hitText: "Your Height",
                      //         icon: "assets/img/menu_traning_status.png",
                      //         obscureText: false,
                      //         // textInputType: TextInputType.number,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 8),
                      //     Container(
                      //       width: 50,
                      //       height: 50,
                      //       alignment: Alignment.center,
                      //       decoration: BoxDecoration(
                      //         gradient: LinearGradient(
                      //           colors: TColor.secondaryG,
                      //         ),
                      //         borderRadius: BorderRadius.circular(15),
                      //       ),
                      //       child: const Text(
                      //         "CM",
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: media.width * 0.07),
                      RoundButton(
                        title: "Next >",
                        onPressed: () {
                          validateAndProceed();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
