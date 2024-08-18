import 'package:diet_app/WeFit/screens/nav_screen.dart';
import 'package:diet_app/WeFit/screens/screens.dart';
import 'package:diet_app/WeFit2/pages/homepage.dart';
import 'package:diet_app/model/diet.dart';
import 'package:diet_app/screen/StepCounterApp.dart';
import 'package:diet_app/screen/meal_planner/dietandfitness/DietPlanner.dart';
import 'package:diet_app/screen/meal_planner/dietandfitness/meal_plan_view.dart';
import 'package:diet_app/screen/water_intake/water_intake.dart';
import 'package:diet_app/screen/workout_tracker/add_exercise.dart';
import 'package:flutter/material.dart';

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

            RoundButton(
                title: "Step Counter",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StepCounterHome(),
                    ),
                  );
                }),

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
          ],
        ),
      ),
    );
  }
}