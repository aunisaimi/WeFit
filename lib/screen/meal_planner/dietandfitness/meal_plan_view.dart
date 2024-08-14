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
  List<Diet> diets = [];
  int? _remainingCalories;
  bool _isLoading = true; // To control the loading state

  Map<String, Map<String, dynamic>> selectedMeals = {
    "Breakfast": {},
    "Lunch": {},
    "Snack": {},
    "Dinner": {},
  };

  List<Map<String, dynamic>> mealArr = [
    {
      "category": "Breakfast",
      "name": "Nasi Lemak",
      "image": "assets/img/nasi lemak.jpeg",
      "title": "Nasi Lemak",
      "calories": 350,
      "fat": 15,
      "recommendedAmount": "1 plate"
    },
    {
      "category": "Breakfast",
      "name": "Roti Canai",
      "image": "assets/img/roti_canai.jpg",
      "title": "Roti Canai",
      "calories": 318,
      "fat": 11,
      "recommendedAmount": "1 plate"
    },
    {
      "category": "Breakfast",
      "name": "Bubur Ayam",
      "image": "assets/img/bubur.jpeg",
      "title": "Bubur",
      "calories": 333,
      "fat": 11,
      "recommendedAmount": "1 plate"
    },
    {
      "category": "Lunch",
      "name": "Nasi Kerabu",
      "image": "assets/img/nasi_kerabu.jpg",
      "title": "Nasi Kerabu",
      "calories": 450,
      "fat": 20,
      "recommendedAmount": "1 serving"
    },
    {
      "category": "Lunch",
      "name": "Nasi Goreng",
      "image": "assets/img/nasi_goreng.jpg",
      "title": "Nasi Goreng",
      "calories": 637,
      "fat": 25,
      "recommendedAmount": "1 serving"
    },
    {
      "category": "Lunch",
      "name": "Laksa Penang",
      "image": "assets/img/laksa_penang.jpg",
      "title": "Laksa Penang",
      "calories": 377,
      "fat": 2,
      "recommendedAmount": "1 serving"
    },
    {
      "category": "Lunch",
      "name": "Satay Ayam / Daging",
      "image": "assets/img/satay.jpg",
      "title": "Satay Ayam / Daging",
      "calories": 47,
      "fat": 1.4,
      "recommendedAmount": "2 serving"
    },
    {
      "category": "Snack",
      "name": "Snacks",
      "image": "assets/img/snacks.jpeg",
      "title": "Snacks",
      "calories": 200,
      "fat": 10,
      "recommendedAmount": "1 packet"
    },
    {
      "category": "Dinner",
      "name": "Mee goreng Mamak",
      "image": "assets/img/mee.jpg",
      "title": "Mee goreng Mamak",
      "calories": 500,
      "fat": 25,
      "recommendedAmount": "1 plate"
    },
    {
      "category": "Dinner",
      "name": "MeeHun Goreng",
      "image": "assets/img/meehoon.jpg",
      "title": "MeeHun Goreng",
      "calories": 588,
      "fat": 23,
      "recommendedAmount": "1 plate"
    },
    {
      "category": "Dinner",
      "name": "Tomyam Seafood",
      "image": "assets/img/tomyam.jpg",
      "title": "Tomyam Seafood",
      "calories": 285,
      "fat": 19,
      "recommendedAmount": "1 plate"
    },
    {
      "category": "Dinner",
      "name": "Nasi Goreng",
      "image": "assets/img/nasi_goreng.jpg",
      "title": "Nasi Goreng",
      "calories": 637,
      "fat": 25,
      "recommendedAmount": "1 serving"
    },
  ];

  List<Map<String, dynamic>> get filteredMeals {
    return mealArr.where((meal) =>
    meal["category"] == selectedCategory &&
        meal["title"].toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

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

  Future<void> _loadInitialCalories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      int initialCalories = (userDoc.get('initialCalories') as num).toInt();

      setState(() {
        _remainingCalories = initialCalories;
        _isLoading = false; // Update loading state
      });

      _saveRemainingCalories(_remainingCalories!);
      await _loadData();
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
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       widget.onCaloriesUpdated(remainingCalories);
        //       SharedPreferences.getInstance().then((prefs) {
        //         prefs.setInt('remainingCalories', remainingCalories);
        //         prefs.setString(
        //             'lastUpdateDate',
        //             DateFormat('yyyy-MM-dd').format(DateTime.now()));
        //       });
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //           content: Text('Remaining calories saved.'),
        //         ),
        //       );
        //     },
        //     icon: const Icon(Icons.save),
        //   ),
        // ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                    title: "Snack",
                    type: isActiveTab == 2
                        ? RoundButtonType.bgSGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      setState(() {
                        isActiveTab = 2;
                        selectedCategory = "Snack";
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
                          child: Image.asset(
                            meal["image"].toString(),
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
                        Text(
                          meal["title"],
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
                          "Recommended Amount: ${meal["recommendedAmount"]}",
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
