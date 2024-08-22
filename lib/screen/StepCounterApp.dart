import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/screen/FootstepsAnimation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';

class StepCounterHome extends StatefulWidget {
  @override
  _StepCounterHomeState createState() => _StepCounterHomeState();
}

class _StepCounterHomeState extends State<StepCounterHome> with SingleTickerProviderStateMixin {
  String _stepCountValue = '0';
  int _totalSteps = 0;
  int _previousTotalSteps = 0;
  int _dailyStepTarget = 10000;
  bool _goalAchieved = false;
  late Stream<StepCount> _stepCountStream;
  late AnimationController _animationController;
  late Animation<double> _footstepsAnimation;
  late Animation<double> _animation;

  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _loadStepData();
    _checkAndResetSteps();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _checkAndResetSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the saved date string
    String? savedDateString = prefs.getString('lastSavedDate');

    if (savedDateString != null && savedDateString.isNotEmpty) {
      try {
        // Parse the saved date string into a DateTime object
        DateTime lastSaveDate = DateTime.parse(savedDateString);

        // Check if the current date is different from the saved date
        if (DateTime.now().day != lastSaveDate.day) {
          // If it's a new day, save the steps from day before and then reset the steps
          await _saveAndResetSteps();
        }
      } catch (e) {
        print("Error parsing date: $e");
        // Handle the error, e.g., reset the steps if the date cannot be parsed.
       await  _saveAndResetSteps();
      }
    } else {
      // If no date is saved, consider saving and resetting the steps.
     await _saveAndResetSteps();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _footstepsAnimation = Tween<double>(
      begin: -100.0,
      end: MediaQuery.of(context).size.width,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _animationController.repeat();
  }

  Future<int> _getCurrentSteps() async {
    // Your logic to get the current steps, for example from a step counter or sensor.
    // Replace with your actual implementation.
    return 0; // Replace with actual step count retrieval logic.
  }

  Future<void> updateStepCount() async {
    // Fetch the current steps from the step counter
    _totalSteps = await _getCurrentSteps();

    // Check if the steps need to be reset (e.g., new day)
    await _checkAndResetSteps();

    // Optionally update the UI with the new step count
  }

  Future<void> initPlatformState() async {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      _onStepCount,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  //Handles the logic for saving to Firestore and resetting steps.
  Future<void> _saveAndResetSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int stepsToday = _totalSteps - _previousTotalSteps;
    stepsToday = stepsToday < 0 ? 0 : stepsToday;

    // retrieve total steps from previous day
    int previousDaySteps = prefs.getInt('previous_day_steps') ?? 0;

    // calculate cumulative steps
    int cumulativeSteps = previousDaySteps + stepsToday;

    // Save cumulative steps to Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'steps': cumulativeSteps,
      'timestamp': DateTime.now(),
      'totalSteps': _totalSteps,
    }, SetOptions(merge: true));

    // save the current day's steps as the previous day's steps
    await prefs.setInt('previous_day_steps', stepsToday);

    // Save the date and total steps to SharedPreferences
    await prefs.setString('lastSavedDate', DateTime.now().toIso8601String());
    await prefs.setInt('previousTotalSteps', _totalSteps);

