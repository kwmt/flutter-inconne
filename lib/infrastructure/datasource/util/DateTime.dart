import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class DateTimeUtil {
  static DateTime parseTime(dynamic date) {
    if (date == null) {
      throw ArgumentError.notNull("DateTimeUtil#parseTime");
    }
    return Platform.isIOS ? (date as Timestamp).toDate() : (date as Timestamp).toDate();
  }
}
