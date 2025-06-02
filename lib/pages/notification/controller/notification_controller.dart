import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  final notifications = <Map<String, dynamic>>[].obs;
  final currentCycleMessage = ''.obs;
  final currentCycleStatus = ''.obs;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    final idToken = box.read('idToken');
    if (idToken != null) {
      loadNotifications(idToken);
    }
  }

  Future<void> loadNotifications(String idToken) async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/notification'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        var data = response.body;
        final decoded = jsonDecode(data);

        // Parsing dan konversi timestamp string ke DateTime
        final List<Map<String, dynamic>> loadedNotifications =
            (decoded['notifications'] as List<dynamic>? ?? []).map((notif) {
          final map = Map<String, dynamic>.from(notif);
          if (map['timestamp'] is String) {
            map['timestamp'] = DateTime.parse(map['timestamp']);
          }
          return map;
        }).toList();

        notifications.assignAll(loadedNotifications);
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }
}
