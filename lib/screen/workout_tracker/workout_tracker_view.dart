import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/common_widget/upcoming_workout_row.dart';
import 'package:diet_app/common/common_widget/what_train_row.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/screen/countdown/countdown_screen.dart';
import 'package:diet_app/screen/countdown/stopwatch_screen.dart';
import 'package:diet_app/screen/home/activity_tracker_view.dart';
import 'package:diet_app/screen/workout_tracker/workout_detail_view.dart';
import 'package:diet_app/screen/workout_tracker/workout_schedule_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../database/auth_service.dart';
import 'exercise_step_detail.dart';

class WorkoutTrackerView extends StatefulWidget {
  final String document;
  final String title;
  WorkoutTrackerView({
    Key? key,
    required this.document,
    required this.title}) : super(key: key);

  @override
  _WorkoutTrackerViewState createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService authService = AuthService();
  List<Map<String,dynamic>> pendingWorkouts =[];

  final List<Map<String, dynamic>> latestArr = [
    {
      "image": "assets/img/1.png",
      "title": "full body ",
      "time": "Today, 03:00pm"
    },
    {
      "image": "assets/img/leg_extension.jpg",
      "title": "legs",
      "time": "Tomorrow, 10:00am"
    }
  ];


  List<Map<String,dynamic>> whatArr =[];
  Map<String,int> totalTimes = {};

  @override
  void initState() {
    super.initState();
    fetchExercise();
    fetchTitles();
    fetchUserPendingWorkouts();
    print("History found: ${fetchPendingWorkouts('')}");
  }

