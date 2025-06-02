import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get_storage/get_storage.dart';

class CalendarController extends GetxController {
  Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;
  Rx<DateTime> focusedDay = DateTime.now().obs;
  Rx<DateTime?> selectedDay = Rx<DateTime?>(null);
  RxInt userCycleLength = 28.obs;
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);

  Map<String, DateTime> startDates = {};
  Map<String, DateTime> endDates = {};

  RxMap<DateTime, List<Map<String, dynamic>>> events =
      <DateTime, List<Map<String, dynamic>>>{}.obs;

  RxBool isStartMarked = false.obs; // State untuk menandai start
  RxBool isEndMarked = false.obs; // State untuk menandai end

  String get formattedDay => DateFormat('EEEE').format(DateTime.now());
  String get formattedDate => DateFormat('MMMM d, y').format(DateTime.now());

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  RxString nextPeriodPrediction =
      ''.obs; // Reactive variable to hold the prediction

  RxBool isLoading = false.obs; // Reactive variable for loading state

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    final idToken = box.read('idToken');
    if (idToken != null) {
      fetchAllPeriodEvents(idToken);
      fetchNextPeriodPrediction(idToken);
    }
  }

  void onFormatChanged(CalendarFormat format) {
    calendarFormat.value = format;
  }

  Future<bool> addEvent({
    required String idToken,
    required String userId,
    required DateTime eventDate,
    required String eventType,
    String? note,
  }) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/user/add-event');

    // Format tanggal jadi "YYYY-MM-DD"
    final formattedDate =
        '${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';

    final body = jsonEncode({
      'uid': userId,
      'date': formattedDate,
      'eventType': eventType,
      'note': note ?? '',
    });

    print('Sending request to: $url');
    print('Request body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeEvent({
    required String idToken,
    required String userId,
    required DateTime eventDate,
  }) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/user/remove-event');

    final formattedDate =
        '${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';

    final body = jsonEncode({
      'firebase_uid': userId,
      'date': formattedDate,
    });

    print('Sending REMOVE event request to: $url');
    print('Request body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      if (events.containsKey(eventDate)) {
        events.remove(eventDate); // hapus tanggal jika tidak ada event

        events.refresh();
      }

      print('Remove event success');
      return true;
    } else {
      print('Remove event failed');
      return false;
    }
  }

  Future<bool> removeNote({
    required String idToken,
    required String userId,
    required DateTime noteDate,
  }) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/user/remove-note');

    final formattedDate =
        '${noteDate.year.toString().padLeft(4, '0')}-${noteDate.month.toString().padLeft(2, '0')}-${noteDate.day.toString().padLeft(2, '0')}';

    final body = jsonEncode({
      'firebase_uid': userId,
      'date': formattedDate,
    });

    print('Sending REMOVE note request to: $url');
    print('Request body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Remove note success');
      return true;
    } else {
      print('Remove note failed');
      return false;
    }
  }

  Future<void> fetchNextPeriodPrediction(String idToken) async {
    isLoading.value = true;
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/user/period-prediction');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      print('Prediction status code: ${response.statusCode}');
      print('Prediction body: ${response.body}');

      if (response.statusCode != 200) {
        nextPeriodPrediction.value = "No prediction available.";
        return;
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> eventList = body['events'] ?? [];

      if (eventList.isEmpty) {
        nextPeriodPrediction.value = "No prediction available.";
        return;
      }

      parseEventsFromJson(body);

      for (var ev in eventList) {
        if (ev['type'] == 'predicted_start') {
          final DateTime ps = DateTime.parse(ev['date']);
          nextPeriodPrediction.value = " ${DateFormat('MMMM d, y').format(ps)}";
          break;
        }
      }
    } catch (e) {
      print('Error while fetching prediction: $e');
      nextPeriodPrediction.value = "Error loading prediction.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllPeriodEvents(String $idToken) async {
    isLoading.value = true;
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/periods-events'),
        headers: {
          'Authorization': 'Bearer ${$idToken}',
        },
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        parseEventsFromJson(data);
        print('Events after parsing:');
        events.forEach((date, eventList) {
          print('Date: $date');
          for (var event in eventList) {
            print(' - Event: $event');
          }
        });
      } else {
        print('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e) {
      isLoading.value = false;
      print('Error while fetching events: $e');
    }
  }

  void parseEventsFromJson(Map<String, dynamic> json) {
    final newEvents = <DateTime, List<Map<String, dynamic>>>{};
    List<dynamic> eventList = json['events'] ?? [];

    for (var event in eventList) {
      DateTime eventDate = DateTime.parse(event['date']);
      DateTime dateOnly =
          DateTime(eventDate.year, eventDate.month, eventDate.day);

      // Tambahkan ke events map
      if (!newEvents.containsKey(dateOnly)) {
        newEvents[dateOnly] = [];
      }

      newEvents[dateOnly]!.add({
        'type': event['type'],
        'date': event['date'],
        'notes': event['notes'],
      });

      // Tambahkan ini untuk mengisi startDates
      if (event['type'] == 'start') {
        String monthKey =
            "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}";
        startDates[monthKey] = dateOnly;
      }
    }

    // Merge newEvents ke dalam events
    for (var entry in newEvents.entries) {
      final existingList = events[entry.key] ?? [];
      final newList = entry.value
          .where((e) =>
              !existingList.any((existing) => existing['type'] == e['type']))
          .toList();

      if (!events.containsKey(entry.key)) {
        events[entry.key] = [];
      }
      events[entry.key]!.addAll(newList);
    }

    events.refresh();
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    this.selectedDay.value = selectedDay;
    this.focusedDay.value = focusedDay;
  }
}
