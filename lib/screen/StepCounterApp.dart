import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterHome extends StatefulWidget {
  @override
  _StepCounterHomeState createState() => _StepCounterHomeState();
}

class _StepCounterHomeState extends State<StepCounterHome> with SingleTickerProviderStateMixin {
  String _stepCountValue = '0';
  int _totalSteps = 0;
  int _previousTotalSteps = 0;
  int _dailyStepTarget = 10000; // Default daily step target
  bool _goalAchieved = false; // Track if the goal is achieved
  late Stream<StepCount> _stepCountStream;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _loadStepData();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
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

  Future<void> _loadStepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousTotalSteps = prefs.getInt('previousTotalSteps') ?? 0;
      _totalSteps = prefs.getInt('totalSteps') ?? 0;
      _dailyStepTarget = prefs.getInt('dailyStepTarget') ?? 10000; // Load daily step target
      _stepCountValue = (_totalSteps - _previousTotalSteps).toString();
      _checkGoalAchievement();
    });
  }

  Future<void> _saveStepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('previousTotalSteps', _previousTotalSteps);
    await prefs.setInt('totalSteps', _totalSteps);
    await prefs.setInt('dailyStepTarget', _dailyStepTarget); // Save daily step target
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _totalSteps = event.steps;
      int currentSteps = _totalSteps - _previousTotalSteps;
      _stepCountValue = currentSteps.toString();
      _saveStepData();
      _checkGoalAchievement();
    });
  }

  void _onError(error) {
    print('Error: $error');
  }

  void _onDone() {
    print('Done with counting steps.');
  }

  void _resetSteps() {
    setState(() {
      _previousTotalSteps = _totalSteps;
      _stepCountValue = '0';
      _goalAchieved = false;
      _animationController.reset();
      _saveStepData();
    });
  }

  void _updateDailyStepTarget(double newValue) {
    setState(() {
      _dailyStepTarget = newValue.toInt();
    });
  }

  void _saveDailyStepTarget() {
    _saveStepData();
    _checkGoalAchievement();
  }

  void _checkGoalAchievement() {
    if (_totalSteps - _previousTotalSteps >= _dailyStepTarget && !_goalAchieved) {
      _goalAchieved = true;
      _animationController.forward();
    }
  }

  String _getCalorieBurnMessage(int steps) {
    int kcal = (steps / 6500 * 260).round();
    return 'you\'ve burned approx. $kcal kcal,'
        ' which is equivalent to ${kcal ~/ 260} plate(s) of rice';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                const Text(
                  'Steps taken:',
                  style: TextStyle(fontSize: 24),
                ),

                Text(
                  '$_stepCountValue',
                  style: const TextStyle(fontSize: 48),
                ),

                const SizedBox(height: 20),

                Text(
                  _getCalorieBurnMessage(_totalSteps - _previousTotalSteps),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                Slider(
                  value: _dailyStepTarget.toDouble(),
                  min: 100,
                  max: 50000,
                  divisions: 49,
                  label: _dailyStepTarget.toString(),
                  onChanged: _updateDailyStepTarget,
                ),

                ElevatedButton(
                  onPressed: _saveDailyStepTarget,
                  child: const Text('Save Target'),
                ),

                ElevatedButton(
                  onPressed: _resetSteps,
                  child: const Text('Reset Steps'),
                ),

              ],
            ),
          ),

          if (_goalAchieved)
            AnimatedOpacity(
              opacity: _animation.value,
              duration: const Duration(seconds: 1),
              child: Center(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
