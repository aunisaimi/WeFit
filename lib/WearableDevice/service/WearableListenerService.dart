// import 'package:flutter/material.dart';
// import 'package:wearable_engine/wearable_engine.dart';
//
// class WearableService {
//   static final WearableService _instance = WearableService._internal();
//
//   factory WearableService() {
//     return _instance;
//   }
//
//   WearableService._internal();
//
//   bool _isConnected = false;
//
//   bool get isConnected => _isConnected;
//
//   Future<void> connect() async {
//     try {
//       await WearableEngine.instance.connect();
//       _isConnected = true;
//     } catch (e) {
//       throw 'Failed to connect to wearable: $e';
//     }
//   }
//
//   void disconnect() {
//     WearableEngine.instance.disconnect();
//     _isConnected = false;
//   }
// }
