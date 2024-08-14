
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper{
  static Future<Map<String,Map<String,dynamic>>> loadSelectedMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedMealsString = prefs.getString('selectedMeals');

    if(selectedMealsString != null) {
      return (jsonDecode(selectedMealsString) as Map<String,dynamic>)
          .map((key, value) => MapEntry(key, Map<String,dynamic>.from(value)));
    }

    return {
      "Breakfast": {},
      "Lunch": {},
      "Snack": {},
      "Dinner": {},
    };
  }

  static Future<void> saveSelectedMeals(Map<String,Map<String,dynamic>> selectedMeals) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMeals', jsonEncode(selectedMeals));
  }
}