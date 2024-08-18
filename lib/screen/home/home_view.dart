import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/Helpers/preferences_helper.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/screen/bmi/bmiCalculator.dart';
import 'package:diet_app/screen/meal_planner/dietandfitness/meal_plan_view.dart';
import 'package:diet_app/screen/on_boarding/started_view.dart';
import 'package:diet_app/screen/water_intake/water_intake.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../../database/auth_service.dart';


class HomeView extends StatefulWidget {
  final int remainingCalories;
  late bool logGoogle = false;

  HomeView({Key? key, required this.remainingCalories}) : super(key : key);

  HomeView.loginWithGoogle(logGoogle, this.remainingCalories){
    this.logGoogle = logGoogle;
  }

  final User? user = FirebaseAuth.instance.currentUser;


  @override
  State<HomeView> createState() => _HomeViewState(logGoogle);
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final String? userId = FirebaseAuth.instance.currentUser?.uid;
  AuthService authService = AuthService();
  Future<DocumentSnapshot<Map<String, dynamic>>>? userDataFuture;

  TextEditingController txtDate = TextEditingController();
  TextEditingController txtWeight = TextEditingController();
  TextEditingController txtHeight = TextEditingController();
  TextEditingController initialCalories = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  // steps reading
  int _totalSteps = 0;
  String _stepCountValue = '0';

  // bmi reading
  double? bmi = 0;
  double? bmiPercentage;
  String? bmiMessage;
  bool isLoading = true;
  String bmiStatus = "";

  // water intake
  double currentIntake = 0;
  final double targetIntake = 4000; // target in ml
  List <Map<String,String>>waterArr = [];
  String formattedDate = '';

  // calories counter
  int _remainingCalories = 2500;
  late ValueNotifier<double> _progressNotifier = ValueNotifier(0);

  bool logGoogle;
  _HomeViewState(this.logGoogle);

  Map<String, Map<String, dynamic>> selectedMeals = {
    "Breakfast": {},
    "Lunch": {},
    "Snack": {},
    "Dinner": {},
  };

  int get _totalCalories {
    int total = 0;
    selectedMeals.forEach((key, meal) {
      if (meal.isNotEmpty) {
        total += meal["calories"] as int;
      }
    });
    return total;
  }

  @override
  void initState() {
    super.initState();
    print('${_emailController}');
    print('${_firstnameController}');
    print('${_lastnameController}');
    fetchUserData().then((_){
      _loadRemainingCalories();
      fetchLatestWorkout();
    });
    _remainingCalories = widget.remainingCalories;
    _progressNotifier = ValueNotifier(_calculateProgress(widget.remainingCalories));
    _loadData();
   // updateIntake();
    fetchIntake();
    fetchRemainingCalories();
    _loadSavedSteps();
  }

