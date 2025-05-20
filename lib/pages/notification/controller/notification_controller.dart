import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationController extends GetxController {
  final notifications = <Map<String, dynamic>>[].obs;
  final currentCycleMessage = ''.obs;
  final currentCycleStatus = ''.obs;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null) {
        final lastPeriodStartDate = userData['lastPeriodStartDate']?.toDate();
        final lastPeriodEndDate = userData['lastPeriodEndDate']?.toDate();
        final cycleLength = userData['cycleLength'] ?? 28;

        final today = DateTime.now();

        if (lastPeriodStartDate != null) {
          final predictedStartDate =
              lastPeriodStartDate.add(Duration(days: cycleLength));
          String formattedPredictedStartDate =
              DateFormat('MMMM d, y').format(predictedStartDate);

          if (today.isAfter(predictedStartDate)) {
            if (lastPeriodStartDate.month != today.month) {
              final daysDelayed = today.difference(lastPeriodStartDate).inDays;
              notifications.add({
                'type': 'delayed',
                'message': "Your period is delayed!",
                'timestamp': today,
                'additionalText':
                    "Delayed by $daysDelayed days since last month."
              });
            }
          }

          if (today.isAfter(lastPeriodStartDate) &&
              today.isBefore(lastPeriodEndDate)) {
            notifications.add({
              'type': 'started',
              'message': "Your period has started!🌟",
              'timestamp': today,
              'additionalText':
                  "Day ${today.difference(lastPeriodStartDate).inDays + 2} of your cycle."
            });
          }

          if (today.isBefore(predictedStartDate)) {
            final daysLeft = predictedStartDate.difference(today).inDays + 1;
            notifications.add({
              'type': 'upcoming',
              'message': "Upcoming period in $daysLeft days 🌟",
              'timestamp': today,
              'additionalText': "Expected start: $formattedPredictedStartDate"
            });
          }

          if (today
              .isAfter(lastPeriodStartDate.add(Duration(days: cycleLength)))) {
            notifications.add({
              'type': 'finished',
              'message': "Your period has finished.",
              'timestamp': today,
              'additionalText': "End of current cycle."
            });
          }
        } else {
          // Ini baru jalan kalau lastPeriodStartDate == null
          notifications.add({
            'type': 'no_data',
            'message': "No cycle data available.",
            'timestamp': today,
            'additionalText': "Please log your last period date."
          });
        }
      }
    }
  }
}
