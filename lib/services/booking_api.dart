import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/booking.dart';

class BookingCommandException implements Exception {
  final String code;
  final String message;

  const BookingCommandException(this.code, this.message);

  @override
  String toString() => message;
}

class CancellationResult {
  final bool refunded;

  const CancellationResult({required this.refunded});
}

class BookingApi {
  static const _endpoint = String.fromEnvironment(
    'BOOKING_COMMAND_ENDPOINT',
    defaultValue:
        'https://europe-west1-bodybuddies-cf068.cloudfunctions.net/bookingCommand',
  );

  Future<void> createSession({
    required Booking booking,
    required String userId,
  }) async {
    await _command({
      'action': 'create',
      'sessionId': booking.id,
      'userId': userId,
      'trainerId': _trainerId(booking),
      'trainerName': booking.trainer,
      'localDate': _localDate(booking),
      'startTime': booking.time,
    });
  }

  Future<CancellationResult> cancelSession({
    required Booking booking,
    String? userId,
  }) async {
    final result = await _command({
      'action': 'cancel',
      'sessionId': booking.id,
      if (userId != null && userId.isNotEmpty) 'userId': userId,
      'trainerId': _trainerId(booking),
      'trainerName': booking.trainer,
      'localDate': _localDate(booking),
      'startTime': booking.time,
    });
    return CancellationResult(refunded: result['refunded'] == true);
  }

  Future<String> blockTime({
    required String trainerId,
    required String trainerName,
    required DateTime date,
    required String startTime,
    required String endTime,
    String reason = '',
  }) async {
    final localDate = _dateText(date);
    final result = await _command({
      'action': 'block',
      'blockId': 'block_${trainerId}_${localDate}_'
          '${startTime.replaceAll(':', '')}_${endTime.replaceAll(':', '')}',
      'trainerId': trainerId,
      'trainerName': trainerName,
      'localDate': localDate,
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
    });
    return result['blockId']?.toString() ?? '';
  }

  Future<void> unblockTime(String blockId) async {
    await _command({'action': 'unblock', 'blockId': blockId});
  }

  Future<void> renameSession({
    required String sessionId,
    required DateTime date,
    required String newName,
  }) async {
    await _command({
      'action': 'rename',
      'sessionId': sessionId,
      'localDate': _dateText(date),
      'newName': newName,
    });
  }

  Future<Map<String, dynamic>> _command(Map<String, dynamic> body) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw const BookingCommandException(
        'unauthenticated',
        'Please sign in again.',
      );
    }
    late http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const BookingCommandException(
        'timeout',
        'The booking server took too long. Please try again.',
      );
    } catch (_) {
      throw const BookingCommandException(
        'network',
        'Could not reach the booking server. Check your connection.',
      );
    }
    Map<String, dynamic> decoded = {};
    if (response.body.isNotEmpty) {
      try {
        final value = jsonDecode(response.body);
        if (value is Map<String, dynamic>) decoded = value;
      } catch (_) {
        // The status code below still produces a safe user-facing error.
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BookingCommandException(
        decoded['code']?.toString() ?? 'failed',
        decoded['error']?.toString() ?? 'Booking request failed.',
      );
    }
    return decoded;
  }

  String _trainerId(Booking booking) {
    if (booking.trainerId.isNotEmpty) return booking.trainerId;
    return booking.trainer
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_');
  }

  String _localDate(Booking booking) {
    return _dateText(DateTime(booking.year, booking.month, booking.day));
  }

  String _dateText(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
