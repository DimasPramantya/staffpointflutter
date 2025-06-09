import 'dart:convert';

import 'package:eventsource/eventsource.dart';
import 'package:hive/hive.dart';
import 'package:staffpoint/service/notification_service.dart';

class SseService {
  EventSource? _eventSource;

  Future<void> connectToCompanyStream(void Function(Map<String, dynamic>) onMessage,) async {
    final url = Uri.parse('https://staff-point-352086447594.asia-southeast2.run.app/api/stream');
    final box = await Hive.openBox('authBox');
    final token = box.get('token');
    try {
      _eventSource = await EventSource.connect(
        url.toString(),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _eventSource?.listen((event) {
        if (event.data != null) {
          //onMessage({'message': event.data});
          showNotification(event.data!);
        }
      });
    } catch (e) {
      print("SSE connection error: $e");
    }
  }

  void disconnect() {
    _eventSource = null;
  }
}