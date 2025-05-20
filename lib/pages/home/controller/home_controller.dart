import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeController extends GetxController {
  var fullname = ''.obs;
  var currentCycleMessage = ''.obs;
  var currentCycleStatus = ''.obs;
  var todaydate = DateTime.now();
  var formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    final storage = GetStorage();
    final idToken = storage.read('idToken');
    if (idToken != null) {
      fetchUserCycleStatus(idToken);
    }
  }

  final List<Map<String, dynamic>> contentList = [
    {
      "title": "What’s 'Normal'? Menstrual Cycle Length and Variation",
      "description":
          "A 'normal' menstrual cycle typically ranges from 21 to 35 days, with an average of 28 days. However, variations of 2–7 days are common...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Signs Your Period is Coming: Common PMS Symptoms",
      "description":
          "Common PMS symptoms include mood swings, bloating, breast tenderness, fatigue, and acne. These usually appear 1–2 weeks before menstruation...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Heavy vs. Light Flow: What’s Considered Normal?",
      "description":
          "Menstrual flow can vary from cycle to cycle. A normal flow ranges between 30–80 ml of blood per period. If you need to change your pad/tampon...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Period Pain: When Should You Be Concerned?",
      "description":
          "Mild to moderate period cramps are common due to uterine contractions. However, severe pain that interferes with daily activities...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Irregular Periods: When Should You Worry?",
      "description":
          "If your periods are consistently irregular, extremely short (less than 21 days), or too long (more than 35 days), it may indicate an issue...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "What Causes Missed or Skipped Periods?",
      "description":
          "Missing a period can happen for many reasons beyond pregnancy. Some common causes include high stress levels, extreme weight loss or gain...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
  ];

  void navigateTo(Widget page) {
    Get.to(() => page);
  }

  Future<void> fetchUserCycleStatus(String idToken) async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/cycle-status'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        fullname.value = data['fullname'] ?? "User";
        currentCycleMessage.value = data['currentCycleMessage'] ?? "";
        currentCycleStatus.value = data['currentCycleStatus'] ?? "";
      } else {
        print(
            'Failed to fetch cycle status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cycle status: $e');
    }
  }
}
