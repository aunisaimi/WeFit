import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/common/common_widget/exercises_row.dart';
import 'package:flutter/cupertino.dart';

class ExercisesSetSection extends StatelessWidget {
  final Map sObj;
  final Function(Map obj) onPressed;

  const ExercisesSetSection({
    Key? key,
    required this.sObj,
    required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var exercisesArr = sObj["set"] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sObj["name"],//.toString(),
          style: TextStyle(
              color: TColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: exercisesArr.length,
            itemBuilder: (context,index){
              var eObj = exercisesArr[index] as Map? ?? {};
              return ExercisesRow(
                eObj: eObj,
                onPressed: () {
                  onPressed(eObj);
                },
              );
            })
      ],
    );
  }
}