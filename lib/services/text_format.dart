import 'dart:convert';
import 'package:bodybuddiesapp/utils/constants.dart';
import 'package:intl/intl.dart';

class TextFormat {
  String encodeBookingWithDate(String id, String date) {
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    return stringToBase64Url.encode("$id:$date");
  }

  String encodeName(String name) {
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    return stringToBase64Url.encode(name);
  }

  String decodeBookingId(String id) {
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    return stringToBase64Url.decode(id);
  }

  String getDateFromDecodedString(String decoded) {
    return decoded.substring(decoded.indexOf(":") + 1, decoded.length);
  }

  String getIDFromDecodedString(String decoded) {
    return decoded.substring(0, decoded.indexOf(":"));
  }

  String getMonthFromDate(String date) {
    return date.substring(date.indexOf(".") + 1, date.length);
  }

  String getMonthName(String date) {
    return months[int.parse(getMonthFromDate(date)) - 1];
  }

  String getYear() {
    return DateTime.now().year.toString();
  }

  String getDayFromDate(String date) {
    return date.substring(0, date.indexOf("."));
  }

  String fixTimeFormat(String time) {
    return time.length == 4 &&
                time.substring(time.length, time.length) != "0" ||
            time.length == 3 &&
                time.substring(time.length - 1, time.length) != "0"
        ? "0"
        : "";
  }

  String addSlashToDate(String date) {
    return date.replaceAll('.', '/');
  }

  String getDayOfWeek(String date) {
    final dateName = DateFormat('EEEE').format(DateFormat("DD MMMM yyyy")
        .parse('${getDayFromDate(date)} ${getMonthName(date)} 2022'));
    return dateName;
  }

  String formatDouble(double total) {
    return total.toStringAsFixed(2);
  }
}
