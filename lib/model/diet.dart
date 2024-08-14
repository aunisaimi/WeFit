import 'package:cloud_firestore/cloud_firestore.dart';

class Diet {
  final String id;
  final String dietType;

  Diet({
    required this.id,
    required this.dietType,
  });

  factory Diet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Diet(
      id: doc.id,
      dietType: data['dietType'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dietType': dietType,
    };
  }

  Future<void> createDietsCollection() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    List<Diet> diets = [
      Diet(id: 'low_carb_diet', dietType: 'Low Carb Diet'),
      Diet(id: 'calorie_deficit', dietType: 'Calorie Deficit'),
      Diet(id: 'intermittent_fasting', dietType: 'Intermittent Fasting'),
      Diet(id: 'vegan_diet', dietType: 'Vegan Diet'),
      Diet(id: 'keto_diet', dietType: 'Keto Diet'),
      Diet(id: 'mediterranean_diet', dietType: 'Mediterranean Diet'),
      Diet(id: 'paleo_diet', dietType: 'Paleo Diet'),
    ];

    for (var diet in diets) {
      print('Creating diet: ${diet.id}'); // Debug print
      await _firestore.collection('diets').doc(diet.id).set(diet.toMap());
      print('Diet ${diet.id} created'); // Debug print
    }
    print('Diets collection created');
  }
}
