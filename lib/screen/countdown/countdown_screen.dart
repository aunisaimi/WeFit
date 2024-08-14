import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_app/common/color_extension.dart';
import 'package:diet_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../common/widget/Round_button.dart';

class CountdownScreen extends StatefulWidget {
  final String duration;
  final String historyId;

  const CountdownScreen({
    Key? key,
    required this.duration,
    required this.historyId,
  }) : super(key: key);

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isPlaying = false;
  bool isExtended = false; // Flag to check if timer has extended
  bool hasStarted = false; // Flag to check if the timer has started

  String get countText {
    Duration count = controller.duration! * controller.value;
    if (isExtended) {
      int elapsedSeconds = controller.duration!.inSeconds -
          (controller.duration!.inSeconds * controller.value).round();
      return Duration(seconds: elapsedSeconds).toString().split('.').first;
    } else {
      return controller.isDismissed
          ? '${controller.duration!.inHours}: '
          '${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
          : '${count.inHours}: '
          '${(count.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(count.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  double progress = 1.0;

  void _showNotification() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'workout_channel',
      'Workout Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      0,
      'Workout Complete',
      'Congratulations! You have completed your workout.',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void notify() {
    if (controller.isDismissed && !isExtended) {
      FlutterRingtonePlayer.playNotification();
      _showNotification(); // Show notification when the timer hits zero

      setState(() {
        isExtended = true;
        _markAsLate(); // Mark the workout as late in Firestore
        controller = AnimationController(
          vsync: this,
          duration: const Duration(hours: 999),
        );
        controller.reverse(from: 1.0);
      });
    }
  }

  void _markAsCompleted() {
    _firestore.collection('history').doc(widget.historyId).update({
      'status': isExtended ? 'late' : 'completed',
      'finishTimestamp': FieldValue.serverTimestamp(), // Add finish timestamp
    });
  }

  void _markAsPending() {
    _firestore.collection('history').doc(widget.historyId).update({
      'status': 'pending',
      'finishTimestamp': FieldValue.serverTimestamp(), // Add finish timestamp
    });
  }

  void _markAsLate() {
    _firestore.collection('history').doc(widget.historyId).update({
      'status': 'late',
      'finishTime': FieldValue.serverTimestamp(), // Add finish timestamp
    });
  }

  void _markAsStarted() {
    if (!hasStarted) {
      _firestore.collection('history').doc(widget.historyId).update({
        'startTimestamp': FieldValue.serverTimestamp(), // Add start timestamp
      });
      hasStarted = true;
    }
  }

  @override
  void initState() {
    super.initState();

    try {
      final durationInSeconds = int.parse(widget.duration);
      controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: durationInSeconds),
      );
    } catch (e) {
      print('Error parsing duration: $e');
    }

    controller.addListener(() {
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      } else {
        setState(() {
          progress = 1.0;
          isPlaying = false; // change pause to play after 0
        });
      }
      notify();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 1,
        leading: InkWell(
          onTap: () {
            _markAsPending();
            Navigator.pop(context);
          },
          child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded)),
        ),
        title: Text(
          "Countdown",
          style: TextStyle(
              color: TColor.black,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey.shade400,
                    value: progress,
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isExtended
                          ? Colors.red
                          : Colors.purple,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.isDismissed) {
                      // to restrict user from picking duration while running
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          height: 300,
                          child: CupertinoTimerPicker(
                            initialTimerDuration: controller.duration!,
                            onTimerDurationChanged: (time) {
                              setState(() {
                                controller.duration = time;
                              });
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => Text(
                      countText,
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.isAnimating) {
                      controller.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      _markAsStarted(); // Mark the start time when starting the timer
                      controller.reverse(
                          from: controller.value == 0
                              ? 1.0
                              : controller.value);
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  child: RoundButton(
                    icon: isPlaying == true
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.reset();
                    setState(() {
                      isPlaying = false;
                    });
                  },
                  child: ElevatedButton(
                    // icon: Icons.stop,
                    onPressed: () {
                      _markAsCompleted();
                      Navigator.pop(context);
                    },
                    child: const Text('Finish Workout'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
