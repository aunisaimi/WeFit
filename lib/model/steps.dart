// // class StepModel {
// //   final String id;
// //   final String steps;
// //   final String description;
// //
// //   StepModel({required this.id, required this.description, required this.steps});
// //
// //   factory StepModel.fromMap(String id, Map<String, dynamic> data) {
// //     return StepModel(
// //       id: id,
// //       steps:data['steps'], // as String,
// //       description: data['description'] as String,
// //     );
// //   }
// // }
//
// class StepModel {
//   final String stepNumber;
//   final String description;
//
//   StepModel({required this.stepNumber, required this.description});
//
//   factory StepModel.fromMap(String id, Map<String, dynamic> data) {
//     return StepModel(
//       stepNumber: id,
//       description: data['description'] ?? '',
//     );
//   }
// }
//

class StepModel {
  final String stepNumber;
  final String description;

  StepModel({required this.stepNumber, required this.description});

  factory StepModel.fromMap(Map<String, dynamic> data) {
    return StepModel(
      stepNumber: data['steps'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'steps': stepNumber,
      'description': description,
    };
  }
}

