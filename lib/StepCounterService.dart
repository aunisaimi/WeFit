import 'package:flutter/services.dart';

class StepCounterService {
  static const platform = MethodChannel('stepCounterChannel');

  Future<int> getStepCount() async {
    try {
      final int stepCount = await platform.invokeMethod('getStepCount');
      return stepCount;
    } on PlatformException catch (e) {
      print("Failed to get step count: '${e.message}'.");
      return 0;
    }
  }
}
