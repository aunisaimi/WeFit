import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/model/meal.dart';
import 'package:diet_app/screen/meal_planner/dietandfitness/MealDetailScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({Key? key, required dietType}) : super(key: key);

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  List<Map<String, String>> dietTypes = [];
  String selectedDietId = '';
  String selectedDietName = '';
  List<Meal> meals = [];
  String selectedCategory = 'breakfast';

  @override
  void initState() {
    super.initState();
    _fetchDietTypes();
    _loadSelectedDiet(); // Load previously selected diet from local storage
  }

  Future<void> _loadSelectedDiet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDietId = prefs.getString('selectedDietId');
    String? savedDietName = prefs.getString('selectedDietName');

    if (savedDietId != null && savedDietName != null) {
      setState(() {
        selectedDietId = savedDietId;
        selectedDietName = savedDietName;
      });

      // Fetch meals for the loaded selected diet
      _fetchMeals(selectedDietId, selectedCategory);
    }
  }

  Future<void> _saveSelectedDiet(String dietId, String dietName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDietId', dietId);
    await prefs.setString('selectedDietName', dietName);
  }

  Future<void> _updateSelectedDietInFirestore(String dietId, String dietName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'selectedDietId': dietId,
        'selectedDietName': dietName,
      });
    } catch (e, stackTrace) {
      print('Error updating selected diet in Firestore: $e');
      print(stackTrace);
    }
  }

  Future<void> _fetchDietTypes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('diets')
          .get();
      setState(() {
        dietTypes = snapshot.docs.map((doc) => {
          'dietId': doc.id,
          'name': doc['dietType'] as String,
        }).toList();

        if (dietTypes.isNotEmpty) {
          if (selectedDietId.isEmpty) {
            // Set initial selected diet to the first one from Firestore
            selectedDietId = dietTypes.first['dietId']!;
            selectedDietName = dietTypes.first['name']!;
            _saveSelectedDiet(selectedDietId, selectedDietName);
          }
          _fetchMeals(selectedDietId, selectedCategory);
        }
      });

      print('Diet types fetched: $dietTypes');
    } catch (e, stackTrace) {
      print('Error fetching diet types: $e');
      print(stackTrace);
    }
  }

  Future<void> _fetchMeals(String dietId, String category) async {
    try {
      print('Fetching meals for dietId: $dietId, category: $category');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('meals')
          .where('dietId', isEqualTo: dietId)
          .where('category', isEqualTo: category)
          .get();

      setState(() {
        meals = snapshot.docs
            .where((doc) => doc['category'] != null) // Filter out null 'category' values
            .map((doc) => Meal.fromFirestore(doc))
            .toList();
      });

      print('Meals fetched: $meals');
    } catch (e, printStack) {
      print('Error fetching meals: $e');
      print(printStack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet Planner"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [TColor.secondaryColor1, TColor.secondaryColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedDietName,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDietId =
                      dietTypes.firstWhere((diet) => diet['name'] == newValue)['dietId']!;
                      selectedDietName = newValue!;
                    });

                    _saveSelectedDiet(selectedDietId, selectedDietName); // Save locally

                    _updateSelectedDietInFirestore(selectedDietId, selectedDietName); // Save in Firestore

                    _fetchMeals(selectedDietId, selectedCategory); // Fetch meals for the selected diet
                  },
                  items: dietTypes
                      .map<DropdownMenuItem<String>>(
                        (diet) => DropdownMenuItem<String>(
                      value: diet['name'],
                      child: Text(diet['name']!),
                    ),
                  )
                      .toList(),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [TColor.secondaryColor1, TColor.secondaryColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                    print('Selected category: $selectedCategory');
                    _fetchMeals(selectedDietId, selectedCategory);
                  },
                  items: ['breakfast', 'lunch', 'dinner', 'snack']
                      .map<DropdownMenuItem<String>>(
                        (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                Meal meal = meals[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.image,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    title: Text(
                      meal.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Calories: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${meal.calories}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Fat: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${meal.fat}'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealDetailScreen(meal: meal),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
