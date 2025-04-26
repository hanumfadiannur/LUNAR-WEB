import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunar/pages/auth_page.dart';

class HomeController extends GetxController {
  final user = FirebaseAuth.instance.currentUser!;
  final todayDate = DateFormat("d MMM").format(DateTime.now());
  var currentCycleMessage = ''.obs; // RxString
  var currentCycleStatus = ''.obs; // RxString
  var currentDay = 0.obs; // RxInt
  var fullname = ''.obs; // RxString

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); // Ambil data pengguna saat inisialisasi
    _checkCycleStatus();
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

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const AuthPage()); // langsung ganti semua halaman
  }

  void navigateTo(Widget page) {
    Get.to(() => page);
  }

  void fetchUserData() async {
    if (user.uid.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Use user.uid to get the current user's document
            .get();

        if (userDoc.exists) {
          fullname.value = userDoc['fullname'] ?? "User"; // Set fullname value
          print("Fullname: ${fullname.value}");
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to fetch user data. Please try again later.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _checkCycleStatus() async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null) {
        final lastPeriodStartDate = userData['lastPeriodStartDate']?.toDate();
        final lastPeriodEndDate = userData['lastPeriodEndDate']?.toDate();
        final cycleLength = userData['cycleLength'] ?? 28;

        // Jika ada lastPeriodStartDate, cek status siklus
        if (lastPeriodStartDate != null) {
          final today = DateTime.now();

          // Prediksi tanggal periode berikutnya
          final predictedStartDate =
              lastPeriodStartDate.add(Duration(days: cycleLength));

          String formattedPredictedStartDate =
              DateFormat('MMMM d y').format(predictedStartDate);
          // Print predictedStartDate untuk debugging
          print("Predicted Start Date: $formattedPredictedStartDate");

          // Cek apakah prediksi bulan depan sudah lewat
          if (today.isAfter(predictedStartDate)) {
            // Jika lastPeriodStartDate bulan lalu, tampilkan pesan keterlambatan
            if (lastPeriodStartDate.month != today.month) {
              final daysDelayed = today.difference(lastPeriodStartDate).inDays;
              currentCycleMessage.value = "Your period is delayed!";
              currentCycleStatus.value =
                  "Delayed by $daysDelayed days since last month.";
            }
          } else if (today.isAfter(lastPeriodStartDate) &&
              today.isBefore(lastPeriodEndDate)) {
            currentCycleMessage.value = "Your period has started!";
            currentCycleStatus.value =
                "Day ${today.difference(lastPeriodStartDate).inDays + 2}"; // Menunjukkan hari ke-n setelah mulai
          }
          // Jika hari ini masih dalam bulan yang sama dan sudah selesai haid
          else if (today.month == lastPeriodStartDate.month &&
              today.isBefore(predictedStartDate)) {
            currentCycleMessage.value = "Your period has ended!";
            currentCycleStatus.value =
                "Your period is expected to begin on, $formattedPredictedStartDate";
          }
          // Jika periode sudah selesai
          else if (today
              .isAfter(lastPeriodStartDate.add(Duration(days: cycleLength)))) {
            currentCycleMessage.value = "Your period is finished.";
            currentCycleStatus.value = "End of cycle.";
          }
        } else {
          // Jika tidak ada lastPeriodStartDate, tampilkan pesan bahwa data siklus belum tersedia
          currentCycleMessage.value = "No cycle data available.";
          currentCycleStatus.value = "Please log your last period date.";
        }
      }
    }
  }
}
