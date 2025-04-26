import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContentController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;
  final contentList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  void loadContent() {
    contentList.assignAll([
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
    ]);
  }

  void toggleContent(int index) {
    contentList[index]["expanded"] = !(contentList[index]["expanded"] ?? false);
    contentList.refresh();
  }
}
