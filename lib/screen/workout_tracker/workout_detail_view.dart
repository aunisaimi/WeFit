import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/exercise_set_section.dart';
import 'package:diet_app/screen/workout_tracker/add_exercise.dart';
import 'package:diet_app/screen/workout_tracker/exercise_step_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/common_widget/icon_title_next_row.dart';

class WorkoutDetailView extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final String? title;
  // final String document;
  final String category;

  const WorkoutDetailView({
    Key? key,
    required this.exercises,
    // required this.document,
    required this.category,
    this.title,
  }) : super(key: key);

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth= FirebaseAuth.instance;

  String _difficulty = "Beginner"; // Default difficulty level
  Set<String> _favourites = {};

  List youArr = [
    {
      "image": "assets/img/fitness.png",
      "title": "Barbell",
    },
    {
      "image": "assets/img/skipping_rope.png",
      "title": "Skipping Rope",
    },
    {
      "image": "assets/img/bottle.png",
      "title": "1 Litre Bottle",
    },
    {
      "image": "assets/img/bubur.jpeg",
      "title": "Bubur",
    },
  ];
  List<String> title = ['full body', 'arms','legs','abs'];

  Map<String, List<String>> durations = {
    "Beginner": [
      "05:00", "12x", "15x", "20x", "25x", "02:00", "00:25", "12x", "00:30", "15x", "02:00"
    ],
    "Intermediate": [
      "06:00", "15x", "18x", "25x", "30x", "02:30", "00:30", "15x", "00:45", "20x", "02:30"
    ],
    "Advanced": [
      "07:00", "18x", "20x", "30x", "35x", "03:00", "00:35", "18x", "01:00", "25x", "03:00"
    ],
  };


  // dummy data for illustration
  final Map<String,dynamic> sObj = {};
  Map<String, List<Map<String, dynamic>>> _groupedExercises = {};

  @override
  void initState() {
    super.initState();
    print("Exercise to be shown: ${widget.exercises}");
    setState(() {
      _difficulty = "Beginner";
    });
    _fetchAndGroupExercisesByTitle();
    _fetchAndGroupExercisesByDifficulty();
  }

  Future<void> _fetchAndGroupExercisesByDifficulty() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('exercises')
          .doc(_difficulty.toLowerCase())
          .collection(widget.category.toLowerCase())
          .get();

      Map<String, List<Map<String, dynamic>>> groupedExercises = {};

      for (var doc in snapshot.docs) {
        var exercise = doc.data() as Map<String, dynamic>;
        String title = exercise['title'] ?? 'Unknown';

        if (groupedExercises.containsKey(title)) {
          groupedExercises[title]!.add(exercise);
        } else {
          groupedExercises[title] = [exercise];
        }
      }

      setState(() {
        _groupedExercises = groupedExercises;
      });

      print('Grouped exercises: $_groupedExercises');
    } catch (e, stackTrace) {
      print("Error fetching exercises: $e");
      print(stackTrace);
    }
  }

  void _onDifficultySelected(String difficulty) {
    setState(() {
      _difficulty = difficulty;
      _fetchAndGroupExercisesByDifficulty();
    });
  }

  Future<void> _fetchAndGroupExercisesByTitle() async {
    try {
      Map<String,List<Map<String,dynamic>>> groupedExercises = {};

      for (var exercise in widget.exercises) {
        print('Processing exercise: $exercise');

        if(exercise.containsKey('title')){
          String title = exercise['title'];
          if (groupedExercises.containsKey(title)) {
            groupedExercises[title]!.add(exercise);
          } else {
            groupedExercises[title] = [exercise];
          }
        } else {
          print('Exercise missing title: $exercise');
        }
      }

      setState(() {
        _groupedExercises = groupedExercises;
      });

      print('Grouped exercises: $_groupedExercises');
    } catch (e,printStack){
      print("Error fetching exercises: $e");
      print(printStack);
    }
  }

  Future<void> _addToHistory(Map<String,dynamic> exercise) async {
    try{
      final User? user = _auth.currentUser;
      if( user != null){
        await _firestore.collection('history').add({
          'userId': user.uid,
          'exercise': exercise,
          'status': 'no',
          'timestamp': FieldValue.serverTimestamp(),
        });
        print("Exercise added to the history: $exercise");
      } else {
        print("No user signed in");
      }
    } catch(e,printStack){
      print("Error adding to firestore history: $e");
      print(printStack);
    }
  }

  void _toggleFavorite(String exerciseTitle){
    setState(() {
      if(_favourites.contains(exerciseTitle)){
        _favourites.remove(exerciseTitle);
      } else {
        _favourites.add(exerciseTitle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: TColor.primaryG),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.transparent,
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
                    child: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
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
            ];
          },
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: TColor.gray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(height: media.width * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.exercises.first["title"].toString(),
                                  //widget.category,
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  _difficulty,
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                                _favourites.contains(widget.exercises.first["title"])
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                                color: _favourites.contains(widget.exercises.first["title"])
                                    ? TColor.secondaryColor1
                                    : TColor.gray
                            ),
                            onPressed: () {
                              _toggleFavorite(widget.exercises.first["title"]);
                            },

                          ),
                        ],
                      ),
                      SizedBox(height: media.width * 0.05),
                      //
                      // Container(
                      //   height: 50,
                      //   padding: const EdgeInsets.all(6),
                      //   decoration: ,
                      // )
                      IconTitleNextRow(
                        icon: "assets/img/difficulty.png",
                        title: "Difficulty",
                        time: _difficulty, // Display selected difficulty
                        color: TColor.secondaryColor2.withOpacity(0.3),
                        onPressed: () {
                          // Show dialog to choose difficulty
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Select Difficulty"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text("Beginner"),
                                      onTap: () {
                                        setState(() {
                                          Navigator.pop(context);
                                          _onDifficultySelected("Beginner");
                                        });
                                      },
                                    ),
                                    ListTile(
                                      title: const Text("Intermediate"),
                                      onTap: () {
                                        setState(() {
                                          Navigator.pop(context);
                                          _onDifficultySelected("Intermediate");
                                        });
                                      },
                                    ),
                                    ListTile(
                                      title: const Text("Advanced"),
                                      onTap: () {
                                        setState(() {
                                          Navigator.pop(context);
                                          _onDifficultySelected("Advanced");
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      //SizedBox(height: media.width * 0.05),
                      SizedBox(height: media.width * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Exercises",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {},
                          //   child: Text(
                          //     "${_groupedExercises.length} Sets",
                          //     style: TextStyle(
                          //       color: TColor.gray,
                          //       fontSize: 12,
                          //     ),
                          //   ),
                          // )
                        ],
                      ),

                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _groupedExercises.keys.length,
                        itemBuilder: (context, index) {
                          String title = _groupedExercises.keys.elementAt(index);
                          List<Map<String, dynamic>> exercises =
                          _groupedExercises[title]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: exercises.length,
                                itemBuilder: (context, exerciseIndex) {
                                  // Debug print to check the length of exercises
                                  print('Length of exercises: ${exercises.length}');

                                  // Check if exerciseIndex is valid
                                  if (exerciseIndex >= 0 &&
                                      exerciseIndex < exercises.length){
                                    // to access sObj
                                    Map<String,dynamic> sObj =  Map<String, dynamic>
                                        .from(exercises[exerciseIndex]);

                                    // Debug print to check the data
                                    print('Exercise object: $sObj');
                                    // Debug print to check the structure of each item in exercises
                                    print('Exercise object at index $exerciseIndex: $sObj');
                                    //print('Exercise name: ${sObj.containsKey('exercise') ? sObj['exercise'] : 'Key not found'}');

                                    // Assign default values if any of the fields are null
                                    String image = sObj["image"] ?? '';
                                    // String duration = sObj["duration"] ?? '';
                                    String exercise = sObj["title"] ?? '';
                                    String document = sObj["name"] ?? '';
                                    String type = sObj["type"] ?? '';
                                    String value = sObj["value"] ?? '';

                                    print('Image: ${sObj.containsKey('image') ? sObj['image'] : 'Key not found'}');
                                    print('Value: ${sObj.containsKey('value') ? sObj['value'] : 'Key not found'}');
                                    print('Exercise: ${sObj.containsKey('title') ? sObj['title'] : 'Key not found'}');
                                    print('Document: ${sObj.containsKey('name') ? sObj['name'] : 'Key not found'}');
                                    print('Type: ${sObj.containsKey('type') ? sObj['type'] : 'Key not found'}');

                                    // Debug print to check the exercise name
                                    print('Exercise name: $document');

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: ExercisesSetSection(
                                            sObj: sObj,
                                            onPressed: (sObj) {
                                              if (exercise.isNotEmpty) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ExercisesStepDetails(
                                                      eObj: sObj,
                                                      image: image,
                                                      //duration: duration,
                                                      difficulty: _difficulty,
                                                      document: document,
                                                      exerciseName: exercise,
                                                      steps: '',
                                                      type: type,
                                                      value: value,
                                                      historyId: '',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                print("Exercise name is empty or exercise object: $sObj");
                                              }
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_forward),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ExercisesStepDetails(
                                                  eObj: sObj,
                                                  image: image,
                                                  //duration: duration,
                                                  exerciseName: exercise,
                                                  difficulty: _difficulty,
                                                  document: document,
                                                  steps: '',
                                                  value: value,
                                                  type: type,
                                                  historyId: '',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  } else {
                                    print('Invalid exercise index: $exerciseIndex');
                                    return const SizedBox();
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: media.width * 0.1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}