    // Reset steps in state
    setState(() {
      _previousTotalSteps = _totalSteps;
      _stepCountValue = '0';
      _goalAchieved = false;
    });
  }

  void _onResetButtonPressed() async {
    await _saveAndResetSteps();

    // Optionally show a confirmation dialog or snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Steps have been reset successfully.'),
      ),
    );
  }

  // review
  Future<void> _loadStepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _previousTotalSteps = prefs.getInt('previousTotalSteps') ?? 0;
    _dailyStepTarget = prefs.getInt('dailyStepTarget') ?? 10000;

    setState(() {
      int currentSteps = _totalSteps - _previousTotalSteps;
      _stepCountValue = currentSteps >= 0 ? currentSteps.toString() : '0';
      _checkGoalAchievement();
    });
  }

  // Future<int> _getTotalSteps() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int previousDaySteps = prefs.getInt('previous_day_steps') ?? 0;
  //   int currentSteps = await _getCurrentSteps();
  //   return previousDaySteps + currentSteps;
  // }

  void _onStepCount(StepCount event) async {
    int currentSteps = event.steps - _previousTotalSteps;
    if (currentSteps < 0) {
      // Handle potential anomalies from the pedometer
      _previousTotalSteps = event.steps;
      currentSteps = 0;
    }

    setState(() {
      _totalSteps = event.steps;
      _stepCountValue = currentSteps.toString();
      _checkGoalAchievement();
    });

    await _saveStepData();
    await _saveStepCountToFirestore();
  }

  // Future<void> _saveStepCountToFirestore() async {
  //   String today = DateTime.now().toIso8601String().split('T').first;
  //   int currentSteps = _totalSteps - _previousTotalSteps;
  //
  //   DocumentReference userDoc = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId);
  //
  //   await userDoc.set({
  //     'lastResetDate': today,
  //     'totalSteps': _totalSteps,
  //     'previousTotalSteps': _previousTotalSteps,
  //     'steps': currentSteps,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   }, SetOptions(merge: true));
  //
  //   print('Step count saved to Firestore: $currentSteps');
  // }

  Future<void> _saveStepCountToFirestore({String? lastResetDate}) async {
    String today = DateTime.now().toIso8601String().split('T').first;
    int currentSteps = _totalSteps - _previousTotalSteps;

    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    await userDoc.set({
      'lastResetDate': lastResetDate ?? today,
      'totalSteps': _totalSteps,  // Save the total steps
      'previousTotalSteps': _previousTotalSteps,  // Save previous total steps
      'steps': currentSteps,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('Step count saved to Firestore: $currentSteps');
  }

  void _onError(error) {
    print('Error: $error');
  }

  void _onDone() {
    print('Done with counting steps.');
  }

  Future<void> _saveStepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('previousTotalSteps', _previousTotalSteps);
    await prefs.setInt('totalSteps', _totalSteps);
    await prefs.setInt('dailyStepTarget', _dailyStepTarget);

    print('Step data saved to SharedPreferences:'
        ' Previous Total Steps: $_previousTotalSteps, '
        'Total Steps: $_totalSteps');
  }

  void _resetSteps() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      showCloseIcon: true,
      title: "Reset Steps",
      desc: "Are you sure you want to reset your steps count for the day?",
      btnOkOnPress: () async {
        setState(() {
          _previousTotalSteps = 0;
          _totalSteps = 0;
          _stepCountValue = '0';
          _goalAchieved = false;
          _animationController.reset();
        });

        await _saveStepData();
        await _saveStepCountToFirestore(lastResetDate: DateTime.now().toIso8601String().split('T').first);

        // Forcefully reload step data when coming back from other screens
        await _loadStepData();

        // Recalculate calories burned
        setState(() {
          _getCalorieBurnMessage(0);  // Set to 0 as the steps are reset
        });
      },
      btnCancelOnPress: () {},
    ).show();
  }

  void _updateDailyStepTarget(double newValue) {
    setState(() {
      _dailyStepTarget = newValue.toInt();
    });
  }

  void _saveDailyStepTarget() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      showCloseIcon: true,
      title: "Save Daily Step Target",
      desc: "Are you sure you want to save this target?",
      btnOkOnPress: () async {
        await _saveStepData();
        setState(() {
          _checkGoalAchievement();
        });
      },
      btnCancelOnPress: () {},
    ).show();
  }

  void _checkGoalAchievement() {
    int currentSteps = _totalSteps - _previousTotalSteps;
    if (currentSteps >= _dailyStepTarget && !_goalAchieved) {
      setState(() {
        _goalAchieved = true;
        _animationController.forward();
      });
    }
  }

  String _getCalorieBurnMessage(int steps) {
    // Define the constants for calculation
    const double stepsPerKcal = 6500 / 260; // This means 25 steps = 1 kcal

    // Calculate the calories burned
    int kcal = (steps / stepsPerKcal).round();

    return 'You\'ve burned approximately $kcal kcal';
  }

  void saveStepsFromPreviousDay(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('previous_day_steps', steps);
  }

  Future<int> getStepsFromPreviousDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('previous_day_steps') ?? 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    //_saveAndResetSteps();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1-((_totalSteps - _previousTotalSteps) / _dailyStepTarget);
    progress = progress.clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: TColor.primaryG,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ),

          FootstepsAnimation(), // The GIF is now placed at the top right

          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                const SizedBox(height: 100),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: TColor.secondaryColor2,
                        valueColor: AlwaysStoppedAnimation<Color>(TColor.lightGray),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          '$_stepCountValue',
                          style: const TextStyle(fontSize: 48, color: Colors.white),
                        ),

                        const Text(
                          'Steps Taken',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Text(
                  _getCalorieBurnMessage(_totalSteps - _previousTotalSteps),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Slider(
                  value: _dailyStepTarget.toDouble(),
                  min: 100,
                  max: 30000,
                  divisions: 29000 ~/ 1000,
                  label: _dailyStepTarget.toString(),
                  onChanged: (double newValue) {
                    setState(() {
                      _updateDailyStepTarget(newValue);
                    });
                  },
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _saveDailyStepTarget,
                      child: const Text('Save Target'),
                    ),

                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _onResetButtonPressed,
                      child: const Text('Reset Steps'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_goalAchieved)
            AnimatedOpacity(
              opacity: _animationController.value,
              duration: const Duration(seconds: 1),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Congratulations!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'You\'ve reached your daily goal!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _goalAchieved = false;
                            _animationController.reset();
                          });
                        },
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
