import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/model/steps.dart';
import 'package:diet_app/screen/countdown/countdown_screen.dart';
import 'package:diet_app/screen/countdown/stopwatch_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../database/auth_service.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Map eObj;
  //final Map eObj; // exercise obj contains details about exercise
  final String image;
  final String? duration;
  String value;
  final String document;
  final String difficulty;
  final String exerciseName;
  final String? description;
  final String steps;
  String? type;
  final String historyId;
  //Function(Map<String,dynamic>) createHistoryEntry;

   ExercisesStepDetails({
    Key? key,
    required this.eObj,
    required this.image,
    this.duration,
    required this.value,
    required this.document,
    required this.difficulty,
    required this.exerciseName,
    this.description,
    required this.steps,
    this.type,
    required this.historyId,

    // required this.createHistoryEntry
  }) : super(key: key);

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService authService = AuthService();
  String? exerciseType;
  String? exerciseValue;
  String? _youtubeLink;


  List<StepModel> stepArr = []; // list to store steps of exercises


  Future<void> fetchSteps() async {
    try {
      String exerciseName = widget.document;
      String difficulty = widget.difficulty.toLowerCase();
      print('Fetching steps for exercise: $exerciseName, Difficulty: $difficulty');

      DocumentSnapshot<Map<String,dynamic>> exerciseDoc = await _firestore
          .collection('exercises')
          .doc(difficulty) //beginner
          .collection(exerciseName)
          .doc(exerciseName)
          .get();

      if (exerciseDoc.exists){
        print("Exercise found: $exerciseName");
        Map<String,dynamic> data = exerciseDoc.data() ?? {};

        // fetch youtube link from the main exercise doc
        // String? youtubeLink = data['youtubeLink'] as String?;
        //
        // setState(() {
        //   // store the yt link
        //   _youtubeLink = youtubeLink;
        // });

        // Extracting exercise type and duration/freq
        String type = data['type'];
        String value = data['value'];
        _youtubeLink = data['youtubeLink'];

        print("Type: $type");
        print("Value: $value");
        print("YouTube Link: $_youtubeLink");

        setState(() {
          widget.type = type;
          widget.value = value;
        });

        // Fetching steps from the sub-collection
        DocumentSnapshot<Map<String,dynamic>> stepsDoc = await exerciseDoc
            .reference
            .collection('steps')
            .doc('steps')
            .get();

        if (stepsDoc.exists){
          print('Steps found for exercise: $exerciseName');
          Map<String,dynamic> stepsData = stepsDoc.data() ?? {};

          List<String> orderedKeys = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth'];

          // Sort the keys in the correct order
          List<String> sortedKeys = stepsData.keys.toList();
          sortedKeys.sort((a, b) {
            return orderedKeys.indexOf(a).compareTo(orderedKeys.indexOf(b));
          });

          // Create the steps list in the correct order
          List<StepModel> stepsList = sortedKeys.map((key) {
            String stepNumber = key;
            String stepDescription = stepsData[key] as String;

            // Create a map to match the expected structure for StepModel.fromMap
            Map<String, dynamic> stepData = {
              'steps': stepNumber,
              'description': stepDescription,
            };

            return StepModel.fromMap(stepData);
          }).toList();

          setState(() {
            stepArr = stepsList;
          });
        } else {
          print('No steps found for the exercise: $exerciseName');
        }
      } else {
        print('No exercise found: $exerciseName');
      }
    }  catch (e, printStack) {
      print('Error fetching steps: $e');
      print(printStack);
    }
  }

  Future<String> _addToHistory({required String userId, required Map exercise, required String status}) async {
    try {
      // Fetch user details from the 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print("User details not found for userId: $userId");
        return '';
      }

      // Retrieve only the necessary user details
      Map<String, dynamic> userDetails = userDoc.data() ?? {};
      Map<String, dynamic> selectedUserDetails = {
        'fname': userDetails['fname'],
        'weight': userDetails['weight'],
        'bmi': userDetails['bmi'],
      };

      // Add the exercise and selected user details to the 'history' collection
      DocumentReference historyRef = await _firestore.collection('history').add({
        'userId': userId,
        'exercise': exercise,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'userDetails': selectedUserDetails, // Include only selected user details
      });

      String historyId = historyRef.id; // Get the generated history ID
      print("Exercise added to the history: ${exercise['name']}");
      print("Generated historyId: $historyId"); // Print the generated historyId
      return historyId; // Return the generated historyId
    } catch (e, stackTrace) {
      print("Error adding to Firestore history: $e");
      print(stackTrace);
      return ''; // Return an empty string if an error occurs
    }
  }

  Future<void> _updateHistoryStatus(String historyId, String status) async {
    try {
      print('history id : $historyId');
      if (historyId.isEmpty) {
        throw Exception("Invalid historyId");
      }

      await _firestore.collection('history').doc(historyId).update({
        'status': status,
        'completedAt': FieldValue.serverTimestamp(),
      });

      print("History status updated to $status");
    } catch (e, printStack) {
      print("Error updating history status: $e");
      print(printStack);
    }
  }

  @override
  void initState() {
    super.initState();
    print("Document to be opened: ${widget.document}");
    //print("Steps: ");
    //fetchExerciseName();
    fetchSteps();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                      color: TColor.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.network(
                      widget.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_youtubeLink != null && _youtubeLink!.isNotEmpty){
                        final Uri url = Uri.parse(_youtubeLink!);
                        if (await canLaunchUrl(url)){
                          await launchUrl(url);
                        } else {
                          print("Could not launch $url");
                        }
                      } else {
                        print("No youtube link available for the exercise");
                      }
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                widget.eObj["name"].toString().replaceAll('_', ' '),
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.difficulty,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Descriptions",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                widget.eObj['description'],
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "How To Do It",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          color: TColor.black.withOpacity(0.7),
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "${stepArr.length} sets",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: stepArr.length,
                itemBuilder: (context, index) {
                  var step = stepArr[index];
                  return ListTile(
                    title: Text(step.stepNumber),
                    subtitle: Text(step.description),
                  );
                  // return StepDetailRow(
                  //   sObj: sObj,
                  //   isLast: stepArr.last == sObj,
                  // );
                },
              ),

              const SizedBox(height: 20),

              RoundButton(
                title: "Start",
                elevation: 1,
                onPressed: () async {
                  final User? user = _auth.currentUser;
                  if (user != null) {
                    String historyId = await _addToHistory(
                      userId: user.uid,
                      exercise: widget.eObj,
                      status: "pending",
                    );
                    if (historyId.isNotEmpty) {
                      if (widget.type == 'duration' && widget.value.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CountdownScreen(
                              duration: widget.value,
                              historyId: historyId,
                            ),
                          ),
                        );
                      } else if (widget.type == 'frequency') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StopwatchScreen(
                              exerciseName: widget.exerciseName,
                              historyId: historyId,
                            ),
                          ),
                        );
                      } else {
                        print('Invalid exercise type');
                      }
                    } else {
                      print('Failed to add workout to history');
                    }
                  } else {
                    print("No User signed in");
                  }
                },
              ),
              const SizedBox(height: 15),
              // RoundButton(
              //   title: "Complete Workout",
              //   elevation: 1,
              //   onPressed: () async {
              //     if (widget.historyId != null && widget.historyId.isNotEmpty) {
              //       await _updateHistoryStatus(widget.historyId, "completed");
              //       Navigator.pop(context);
              //     } else {
              //       print("HistoryId is null or empty.");
              //       // Handle the case where historyId is null or empty
              //     }
              //   },
              // )
              //const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}