  Future<void> _loadSavedSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSteps = prefs.getInt('totalSteps') ?? 0;
      int previousTotalSteps = prefs.getInt('previousTotalSteps') ?? 0;
      _stepCountValue = (_totalSteps - previousTotalSteps).toString();
    });
  }

  Future<void> _loadRemainingCalories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastUpdateDate = prefs.getString('lastUpdateDate');
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastUpdateDate == null || lastUpdateDate != currentDate) {
      // Reset remaining calories if date has changed
      await _updateRemainingCalories(widget.remainingCalories);
      await prefs.setString('lastUpdateDate', currentDate);
    } else {
      setState(() {
        _remainingCalories = prefs.getInt('remainingCalories') ?? widget.remainingCalories;
        _progressNotifier.value = _calculateProgress(_remainingCalories);
      });
    }
  }

  Future<void> fetchRemainingCalories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      int initialCalories = (userDoc.get('initialCalories') as num).toInt();

      setState(() {
        _remainingCalories = initialCalories;
        _progressNotifier.value = _calculateProgress(_remainingCalories!);
        isLoading = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastUpdateDate = prefs.getString('lastUpdateDate');
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (lastUpdateDate == null || lastUpdateDate != currentDate) {
        await _updateRemainingCalories(_remainingCalories!);
        await prefs.setString('lastUpdateDate', currentDate);
      } else {
        setState(() {
          _remainingCalories = prefs.getInt('remainingCalories') ?? _remainingCalories!;
          _progressNotifier.value = _calculateProgress(_remainingCalories!);
        });
      }
    }
  }

  Future<void> _updateRemainingCalories(int updatedCalories) async {
    setState(() {
      _remainingCalories = updatedCalories;
      _progressNotifier.value = _calculateProgress(_remainingCalories);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remainingCalories', _remainingCalories);
  }

  double _calculateProgress(int remainingCalories) {
    const int dailyCalorieGoal = 2500; // default daily goal is 2500kcal
    double progress = (remainingCalories / dailyCalorieGoal) * 100;

    // Debugging print
    print("Progress calculation: $remainingCalories / $dailyCalorieGoal = $progress");

    return progress;
  }

  // Define a list of images or widgets for the carousel
  final List<String> imgList =[
    'assets/img/1.png',
    'assets/img/2.png',
    'assets/img/3.png',
  ];

  Future<void> _loadData() async{
    var meals = await PreferencesHelper.loadSelectedMeals();
    setState(() {
      selectedMeals = meals;
    });
  }

  Future<void> fetchUserData() async {
    try {
      // Get the current user's ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the user's document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Extract and set user data to the respective TextEditingController
        setState(() {
          _emailController.text = userDoc['email'];
          _firstnameController.text = userDoc['fname'];
          _lastnameController.text = userDoc['lname'];
          _genderController.text = userDoc['gender'];
          bmi = userDoc['bmi'];
          bmiPercentage = calculateBMIPercentage(bmi!);
          bmiStatus = determineBMIStatus(bmi!);
          initialCalories = userDoc['initialCalories'];
          _remainingCalories = userDoc['initialCalories'] ?? widget.remainingCalories;
          _progressNotifier.value = _calculateProgress(_remainingCalories);
        });
        print("This is the current user email: ${userDoc['email']}");
        print("This is the current user name: ${userDoc['fname']}");
        print("This is the current user lname: ${userDoc['lname']}");
        print("This is the current user gender: ${userDoc['gender']}");
        print("This is the current user bmi: ${userDoc['bmi']}");
        print("This is the current calorie: ${userDoc['initialCalories']}");

      } else {
        print("Data not exist");
      }
    } catch (e) {
      print("Error, please check: ${e}");
    }
  }
  
  double calculateBMIPercentage(double bmi){
    const double minNormalBMI = 18.5;
    const double maxNormalBMI  = 24.9;

    if (bmi < minNormalBMI){
      return ((bmi / minNormalBMI) * 100).clamp(0.0, 100.0);
    } else if (bmi > maxNormalBMI){
      return ((bmi / maxNormalBMI) * 100).clamp(0.0, 100.0);
    } else {
      return ((bmi - minNormalBMI) / (maxNormalBMI - minNormalBMI)) * 100;
    }
  }

  String determineBMIStatus(double bmi) {
    if (bmi < 18.5) {
      return "You are underweight";
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      return "You have a normal weight";
    } else {
      return "You are overweight";
    }
  }

  String _getBMIMessage(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  Future<void> fetchLatestWorkout() async {
    try {
      var userId = widget.user?.uid;
      if(userId != null){
        var snapshot = await FirebaseFirestore.instance
            .collection('history')
            .where('userId',isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if(snapshot.docs.isNotEmpty){
          setState(() {
            lastWorkoutArr = snapshot.docs.map((doc) => doc.data()).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e,printStack){
      print('Error fetching latest workout: $e');
      print(printStack);
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateIntake(double intake){
    setState(() {
      currentIntake += intake;
      waterArr.add({
        "title": "${DateTime.now().hour}:${DateTime.now().minute}",
        "subtitle": "${intake.toStringAsFixed(0)} ml",
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now())
      });
    });
    saveIntakeToFirestore(intake);
  }

  Future<void> fetchIntake() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('intake')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('timestamp', isGreaterThanOrEqualTo: DateTime.now().subtract(
          Duration(
              hours: DateTime.now().hour,
              minutes: DateTime.now().minute,
              seconds: DateTime.now().second)))
          .get();

      print('Query executed. Document count: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('No documents found for the current user.');
      } else {
        print('Fetched documents: ${snapshot.docs.length}');
      }

      final intakeData = snapshot.docs.map((doc) {
        final timestamp = doc['timestamp'].toDate();
        final date = DateFormat('d MMMM yyyy').format(timestamp); // Format the date
        print('Document data: ${doc.data()}');
        return {
          "title": "${doc['timestamp'].toDate().hour}:${doc['timestamp'].toDate().minute}",
          "subtitle": "${doc['intake'].toStringAsFixed(0)} ml",
          "date": date,
        };
      }).toList();

      setState(() {
        waterArr = intakeData;
        currentIntake = intakeData.fold(
            0, (sum, item) => sum + double.parse(item["subtitle"]!
            .split(" ")[0]));
        formattedDate = intakeData.isNotEmpty
            ? intakeData[0]["date"]! : ''; // Update the formatted date
        print('Updated currentIntake: $currentIntake');
      });
    } catch (printStack,e) {
      print('Error fetching data: $e and $printStack');
    }
  }

  Future<void> saveIntakeToFirestore(double intake) async {
    final now = DateTime.now();
    final intakeEntry = {
      'intake': intake,
      'timestamp': now,
      'date': now.toIso8601String().split('T').first,
      'userId': FirebaseAuth.instance.currentUser?.uid //userId,
    };

    await FirebaseFirestore.instance.collection('intake').add(intakeEntry);
    fetchIntake();
  }

  String _getCalorieBurnMessage(int steps) {
    int kcal = (steps / 6500 * 260).round(); // 6.5k steps ~ 260 kcal
    return 'You\'ve burned approx. $kcal kcal, which is equivalent to ${kcal ~/ 260} plate(s) of rice.';
  }

  @override
  void dispose(){
    super.dispose();
    _progressNotifier.dispose();
  }

  void logout(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              TextButton(
                  child: const Text('Yes'),
                  onPressed: (){
                    final _auth = AuthService();
                    _auth.signOut();
                    Navigator.of(context)
                        .pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const StartedView())
                    );
                  },
              )
            ],
          );
        });
  }

  List lastWorkoutArr = [
    {
      "name": "Full Body Workout",
      "image": "assets/img/workout_2.jpg",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },
    {
      "name": "Lower Body Workout",
      "image": "assets/img/leg_extension.jpg",
      "kcal": "200",
      "time": "30",
      "progress": 0.4
    },
    {
      "name": "Ab Workout",
      "image": "assets/img/situp.jpg",
      "kcal": "300",
      "time": "40",
      "progress": 0.7
    },
  ];
  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
    FlSpot(0, 20),
    FlSpot(1, 25),
    FlSpot(2, 40),
    FlSpot(3, 50),
    FlSpot(4, 35),
    FlSpot(5, 40),
    FlSpot(6, 30),
    FlSpot(7, 20),
    FlSpot(8, 25),
    FlSpot(9, 40),
    FlSpot(10, 50),
    FlSpot(11, 35),
    FlSpot(12, 50),
    FlSpot(13, 60),
    FlSpot(14, 40),
    FlSpot(15, 50),
    FlSpot(16, 20),
    FlSpot(17, 25),
    FlSpot(18, 40),
    FlSpot(19, 50),
    FlSpot(20, 35),
    FlSpot(21, 80),
    FlSpot(22, 30),
    FlSpot(23, 20),
    FlSpot(24, 25),
    FlSpot(25, 40),
    FlSpot(26, 50),
    FlSpot(27, 35),
    FlSpot(28, 50),
    FlSpot(29, 60),
    FlSpot(30, 40)
  ];

  List ads = [
    {
      "image": "assets/img/drink.png",
      "subtitle":
      "Drink a lot of water"
    },
    {
      "image": "assets/img/do_yoga.png",
      "subtitle":
      "Remember to meditate "
    },
    {
      "image": "assets/img/keep_walking.png",
      "subtitle":
      "Do exercises even at minimal"
    },
    {
      "image": "assets/img/rest_well.png",
      "subtitle":
      "Exercise excessively is not good.\nTake a rest."
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    double intakePercentage = (currentIntake / targetIntake).clamp( 0.0, 1.0);
    print('Intake Percentage: $intakePercentage');

    print("Building HomeView with remaining calories: $_remainingCalories");
    print("Building HomeView with taken water intake: $currentIntake");

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2.withOpacity(0.4),
            TColor.primaryColor1.withOpacity(0.1),
          ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: TColor.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12),
                        ),
                        Text(
                          "${_firstnameController.text} ${_lastnameController.text}",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        logout(context);
                      },
                      icon: const Icon(
                        Icons.exit_to_app_rounded,
                        size: 25,),
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05,),

                //BMI display
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.075)),
                  child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          "assets/img/bg_dots.png",
                          height: media.width * 0.4,
                          width: double.maxFinite,
                          fit: BoxFit.fitHeight,
                        ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BMI : ${double.parse(bmi!.toStringAsFixed(2))}",
                                style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'BMI Message:${_getBMIMessage(bmi!)} ',
                                style: TextStyle(
                                    color: TColor.white.withOpacity(0.7),
                                    fontSize: 12),
                              ),

                              SizedBox(height: media.width * 0.05),

                              SizedBox(
                                  width: 120,
                                  height: 35,
                                  child: RoundButton(
                                      title: "View More",
                                      type: RoundButtonType.bgSGradient,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      onPressed: ()  async {
                                        //final result = await
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const BMICalculator()
                                            )
                                        );
                                      }))
                            ],
                          ),

                          const SizedBox(height: 10),

                          AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event,
                                      pieTouchResponse) {},
                                ),
                                startDegreeOffset: 270,
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 1,
                                centerSpaceRadius:  15,
                                sections: showingSections(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),

                SizedBox(height: media.width * 0.05),

                SizedBox(height: media.width * 0.05),

                // ads
                CarouselSlider(
                    items: ads.map((item) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: TColor.secondaryG,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(vertical: media.width * 0.05,horizontal: 10),
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Column(
                          children: [
                            Image.asset(
                              item['image'].toString(),
                              width: media.width * 0.5,
                              fit: BoxFit.fitWidth,
                            ),

                            SizedBox(height: media.width * 0.05),

                            Text(
                              item['subtitle'].toString(),
                              style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.7,
                      aspectRatio: 16/9,
                      initialPage: 0,
                      height: 200,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    )),

                SizedBox(height: media.width * 0.05),

                Text(
                  "Activity Status",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),

                SizedBox(height: media.width * 0.02),

                SizedBox(height: media.width * 0.05),

                // water intake
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10)
                            ]),
                        child: Row(
                          children: [
                            SimpleAnimationProgressBar(
                              height: media.width * 0.85,
                              width: media.width * 0.07,
                              backgroundColor: Colors.grey.shade100,
                              foregrondColor: Colors.purple,
                              ratio: intakePercentage,
                              direction: Axis.vertical,
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: const Duration(seconds: 3),
                              borderRadius: BorderRadius.circular(15),
                              gradientColor: LinearGradient(
                                  colors: TColor.primaryG,
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Water Intake",
                                      style: TextStyle(
                                          color: TColor.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                            .createShader(
                                            Rect.fromLTRB(
                                                0, 0, bounds.width, bounds.height));
                                      },
                                      child: Text(
                                       "${(currentIntake / 1000).toStringAsFixed(1)} Liters",
                                        // "4 Liters",
                                        style: TextStyle(
                                            color: TColor.white.withOpacity(0.7),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Real time updates",
                                      style: TextStyle(
                                        color: TColor.gray,
                                        fontSize: 12,
                                      ),
                                    ),

                                    SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: waterArr.map((wObj) {
                                          var isLast = wObj == waterArr.last;
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin:
                                                    const EdgeInsets.symmetric(vertical: 2),
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: TColor.secondaryColor1.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                  ),
                                                  if (!isLast)
                                                    DottedDashedLine(
                                                        height: media.width * 0.078,
                                                        width: 0,
                                                        dashColor: TColor
                                                            .secondaryColor1
                                                            .withOpacity(0.5),
                                                        axis: Axis.vertical)
                                                ],
                                              ),

                                              const SizedBox(width: 10),

                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    wObj["title"].toString(),
                                                    style: TextStyle(
                                                      color: TColor.gray,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  ShaderMask(
                                                    blendMode: BlendMode.srcIn,
                                                    shaderCallback: (bounds) {
                                                      return LinearGradient(
                                                          colors: TColor.secondaryG,
                                                          begin: Alignment.centerLeft,
                                                          end: Alignment.centerRight)
                                                          .createShader(
                                                          Rect.fromLTRB(
                                                              0,
                                                              0,
                                                              bounds.width,
                                                              bounds.height));
                                                    },
                                                    child: Text(
                                                      wObj["subtitle"].toString(),
                                                      style: TextStyle(
                                                        color: TColor.white.withOpacity(0.7),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: media.width * 0.05),

                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Container(
                              width: double.maxFinite,
                              height: media.width * 0.7,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 25, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 2)
                                  ]),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Steps taken today",
                                      style: TextStyle(
                                          color: TColor.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight
                                        ).createShader(
                                            Rect.fromLTRB(
                                                0, 0, bounds.width, bounds.height));
                                      },
                                      // child: Text(
                                      //   "Steps today: ",
                                      //   style: TextStyle(
                                      //       color: TColor.white,
                                      //       fontWeight: FontWeight.w700,
                                      //       fontSize: 12
                                      //   ),
                                      // ),
                                    ),
                                    const SizedBox(height: 19),
                                    Container(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: media.width * 0.2,
                                        height: media.width * 0.2,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: media.width * 0.18,
                                              height: media.width * 0.18,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: TColor.primaryG),
                                                borderRadius: BorderRadius.circular(media.width * 0.075),
                                              ),
                                              child: FittedBox(
                                                child: Text(
                                                  "$_totalSteps steps",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: TColor.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SimpleCircularProgressBar(
                                              progressStrokeWidth: 10,
                                              backStrokeWidth: 10,
                                              progressColors: [TColor.secondaryColor2, TColor.secondaryColor1],
                                              backColor: Colors.grey.shade100,
                                              valueNotifier: _progressNotifier,
                                              startAngle: -180,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      _getCalorieBurnMessage(_totalSteps),
                                      style: TextStyle(
                                        color: TColor.black,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.snowshoeing_sharp)
                                  ]),
                            ),

                            SizedBox(height: media.width * 0.05),

                            Container(
                              width: double.maxFinite,
                              height: media.width * 0.5,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 25, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 2)
                                  ]),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Calories",
                                      style: TextStyle(
                                          color: TColor.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                            .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                      },
                                      child: Text(
                                        "${_remainingCalories ?? 0} kCal",
                                        style: TextStyle(
                                            color: TColor.white, //.withOpacity(0.7),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: media.width * 0.2,
                                        height: media.width * 0.2,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: media.width * 0.15,
                                              height: media.width * 0.15,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: TColor.primaryG),
                                                borderRadius: BorderRadius.circular(media.width * 0.075),
                                              ),
                                              child: FittedBox(
                                                child: Text(
                                                  "${_remainingCalories ?? 0} kCal\nleft",
                                                  //"$_remainingCalories kCal\nleft",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: TColor.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SimpleCircularProgressBar(
                                              progressStrokeWidth: 10,
                                              backStrokeWidth: 10,
                                              progressColors: [TColor.secondaryColor2, TColor.secondaryColor1],
                                              backColor: Colors.grey.shade100,
                                              valueNotifier: _progressNotifier,
                                              startAngle: -180,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ],
                        )
                    )
                  ],
                ),

                SizedBox(height: media.width * 0.1,),
                SizedBox(height: media.width * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      2, (i) {
        final double value = bmiPercentage ?? 0;
        final double percentage = bmiPercentage ?? 0.0;
        final Color color = TColor.secondaryColor2;
        var color0 = LinearGradient(colors: TColor.primaryG);

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color,
                value: value,
                title:'${percentage.toStringAsFixed(2)}',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white
                ),
            );
          case 1:
            return PieChartSectionData(
              color: Colors.white,
              value: 100 - value,//100 - value,
              title: '',
              radius: 45,
              titlePositionPercentageOffset: 0.55,
            );

          default:
            throw Error();
        }
      },
    );
  }
}