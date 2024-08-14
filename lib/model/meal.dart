import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String id;
  final String name;
  final String category;
  final int calories;
  final int fat;
  final String image;
  final String title;
  final String recommend;
  final String dietId;
  final String tips;
  final String dietType;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.fat,
    required this.dietId,
    required this.title,
    required this.recommend,
    required this.image,
    required this.dietType,
    required this.tips
  });

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Meal(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      calories: int.parse(data['calories'] as String),
      fat: int.parse(data['fat'] as String),// Make sure to provide a default value
      title: data['title'] ?? '',
      recommend: data['recommend'] ?? '',
      image: data['image'] ?? '', // Make sure to provide a default value
      dietId: data['dietId'] ?? '',
      dietType: data['dietType'] ?? '',
      tips: data['tips'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories': calories,
      'fat': fat,
      'title': title,
      'recommend': recommend,
      'image': image,
      'dietId': dietId,
      'dietType': dietType,
      'tips': tips,
    };
  }

}