/*

- e.g: Aug 07, 2024, 21:00
- will return the string: "2024-08-07 21:30"

 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestap) {
  DateTime dateTime = timestap.toDate();
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}