import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/WeFit2/pages/homepage.dart';
import 'package:diet_app/animation_try.dart';
import 'package:diet_app/model/diet.dart';
import 'package:diet_app/screen/StepCounterApp.dart';
import 'package:diet_app/screen/meal_planner/dietandfitness/DietPlanner.dart';
import 'package:diet_app/screen/meal_planner/dietandfitness/meal_plan_view.dart';
import 'package:diet_app/screen/water_intake/water_intake.dart';
import 'package:diet_app/screen/workout_tracker/add_exercise.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/RoundButton.dart';
import '../workout_tracker/workout_tracker_view.dart';

class SelectView extends StatefulWidget {
  const SelectView({super.key});

  @override
  State<SelectView> createState() => _SelectViewState();
}

class _SelectViewState extends State<SelectView> {
  @override
  Widget build(BuildContext context) {
    List<Diet> diets = [];
    double currentIntake = 0;
    final double targetIntake = 4000;

    int _totalSteps = 0;
    int _previousTotalSteps = 0;
    String _stepCountValue = '0';

    Future<void> _fetchStepCountFromFirestore() async {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        setState(() {
          _totalSteps = snapshot.data()?['totalSteps'] ?? 0;
          _previousTotalSteps = snapshot.data()?['previousTotalSteps'] ?? 0;
        });
      }
    }

    Future<void> _loadSavedSteps() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _totalSteps = prefs.getInt('totalSteps') ?? 0;
        _previousTotalSteps = prefs.getInt('previousTotalSteps') ?? 0;
      });

      await _fetchStepCountFromFirestore();
    }

    @override
    void initState() {
      super.initState();
      _loadSavedSteps(); // Call this to load steps when the view is initialized
    }



    void updateIntake(double intake) {
      setState(() {
        currentIntake += intake;
      });
    }
    // var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundButton(
                title: "Workout Tracker",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkoutTrackerView(
                            document: '',
                            title: ''),
                    ),
                  );
                }),

            const SizedBox(height: 15,),

            RoundButton(
                title: "Meal Planner",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  MealPlanView(
                        //remainingCalories: 2500,
                        onCaloriesUpdated: (int value) {  },),
                    ),
                  );
                }),

            const SizedBox(height: 15),

            RoundButton(
                title: "Diet Helper",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  MealPlanner(
                          dietType:  diets.map(
                              (diet) => diet.dietType).toList()),
                    ),
                  );
                }),

            const SizedBox(height: 15),
          // RoundButton(
          //   title: "Step Counter",
          //   onPressed: () async {
          //     // Navigate to StepCounterHome and ensure state is properly reset
          //     bool shouldReload = await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => StepCounterHome(),
          //       ),
          //     );
          //
          //     if (shouldReload != null && shouldReload) {
          //       // Reload step data in HomeView after returning from StepCounterHome
          //       await _loadSavedSteps();
          //     }
          //   },
          // ),

            RoundButton(
              title: "Step Counter",
              onPressed: () async {
                // Navigate to StepCounterHome and ensure state is properly reset
                bool shouldReload = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StepCounterHome(),
                  ),
                ) ?? false;  // Handle null case with a default value

                if (shouldReload) {
                  // Reload step data in HomeView after returning from StepCounterHome
                  await _loadSavedSteps();
                }
              },
            ),

            // RoundButton(
            //   title: "Step Counter",
            //   onPressed: () async {
            //     // Navigate to StepCounterHome and ensure state is properly reset
            //     await Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => StepCounterHome(),
            //       ),
            //     ).then((_) {
            //       // Optional: Perform any actions after returning from StepCounterHome if needed
            //     });
            //   },
            // ),

            const SizedBox(height: 15),

            RoundButton(
                title: "WeFit 2.0",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  HomePage()
                    ),
                  );
                }),


            //const SizedBox(height: 15),

            const SizedBox(height: 15),

            RoundButton(
                title: "Track Water Intake",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  WaterIntake(
                          onUpdate: updateIntake),
                    ),
                  );
                }),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}