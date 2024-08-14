class ExerciseModel {
  final String type;
  final String area;
  final String description;
  final String value;
  final String title;
  final String image;
  final String steps;
  final String youtubeLink;

  ExerciseModel({
    required this.title,
    required this.type,
    required this.value,
    required this.description,
    required this.area,
    required this.image,
    required this.steps,
    required this.youtubeLink,
  });

 factory ExerciseModel.fromMap(Map<String, dynamic> data) {
    return ExerciseModel(
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      area: data['area'] ?? '',
      value: data['value'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      steps: data['steps'] ?? '',
      youtubeLink: data['youtubeLink'] ?? '',
    );
 }

 Map<String,dynamic> toMap(){
   return {
     'title': title,
     'type': type,
     'area': area,
     'value': value,
     'description': description,
     'image': image,
     'steps': steps,
     'youtubeLink': youtubeLink,
   };
 }
}