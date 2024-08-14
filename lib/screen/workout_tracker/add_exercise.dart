import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../common/RoundButton.dart';

class AddExercise extends StatefulWidget {
  const AddExercise({super.key});

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final TextEditingController _exerciseNameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _valueCtrl = TextEditingController();
  String _difficulty = 'beginner'; // default
  String _type = 'frequency';
  String _title = 'full body'; // Default
  Uint8List? _image;
  final imagePicker = ImagePicker();
  final List<String> _types = ['frequency', 'duration'];
  final List<String> _titles = ['full body', 'arms', 'legs', 'abs'];
  final List<String> _difficulties = ['beginner', 'intermediate', 'advanced'];

  Future<void> _pickImage() async {
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _image = imageBytes;
      });
    }
  }

  Future<String> _uploadImage(String exerciseName) async {
    final storageRef = FirebaseStorage.instance.ref().child('workouts/$exerciseName.jpg');
    final uploadTask = storageRef.putData(_image!);
    final snapshot = await uploadTask;
    final imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  void _saveExercise() async {
    try {
      final exerciseName = _exerciseNameCtrl.text.trim();
      String? imageUrl;

      if (_image != null) {
        imageUrl = await _uploadImage(exerciseName);
      }

      final exerciseData = {
        'value': _valueCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'duration': _durationCtrl.text.trim(),
        'image': imageUrl,
        'type': _type,
        'title': _title,
      };

      await FirebaseFirestore.instance
          .collection('workouts')  // Changed collection name to 'workouts'
          .doc(_difficulty)
          .collection('exerciseList')
          .doc(exerciseName)
          .set(exerciseData);

      ScaffoldMessenger.of(context)
          .showSnackBar(
          const SnackBar(
              content: Text('Exercise added successfully')
          )
      );

      print('Exercise added');

      Navigator.pop(context);
    } catch (e, printStack) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
          const SnackBar(
              content: Text('Exercise failed to be added into Firestore!')
          )
      );
      print('Error adding exercise: $e');
      print(printStack);
    }
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
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                    ),
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
                    "assets/img/complete_profile.png",
                    width: media.width * 0.75,
                    height: media.width * 0.8,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ];
          },
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25)
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
                                Center(
                                  child: Text(
                                    "Add Exercise",
                                    style: TextStyle(
                                        color: TColor.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),

                                SizedBox(height: media.width * 0.05),

                                RoundTextField(
                                  controller: _exerciseNameCtrl,
                                  hitText: "Exercise",
                                  icon: "assets/img/choose_workout.png",
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                ),

                                SizedBox(height: media.width * 0.05),

                                RoundTextField(
                                  controller: _descriptionCtrl,
                                  hitText: "Description",
                                  icon: "assets/img/menu_tips.png",
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                ),

                                SizedBox(height: media.width * 0.05),

                                RoundTextField(
                                  controller: _durationCtrl,
                                  hitText: "Duration",
                                  icon: "assets/img/activity_tab.png",
                                  keyboardType: TextInputType.number,
                                  obscureText: false,
                                ),

                                SizedBox(height: media.width * 0.05),

                                RoundTextField(
                                  controller: _valueCtrl,
                                  hitText: "Value",
                                  icon: "assets/img/p_workout.png",
                                  keyboardType: TextInputType.number,
                                  obscureText: false,
                                ),

                                SizedBox(height: media.width * 0.05),

                                DropdownButtonFormField(
                                  value: _title,
                                  items: _titles.map((String title) {
                                    return DropdownMenuItem(
                                      value: title,
                                      child: Text(title),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _title = value as String;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    labelText: 'Title',
                                  ),
                                ),

                                SizedBox(height: media.width * 0.05),

                                DropdownButtonFormField(
                                  value: _type,
                                  items: _types.map((String type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _type = value as String;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    labelText: 'Type',
                                  ),
                                ),

                                SizedBox(height: media.width * 0.05),

                                DropdownButtonFormField(
                                  value: _difficulty,
                                  items: _difficulties.map((String difficulty) {
                                    return DropdownMenuItem(
                                      value: difficulty,
                                      child: Text(difficulty),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _difficulty = value as String;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    labelText: 'Difficulty',
                                  ),
                                ),

                                SizedBox(height: media.width * 0.05),

                                ElevatedButton(
                                  onPressed: _pickImage,
                                  child: Text('Pick Image'),
                                ),

                                SizedBox(height: media.width * 0.05),

                                RoundButton(
                                  title: "Save Exercise",
                                  onPressed: () => _saveExercise(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
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
