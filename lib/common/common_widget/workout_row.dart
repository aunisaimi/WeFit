import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:diet_app/common/color_extension.dart';

class WorkoutRow extends StatelessWidget {
  final Map wObj;

  const WorkoutRow({Key? key, required this.wObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final String workoutName = wObj['title'] ?? 'Unknown Workout';
    final int caloriesBurned = wObj['kcal'] ?? 0;
    final int durationMinutes = wObj['time'] ?? 0;
    final String imageUrl = wObj['image'] ?? '';
    final double progress = (wObj['progress'] as double?) ?? 0.0;
    final Timestamp? timestamp = wObj['timestamp'] as Timestamp?;
    final DateTime? workoutDate = timestamp?.toDate();
    final String formattedDate = workoutDate != null
        ? DateFormat.yMMMd().add_jm().format(workoutDate)
        : 'Unknown Date';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/img/1.png', // Ensure this image exists
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutName,
                    style: TextStyle(color: TColor.black, fontSize: 12),
                  ),
                  Text(
                    "$caloriesBurned Calories Burn | $durationMinutes minutes",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SimpleAnimationProgressBar(
                    height: 15,
                    width: media.width * 0.5,
                    backgroundColor: Colors.grey.shade100,
                    foregrondColor: Colors.purple,
                    ratio: progress,
                    direction: Axis.horizontal,
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(seconds: 3),
                    borderRadius: BorderRadius.circular(7.5),
                    gradientColor: LinearGradient(
                        colors: TColor.primaryG,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                  ),
                ],
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_forward_ios_rounded))
        ],
      ),
    );
  }
}
