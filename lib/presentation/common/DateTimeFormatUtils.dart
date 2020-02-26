import 'package:intl/intl.dart';

class DateTimeFormatUtils {
  static String format(DateTime dateTime) {
    return DateFormat("yyyy/MM/dd HH:mm").format(dateTime);
  }
}
