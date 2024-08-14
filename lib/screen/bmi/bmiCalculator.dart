
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/round_textfield.dart';
import 'package:diet_app/database/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BMICalculator extends StatefulWidget {

  const BMICalculator({Key? key}) : super(key: key);

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();

  late double? bmi = 0;

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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _heightCtrl.text = userDoc.data()!['height'].toString();
          _weightCtrl.text = userDoc.data()!['weight'].toString();

          // Validate the height and weight before parsing
          if (_isValidNumber(_heightCtrl.text) && _isValidNumber(_weightCtrl.text)) {
            double height = double.parse(_heightCtrl.text);
            double weight = double.parse(_weightCtrl.text);

            bmi = calculateBMI(height, weight);

            // Update BMI on Firestore
            updateBMIOnFirestore(bmi!);
          } else {
            print("Invalid height or weight data");
          }
        });

        print("Height: ${userDoc['height']}");
        print("Weight: ${userDoc['weight']}");
        print("Calculated BMI: $bmi");
      } else {
        print('User document does not exist');
      }
    } catch (e, stackTrace) {
      print('Error fetching user data: $e');
      print(stackTrace);
    }
  }


  double calculateBMI(double height, double weight) {
    return weight / (height * height) * 10000;
  }

  bool _isValidNumber(String value) {
    return double.tryParse(value) != null;
  }

  void updateBMI() {
    if (_heightCtrl.text.isNotEmpty && _weightCtrl.text.isNotEmpty) {
      if (_isValidNumber(_heightCtrl.text) && _isValidNumber(_weightCtrl.text)) {
        double height = double.parse(_heightCtrl.text);
        double weight = double.parse(_weightCtrl.text);

        setState(() {
          bmi = calculateBMI(height, weight);
        });
      } else {
        print("Invalid height or weight input");
      }
    }
  }

  double calculateBMIPercentage(double bmi){
    const double minNormalBMI = 18.5;
    const double maxNormalBMI  = 24.9;

    if (bmi < minNormalBMI){
      return 0.0;
    } else if (bmi > maxNormalBMI){
      return 100.0;
    } else {
      return ((bmi - minNormalBMI) / (maxNormalBMI - minNormalBMI)) * 100;
    }
  }

  void saveDataToSharedPreferences(double bmiPercentage, String bmiMessage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bmiPercentage', bmiPercentage);
    await prefs.setString('bmiMessage', bmiMessage);
  }

  void updateBMIOnFirestore(double bmi) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Check if the 'bmi' field exists in the document
        if (userDoc.data()!.containsKey('bmi')) {
          // If the field exists, update its value
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'bmi': bmi});
        } else {
          // If the field doesn't exist, create it and set its value
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set({'bmi': bmi}, SetOptions(merge: true));
        }
        print('BMI updated on Firestore successfully');
      } else {
        print('User document does not exist');
      }
    } catch (e, stackTrace) {
      print('Error updating BMI on Firestore: $e');
      print(stackTrace);
    }
  }




  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi >= 18.5 && bmi < 25) {
      return Colors.green;
    } else if (bmi >= 25 && bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
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
                    Navigator.pop(context, {
                      'bmi': bmi!,
                      'bmiMessage': _getBMIMessage(bmi!),
                    });
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
                    child: const Icon(Icons.arrow_back_ios_rounded),
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
                    "assets/img/bmi.png",
                    width: media.width * 0.95,
                    height: media.width * 0.85,
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
                topRight: Radius.circular(25),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TColor.gray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  TextField(
                    controller: _heightCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Height (m)'),
                    readOnly: true,
                  ),
                  SizedBox(height: media.width * 0.05),
                  TextField(
                    controller: _weightCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Weight (kg)'),
                    readOnly: true,
                  ),
                  SizedBox(height: media.width * 0.05),
                  if (bmi != null)
                    Text(
                      'Your BMI: ${double.parse(bmi!.toStringAsFixed(2))}',
                      style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  SizedBox(height: media.width * 0.05),
                  if(bmi != null) ...[
                    Text(
                      _getBMIMessage(bmi!),
                      style: TextStyle(
                        color: _getBMIColor(bmi!),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'BMI not available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  SizedBox(height: media.width * 0.05),
                  Text(
                    'BMI Percentage: ${double.parse(calculateBMIPercentage(bmi ?? 0).toStringAsFixed(2))}%',
                    style: TextStyle(
                      color: TColor.secondaryColor1,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (bmi == null)
                    const Text(
                      'BMI not available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: media.width * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'bmiPercentage': calculateBMIPercentage(bmi ?? 0),
                        'bmiMessage': _getBMIMessage(bmi ?? 0),
                      });
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

