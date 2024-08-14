import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  final String exerciseName;
  final String historyId;

  const StopwatchScreen({
    Key? key,
    required this.exerciseName,
    required this.historyId,
  }) : super(key: key);

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _markAsPending();
  }

  void _markAsCompleted() {
    _firestore.collection('history').doc(widget.historyId).update({
      'status': 'completed',
      'finishTimestamp': FieldValue.serverTimestamp(),
    });
  }

  void _markAsPending() {
    _firestore.collection('history').doc(widget.historyId).update({
      'status': 'pending',
      'startTimestamp': FieldValue.serverTimestamp(),
    });
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    // Update startTimestamp when stopwatch starts
    _markAsPending();
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formattedTime() {
    final duration = _stopwatch.elapsed;
    return '${duration.inMinutes.toString().padLeft(2, '0')}'
        ':${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        centerTitle: true,
        elevation: 0,
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formattedTime(),
            style: const TextStyle(fontSize: 48),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
                child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _resetStopwatch,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _markAsCompleted();
              Navigator.pop(context); // Optionally navigate back
            },
            child: const Text('Finish Workout'),
          ),
        ],
      ),
    );
  }
}