import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void onInit() {
    super.onInit();
    _fetchUserData();
    final box = GetStorage();
    final idToken = box.read('idToken');
    if (idToken != null) {
      fetchAllPeriodEvents(idToken);
      fetchNextPeriodPrediction(idToken);
    }
  }

  Future<int> updateCycleLength(DateTime currentStartDate) async {
    int cycleLength = 27; // Default fallback
    print("🔁 updateCycleLength() dipanggil untuk $currentStartDate");

    // Coba cari bulan sebelumnya dari currentStartDate
    int prevMonth = currentStartDate.month - 1;
    int prevYear = currentStartDate.year;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear -= 1;
    }

    final prevMonthStr = prevMonth.toString().padLeft(2, '0');

    var prevPeriodDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('periods')
        .doc(prevYear.toString())
        .collection(prevMonthStr)
        .doc('active')
        .get();

    DateTime? prevStartDate;
    if (prevPeriodDoc.exists) {
      prevStartDate = prevPeriodDoc.data()?['start_date']?.toDate();
      print("📌 Found prevStartDate in Firestore: $prevStartDate");
    }

    if (prevStartDate != null) {
      cycleLength = currentStartDate.difference(prevStartDate).inDays;
      print("✅ Cycle length dihitung dari bulan sebelumnya: $cycleLength hari");
    } else {
      // Fallback: cari bulan setelahnya
      int nextMonth = currentStartDate.month + 1;
      int nextYear = currentStartDate.year;
      if (nextMonth == 13) {
        nextMonth = 1;
        nextYear += 1;
      }

      final nextMonthStr = nextMonth.toString().padLeft(2, '0');

      var nextPeriodDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('periods')
          .doc(nextYear.toString())
          .collection(nextMonthStr)
          .doc('active')
          .get();

      DateTime? nextStartDate;
      if (nextPeriodDoc.exists) {
        nextStartDate = nextPeriodDoc.data()?['start_date']?.toDate();
        print("📌 Found nextStartDate in Firestore: $nextStartDate");
      }

      if (nextStartDate != null) {
        cycleLength = nextStartDate.difference(currentStartDate).inDays;
        print(
            "✅ Cycle length dihitung dari bulan setelahnya: $cycleLength hari");
      } else {
        // Fallback terakhir: ambil dari user.lastPeriodStartDate
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final lastStartDate =
              userDoc.data()?['lastPeriodStartDate']?.toDate();
          if (lastStartDate != null &&
              currentStartDate.isAfter(lastStartDate)) {
            cycleLength = currentStartDate.difference(lastStartDate).inDays;
            print(
                "⚠️ Fallback: dihitung dari lastPeriodStartDate = $lastStartDate → $cycleLength hari");
          } else {
            print(
                "⚠️ Tidak ditemukan data sebelumnya. Gunakan default 27 hari");
          }
        }
      }
    }

    print("🟢 Selesai updateCycleLength → cycleLength: $cycleLength hari");
    return cycleLength;
  }

  Future<void> removeEventAndNotes(DateTime selectedDate) async {
    final normalizedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final formattedDate = DateFormat('yyyy-MM-dd').format(normalizedDate);

    final year = normalizedDate.year.toString();
    final month = DateFormat('MM').format(normalizedDate);

    final periodRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId) // Replace with actual user ID
        .collection('periods')
        .doc(year)
        .collection(month)
        .doc('active');

    try {
      // Check if the 'active' document exists
      final doc = await periodRef.get();

      if (doc.exists) {
        final data = doc.data();

        // Get existing notes, startDate, and endDate
        final notes = Map<String, dynamic>.from(data?['notes'] ?? {});
        final startDate = data?['start_date'] as Timestamp?;
        final endDate = data?['end_date'] as Timestamp?;

        print('Notes: $notes');
        print('Start Date: $startDate');
        print('End Date: $endDate');

        // Convert Firestore Timestamps to DateTime
        final startDateTime = startDate?.toDate();
        final endDateTime = endDate?.toDate();

        // Remove the selected date from notes if it exists
        notes.remove(formattedDate);

        // Reset start and end dates if selectedDate matches
        if (startDateTime != null &&
            selectedDate.isAtSameMomentAs(startDateTime)) {
          // Reset if it's the same as the selected date
          await periodRef.update({
            'start_date': null,
            'end_date': null,
            'notes': notes, // Update notes
          });

          events.refresh();

          print('Start and End dates reset in Firestore.');
        } else {
          // Handle the case where startDate doesn't match selectedDate, or implement endDate logic
          print('No changes to start or end date.');
        }

        // Update the Firestore document with the new notes
        await periodRef.update({
          'notes': notes, // Updated notes
        });

        print('Firestore updated with notes removed.');
      } else {
        print('Document does not exist, creating new document.');

        // If document doesn't exist, create it with initial data
        await periodRef.set({
          'notes': {}, // Initialize notes as an empty map
          'start_date': null, // Set default value for start_date
          'end_date': null, // Set default value for end_date
          'periodLength': 0, // Set default value for periodLength
        });

        print('New active document created.');
      }
    } catch (e) {
      print('Error updating Firestore: $e');
    }
    events.refresh();
  }

  Future<void> removeNote(DateTime eventDate) async {
    final normalizedDate =
        DateTime(eventDate.year, eventDate.month, eventDate.day);
    final formattedDate = DateFormat('yyyy-MM-dd').format(eventDate);

    // Hapus dari local map
    if (events.containsKey(normalizedDate)) {
      events[normalizedDate] = events[normalizedDate]!
          .where((e) => e['type'] != 'noteOnly' || e['date'] != eventDate)
          .toList();

      // Kalau udah kosong, hapus key-nya
      if (events[normalizedDate]!.isEmpty) {
        events.remove(normalizedDate);
      }
    }

    events.refresh();

    // Hapus dari Firestore
    String year = eventDate.year.toString();
    String month = DateFormat('MM').format(eventDate);

    var periodRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('periods')
        .doc(year)
        .collection(month)
        .doc('active');

    // Ambil dokumen dulu
    final doc = await periodRef.get();
    if (doc.exists) {
      final notes = Map<String, dynamic>.from(doc.data()?['notes'] ?? {});
      if (notes.containsKey(formattedDate)) {
        notes.remove(formattedDate);
        await periodRef.update({'notes': notes});
      }
    }

    events.refresh();
  }

  void onFormatChanged(CalendarFormat format) {
    calendarFormat.value = format;
  }

  void _fetchUserData() async {
    if (userId.isEmpty) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      userCycleLength.value = userDoc['cycleLength'];
    }
  }

  Future<void> fetchEventsForMonth(DateTime month) async {
    final year = DateFormat('yyyy').format(month);
    final mon = DateFormat('MM').format(month);

    final periodSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('periods')
        .doc(year)
        .collection(mon)
        .doc('active')
        .get();

    if (periodSnap.exists) {
      final data = periodSnap.data()!;
      final start = (data['start_date'] as Timestamp).toDate();
      final end = (data['end_date'] as Timestamp).toDate();
      final notes = Map<String, dynamic>.from(data['notes'] ?? {});

      startDate.value = start;
      endDate.value = end;
      addEvent(start, 'start',
          note: notes[DateFormat('yyyy-MM-dd').format(start)] ?? '');
      addEvent(end, 'end',
          note: notes[DateFormat('yyyy-MM-dd').format(end)] ?? '');
    }
  }

  Future<void> addEvent(DateTime eventDate, String eventType,
      {String? note, bool saveToFirestore = true}) async {
    final normalizedDate =
        DateTime(eventDate.year, eventDate.month, eventDate.day);

    // Menambahkan event ke dalam map 'events' berdasarkan tanggal yang ternormalisasi
    if (!events.containsKey(normalizedDate)) {
      events[normalizedDate] = [];
    }
    events[normalizedDate]!.add({
      'type': eventType,
      'date': eventDate,
      'notes': note ?? '',
    });

    events.refresh();

    if (!saveToFirestore) return;

    // Simpan ke Firestore
    String year = eventDate.year.toString();
    String month = DateFormat('MM').format(eventDate);

    var periodRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('periods')
        .doc(year)
        .collection(month)
        .doc('active');

    print('Saving event to Firestore...');

    if (eventType == 'start') {
      await periodRef.set({
        'start_date': Timestamp.fromDate(eventDate),
        'notes': note != null
            ? {DateFormat('yyyy-MM-dd').format(eventDate): note}
            : {},
      }, SetOptions(merge: true));
      print('Start date saved: $eventDate');
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final lastPeriodStartDate = userData?['lastPeriodStartDate']?.toDate();

        if (lastPeriodStartDate == null) {
          // Kalau belum ada data, update aja
          final newCycleLength = await updateCycleLength(eventDate);
          await userRef.update({'cycleLength': newCycleLength});
          print('✅ Cycle length updated (no previous start).');
        } else {
          // Hitung beda bulan
          int monthDiff = (lastPeriodStartDate.year - eventDate.year) * 12 +
              (lastPeriodStartDate.month - eventDate.month);

          if (monthDiff == 1) {
            final newCycleLength = await updateCycleLength(eventDate);
            await userRef.update({'cycleLength': newCycleLength});
            print('✅ Cycle length updated (difference 1 month).');
          } else {
            print('⛔ Skip update cycleLength (not 1 month difference).');
          }
        }
      }
    } else if (eventType == 'end') {
      await periodRef.set({
        'end_date': Timestamp.fromDate(eventDate),
        'notes': note != null
            ? {DateFormat('yyyy-MM-dd').format(eventDate): note}
            : {},
      }, SetOptions(merge: true));
      print('End date saved: $eventDate');

      // Perbarui periodLength setelah perubahan endDate
      final periodDoc = await periodRef.get();
      if (periodDoc.exists) {
        final startDate = periodDoc.data()?['start_date']?.toDate();
        if (startDate != null) {
          final newPeriodLength = eventDate.difference(startDate).inDays + 1;
          print('New period length: $newPeriodLength');

          // Update periodLength di Firestore
          await periodRef.update({
            'periodLength': newPeriodLength,
          });

          // Update prediksi & cycleLength di user doc + simpan prediksi
          final userRef =
              FirebaseFirestore.instance.collection('users').doc(userId);
          final userDoc = await userRef.get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            if (userData != null) {
              // Hitung ulang cycle length berdasarkan start_date yang baru
              final updatedStartDate =
                  startDate; // Ambil start_date terbaru dari periodRef
              final newCycleLength = await updateCycleLength(updatedStartDate);
              print('New cycle length: $newCycleLength');

              final newPeriodLength =
                  eventDate.difference(updatedStartDate).inDays + 1;

              final predictedStart =
                  updatedStartDate.add(Duration(days: newCycleLength));
              final predictedEnd =
                  predictedStart.add(Duration(days: newPeriodLength - 1));
              print('Predicted start: $predictedStart');
              print('Predicted end: $predictedEnd');

              final predYear = DateFormat('yyyy').format(predictedStart);
              final predMonth = DateFormat('MM').format(predictedStart);

              final userRef =
                  FirebaseFirestore.instance.collection('users').doc(userId);
              final userDoc = await userRef.get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final lastStartDate =
                    userData?['lastPeriodStartDate']?.toDate();
                final lastEndDate = userData?['lastPeriodEndDate']?.toDate();

                if (lastStartDate == null ||
                    updatedStartDate.isAfter(lastStartDate)) {
                  await userRef.update({
                    'cycleLength': newCycleLength,
                    'periodLength': newPeriodLength,
                    'lastPeriodStartDate': Timestamp.fromDate(updatedStartDate),
                    'lastPeriodEndDate': Timestamp.fromDate(eventDate),
                  });
                } else if (lastStartDate.isAtSameMomentAs(updatedStartDate)) {
                  // Kalau start_date sama tapi end_date beda, update end_date aja
                  if (lastEndDate == null ||
                      eventDate.isAfter(lastEndDate) ||
                      eventDate.isBefore(lastEndDate)) {
                    await userRef.update({
                      'lastPeriodEndDate': Timestamp.fromDate(eventDate),
                      'periodLength': newPeriodLength,
                    });
                  }
                } else {
                  print(
                      'Skip update lastPeriodStartDate di addEvent karena lebih lama.');
                }
              }

              // Simpan prediksi baru
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('predictions')
                  .doc(predYear)
                  .collection(predMonth)
                  .doc('active')
                  .set({
                'predicted_start': Timestamp.fromDate(predictedStart),
                'predicted_end': Timestamp.fromDate(predictedEnd),
                'created_at': FieldValue.serverTimestamp(),
                'is_confirmed': false,
              });
            }
          }
        }
      }
    } else if (eventType == 'noteOnly') {
      final formattedDate = DateFormat('yyyy-MM-dd').format(eventDate);

      // Simpan ke Firestore
      await periodRef.set({
        'notes': {
          formattedDate: note ?? '',
        }
      }, SetOptions(merge: true));

      print('Note added to Firestore & local map.');
    }
    events.refresh();
  }

  Future<void> markStartEndPeriod(DateTime startDate,
      {String note = ""}) async {
    // Ambil user data langsung dari Firestore
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return;

    final data = userDoc.data();
    if (data == null) return;

    final int periodLength = data['periodLength'] ?? 5;

    final endDate = startDate.add(Duration(days: 4));

    // Tambahkan event Start dan End
    await addEvent(startDate, 'start', note: note);
    await addEvent(endDate, 'end');

    // Simpan ke Firestore untuk periode aktif
    final year = DateFormat('yyyy').format(startDate);
    final month = DateFormat('MM').format(startDate);

    // Mengambil notes yang ada
    final existingNotesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('periods')
        .doc(year)
        .collection(month)
        .doc('active')
        .get();

    Map<String, dynamic> existingNotes = {};
    if (existingNotesSnap.exists) {
      existingNotes =
          Map<String, dynamic>.from(existingNotesSnap.data()?['notes'] ?? {});
    }

    // Menyaring notes yang berada di antara start_date dan end_date
    Map<String, dynamic> filteredNotes = {};

    existingNotes.forEach((date, noteValue) {
      final noteDate = DateTime.parse(date);

      if (noteDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          noteDate.isBefore(endDate.add(Duration(days: 1)))) {
        filteredNotes[date] = noteValue;
      }
    });

    // Menambahkan notes baru jika ada
    if (note.isNotEmpty) {
      filteredNotes[DateFormat('yyyy-MM-dd').format(startDate)] = note;
    }

    // Update notes dengan hanya yang valid dan tambahkan yang baru
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('periods')
        .doc(year)
        .collection(month)
        .doc('active')
        .set({
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      if (filteredNotes.isNotEmpty) 'notes': filteredNotes,
    }, SetOptions(merge: true));

    final periodDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('periods')
        .doc(year)
        .collection(month)
        .doc('active')
        .get();

    if (periodDoc.exists) {
      final updatedStartDate = periodDoc.data()?['start_date']?.toDate();
      if (updatedStartDate != null) {
        // Pastikan siklus panjang terbaru digunakan untuk prediksi
        final cycleLength = await updateCycleLength(
            updatedStartDate); // Gunakan updatedStartDate terbaru
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);
        final userDoc = await userRef.get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final lastStartDate = userData?['lastPeriodStartDate']?.toDate();
          final lastEndDate = userData?['lastPeriodEndDate']?.toDate();

          if (lastStartDate == null ||
              updatedStartDate.isAfter(lastStartDate) ||
              (updatedStartDate.year == lastStartDate.year &&
                  updatedStartDate.month == lastStartDate.month &&
                  updatedStartDate.isBefore(lastStartDate))) {
            await userRef.update({
              'cycleLength': cycleLength,
              'lastPeriodStartDate': Timestamp.fromDate(updatedStartDate),
              'lastPeriodEndDate': Timestamp.fromDate(endDate),
            });
          } else if (isSameDay(updatedStartDate, lastStartDate)) {
            if (lastEndDate == null || endDate.isAfter(lastEndDate)) {
              await userRef.update({
                'lastPeriodEndDate': Timestamp.fromDate(endDate),
              });
            }
          } else {
            print('❌ Skip update karena tanggal lama dan beda bulan.');
          }
        }

        final predictedStart = updatedStartDate
            .add(Duration(days: cycleLength)); // Gunakan cycleLength terbaru
        final predictedEnd = predictedStart.add(Duration(days: periodLength));

        final predYear = DateFormat('yyyy').format(predictedStart);
        final predMonth = DateFormat('MM').format(predictedStart);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('predictions')
            .doc(predYear)
            .collection(predMonth)
            .doc('active')
            .set({
          'predicted_start': Timestamp.fromDate(predictedStart),
          'predicted_end': Timestamp.fromDate(predictedEnd),
          'created_at': FieldValue.serverTimestamp(),
          'is_confirmed': false,
        });
      }
    }
  }

  Future<void> fetchNextPeriodPrediction(String idToken) async {
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

      // ✅ Gunakan fungsi parseEventsFromJson agar terhubung ke kalender
      parseEventsFromJson(body);

      // ✅ Cari predicted_start untuk UI
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
    }
  }

  Future<void> fetchAllPeriodEvents(String $idToken) async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/periods-events'),
        headers: {
          'Authorization': 'Bearer ${$idToken}',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Decoded JSON data: $data');

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

    // Merge newEvents ke events tanpa hapus event lama
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

// Pastikan UI tahu ada update
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
