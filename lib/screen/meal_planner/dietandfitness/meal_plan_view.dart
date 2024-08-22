import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/Helpers/preferences_helper.dart';
import 'package:diet_app/common/RoundButton.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/diet.dart';

class MealPlanView extends StatefulWidget {
  final ValueChanged<int> onCaloriesUpdated;

  const MealPlanView({
    super.key,
    required this.onCaloriesUpdated,
  });

  @override
  State<MealPlanView> createState() => _MealPlanViewState();
}

class _MealPlanViewState extends State<MealPlanView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int isActiveTab = 0;
  String searchText = '';
  String selectedCategory = 'Breakfast';
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> mealArr = []; // Initialize as empty list
  int? _remainingCalories;
  bool _isLoading = true; // To control the loading state

  Map<String, Map<String, dynamic>> selectedMeals = {
    "Breakfast": {},
    "Lunch": {},
    "Snack": {},
    "Dinner": {},
  };

  List<Map<String, dynamic>> get filteredMeals {
    return mealArr.where((meal) =>
    meal["category"] == selectedCategory &&
        (meal["name"]?.toLowerCase() ?? '').contains(searchText.toLowerCase()))
        .toList();
  }

  int get _totalCalories {
    int total = 0;
    selectedMeals.forEach((key, meal) {
      if (meal.isNotEmpty) {
        // Safely parse the calories value to int
        int calories = int.tryParse(meal["calories"].toString()) ?? 0;
        total += calories;
      }
    });
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialCalories();
  }

  void _saveRemainingCalories(int calories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remainingCalories', calories);
  }

  Future<void> _loadData() async {
    var meals = await PreferencesHelper.loadSelectedMeals();
    setState(() {
      selectedMeals = meals;
    });
  }

  Future<void> _saveData() async {
    await PreferencesHelper.saveSelectedMeals(selectedMeals);
  }

  Future<void> _fetchMealPlannerData() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore
          .instance
          .collection('mealPlanner')
          .get();

      List<Map<String, dynamic>> fetchedMeals = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "category": data["category"],
          "name": data["name"],
          "image": data["image"],
          "description": data["description"],
          "calories": data["calories"],
          "fat": data["fat"],
          "serving": data["serving"],
        };
      }).toList();

      setState(() {
        mealArr = fetchedMeals;
        _isLoading = false; // Update loading state
      });
    } catch (e) {
      // Handle errors here
      print('Error fetching meal planner data: $e');
      setState(() {
        _isLoading = false; // Update loading state
      });
    }
  }

  // Future<void> _loadInitialCalories() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  //     int initialCalories = (userDoc.get('initialCalories') as num).toInt();
  //
  //     setState(() {
  //       _remainingCalories = initialCalories;
  //     });
  //
  //     _saveRemainingCalories(_remainingCalories!);
  //     await _fetchMealPlannerData(); // Fetch meal data after loading calories
  //     await _loadData();
  //   }
  // }

  // reset daily
  Future<void> _loadInitialCalories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastUpdateDate = prefs.getString('lastUpdateDate');
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (lastUpdateDate != currentDate) {
        // Date is different, reset the meal selections
        selectedMeals = {
          "Breakfast": {},
          "Lunch": {},
          "Snack": {},
          "Dinner": {},
        };
        await _saveData();
        prefs.setString('lastUpdateDate', currentDate);
      } else {
        // Load previously selected meals if the date matches
        await _loadData();
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      int initialCalories = (userDoc.get('initialCalories') as num).toInt();

      setState(() {
        _remainingCalories = initialCalories;
      });

      _saveRemainingCalories(_remainingCalories!);
      await _fetchMealPlannerData(); // Fetch meal data after loading calories
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    int remainingCalories = (_remainingCalories ?? 0) - _totalCalories;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        title: Text(
          "Meal Plan",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: _isLoading
          ?
      Center(child: CircularProgressIndicator())
          :
      Column(
        children: [
          Container(
            decoration:
            const BoxDecoration(
              color: Colors.white70,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: RoundButton(
                    title: "Breakfast",
                    type: isActiveTab == 0
                        ? RoundButtonType.bgSGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      setState(() {
                        isActiveTab = 0;
                        selectedCategory = "Breakfast";
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RoundButton(
                    title: "Lunch",
                    type: isActiveTab == 1
                        ? RoundButtonType.bgSGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      setState(() {
                        isActiveTab = 1;
                        selectedCategory = "Lunch";
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RoundButton(
                    title: "Dinner",
                    type: isActiveTab == 3
                        ? RoundButtonType.bgSGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      setState(() {
                        isActiveTab = 3;
                        selectedCategory = "Dinner";
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text(
                  "Total calories: $_totalCalories kcal",
                  style: TextStyle(
                    color: TColor.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Remaining calories: $remainingCalories kcal",
                  style: TextStyle(
                    color: TColor.gray,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                var meal = filteredMeals[index];
                bool isSelected =
                    selectedMeals[selectedCategory]!["name"] == meal["name"];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedMeals[selectedCategory] = {};
                      } else {
                        selectedMeals[selectedCategory] = meal;
                      }
                      _saveData();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade100
                          : Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            meal["image"].toString(), // Updated to use network image
                            width: media.width,
                            height: media.width * 0.55,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          meal["name"],
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Description: ${meal["description"]}",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "Calories: ${meal["calories"]} kcal",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Fat: ${meal["fat"]} g",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Serving size: ${meal["serving"]} g",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onCaloriesUpdated(remainingCalories);
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setInt('remainingCalories', remainingCalories);
                  prefs.setString(
                      'lastUpdateDate',
                      DateFormat('yyyy-MM-dd').format(DateTime.now()));
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Remaining calories saved.'),
                  ),
                );
              },
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                primary: TColor.primaryColor1,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 1,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