  Future<void> fetchExercise() async {
    try {
      List<String> exerciseNames = ['jumping_jack','bear_crawl','donkey_kick','explosive_jump','skipping','squat','plank', 'pushup', 'situp', 'imaginary_chair', 'wall_pushup', 'bicycle_kick'];
      List<String> exerciseDifficulty = ['advanced','beginner','intermediate'];
      List<Map<String,dynamic>> exercisesList =[];
      Map<String,int> totalTimePerCategory = {};

      //for(String difficulty in exerciseDifficulty)
      for (String exerciseName in exerciseNames){
        print('Fetching exercises for path: exercises/$exerciseName');
        // QuerySnapshot<Map<String,dynamic>> querySnapshot = await FirebaseFirestore.instance
        //     .collection('exercises')
        //     .doc('beginner')
        //     .collection(exerciseName)
        //     .get();

        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection("exercises")
            .doc("beginner") // change this if needed
            .collection(exerciseName)
            .doc(exerciseName)
            .get();

        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data();
          if (data != null) {
            data['name'] = exerciseName; // Add the exercise name to the data
            exercisesList.add(data); // Add the exercise data to the list

            // update total time for the category
            String category = data['title'];
            num? timeEstimation = data['time']; // in seconds
            if (timeEstimation != null) {
              if (totalTimes.containsKey(category)){
                totalTimes[category] = totalTimes[category]! + timeEstimation.toInt();
              } else {
                totalTimes[category] = timeEstimation.toInt();
              }
            }
          }
        }
      }
      setState(() {
        //whatArr = exercisesList;
        whatArr.addAll(exercisesList);
        // totalTimes = totalTimePerCategory;
      });
    } catch (e){
      print('Error fetching exercises: $e');
    }
  }

  Future<void> fetchTitles() async {
    try {
      // define the list of categories and the exercises within them
      List<String> titles = ['full_body','arms','legs','abs'];

      List<Map<String,dynamic>> titleList = [];

      // Loop through each category and fetch the exercises
      for (String title in titles){
        QuerySnapshot<Map<String,dynamic>> snapshot = await _firestore
            .collection('exercises')
            .doc('beginner')
            .collection(title)
            .get();

        for (var doc in snapshot.docs) {
          Map<String, dynamic>? data = doc.data();
          if (data != null) {
            //data['category'] = title; // Add the category title to the data
            data['title'] = title;
            titleList.add(data);// Add the title data to the list

            int timeEstimation = int.parse(data['time'].toString()) ?? 0;
            if(totalTimes.containsKey(title)){
              totalTimes[title] = totalTimes[title]! + timeEstimation;
            } else {
              totalTimes[title] = timeEstimation;
            }
          }
        }
      }

      setState(() {
        //whatArr = exercisesList;
        whatArr = titleList;
      });

    } catch (e,printStack){
      print('Error fetching exercises: $e');
      print(printStack);
    }
  }

  Future<void> _onViewMorePressed(BuildContext context, String title) async {
    List<Map<String,dynamic>> filteredExercises = whatArr
        .where((exercise) => exercise['title'] == title)
        .toList();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WorkoutDetailView(
                  exercises: filteredExercises,
                  category: '',
                  // document: 'jumping_jack',
                  // category: 'beginner',
                )
        )
    );
  }


  // Stream<List<Map<String, dynamic>>> fetchPendingWorkouts(String userId) {
  //   return _firestore
  //       .collection('history')
  //       .where('userId', isEqualTo: userId)
  //       .where('status', isEqualTo: 'pending')
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map(
  //           (doc) => doc.data() as Map<String, dynamic>).toList());
  // }

  Stream<List<Map<String, dynamic>>> fetchPendingWorkouts(String userId) {
    return _firestore
        .collection('history')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include the document ID
      return data;
    }).toList());
  }

  Future<void> fetchUserPendingWorkouts() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      fetchPendingWorkouts(user.uid).listen((workouts) {
        setState(() {
          pendingWorkouts = workouts;
        });
      });
    }
  }

  void resumeWorkout(Map<String, dynamic> workout) {
    String? historyId = workout['id'];
    print('History ID: $historyId');

    if (historyId != null && historyId.isNotEmpty) {
      if (workout['exercise']['type'] == 'duration') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CountdownScreen(
              duration: workout['exercise']['value'],
              historyId: historyId,
            ),
          ),
        );
      } else if (workout['exercise']['type'] == 'frequency') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StopwatchScreen(
              exerciseName: workout['exercise']['name'],
              historyId: historyId,
            ),
          ),
        );
      } else {
        print('Invalid exercise type');
      }
    } else {
      print('Invalid historyId: $historyId');
      // Handle the case where historyId is null or empty
    }
  }


  void navigateToExerciseStepDetails(Map<String, dynamic> workout) {
    print('HistoryId: ${workout['id']}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesStepDetails(
          eObj: workout['exercise'],
          image: workout['exercise']['image'] ?? 'default_image_url',
          duration: workout['exercise']['duration']?.toString() ?? '0',
          value: workout['exercise']['value']?.toString() ?? '0',
          document: workout['document'] ?? '',
          difficulty: workout['exercise']['difficulty'] ?? 'beginner',
          exerciseName: workout['exercise']['name']?? 'Unnamed Exercise',
          steps: workout['exercise']?['steps'] ?? '',
          historyId: workout['id'] ?? '',
        ),
      ),
    );
  }

  Future<void> _onSeeMorePressed(BuildContext context) async {
    // Simulate data fetching delay
    await Future.delayed(const Duration(seconds: 1));
    // Navigate to the desired screen after data fetching
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActivityTrackerView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
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
                "Activity Tracker",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
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
                  "assets/img/detail_top.png",
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
                  topRight: Radius.circular(25)),
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
                        borderRadius: BorderRadius.circular(3)),
                  ),

                  SizedBox(height: media.width * 0.05),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                    decoration: BoxDecoration(
                        color: TColor.primaryColor2.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        ClipOval(
                            child: Image.asset(
                              'assets/img/5.png',
                              width: 50,
                              height: 50,
                            )
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Stay consistent with your workout",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Your consistency will drive your results!",
                                  style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),

                  Row(
                    children: [
                      Text(
                        "Workout Schedule",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 10),


                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                        color: TColor.primaryColor2.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Daily Workout Schedule",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        SizedBox(
                          width: 88,
                          height: 35,
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const WorkoutScheduleView())),
                            style: ElevatedButton.styleFrom(
                              primary: TColor.primaryColor2,
                            ),
                            child: Text(
                              "Check",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: TColor.white,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: media.width * 0.05),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Pending Workout",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: fetchPendingWorkouts(user?.uid ?? ""),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No upcoming workouts'));
                      } else {
                        List<Map<String, dynamic>> pendingWorkouts = snapshot.data!;
                        return Column(
                          children: pendingWorkouts.map((workout) {
                            return GestureDetector(
                              onTap: () {
                                // Navigate to the exercise details screen and pass the workout details
                                resumeWorkout(workout);
                                // navigateToExerciseStepDetails(workout);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        TColor.primaryColor1,
                                        TColor.primaryColor2]
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    // Display the workout image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: workout['exercise'] != null &&
                                          workout['exercise']['image'] != null
                                          ? Image.network(
                                        workout['exercise']['image'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                          : Image.asset(
                                        'assets/img/Workout2.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Display the title and time
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workout['exercise'] != null
                                              ? workout['exercise']['name']
                                              : 'Workout',
                                          style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        // Text(
                                        //   workout['exercise'] != null
                                        //       ? workout['exercise']['time'].toString()
                                        //       : 'Time Not Set',
                                        //   style: TextStyle(
                                        //     color: TColor.lightGray,
                                        //     fontWeight: FontWeight.w500,
                                        //     fontSize: 14,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),

                  SizedBox(height: media.width * 0.05),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "What Do You Want to Train?",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),

                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    // get the unique titles from whatArr list
                    itemCount: whatArr.map((exercise) => exercise['title'])
                        .toSet()
                        .length,
                    itemBuilder: (context, index) {
                      // Get the unique titles from the whatArr list
                      final uniqueTitles = whatArr
                          .map((exercise) => exercise['title'])
                          .toSet()
                          .toList();

                      // Find the first exercise that matches the current unique title
                      final exercise = whatArr
                          .firstWhere((exercise) =>
                      exercise['title'] == uniqueTitles[index]);

                      final totalTime = totalTimes[uniqueTitles[index]] ?? 0; // get total time for category in seconds

                      return WhatTrainRow(
                        wObj: exercise,
                        onViewMorePressed: () {
                          _onViewMorePressed(
                              context,
                              exercise['title']);
                        },
                        totalTime: totalTime,
                      );
                    },
                  ),

                  SizedBox(height: media.width * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}