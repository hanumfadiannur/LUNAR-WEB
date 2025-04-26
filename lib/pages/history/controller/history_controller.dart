import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Pastikan sudah menambahkan Firebase
import 'package:intl/intl.dart';

class HistoryController extends GetxController {
  var startDate = ''.obs; // Menyimpan tanggal mulai siklus
  var periodLength = ''.obs; // Menyimpan panjang periode
  var daysAgo = ''.obs; // Menyimpan selisih hari dari tanggal sekarang
  var cycleHistory = <Map<String, dynamic>>[]
      .obs; // Menyimpan riwayat siklus dari seluruh bulan
  var fullname = ''.obs; // Menyimpan fullname pengguna
  // Ambil userId dari FirebaseAuth
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); // Memanggil fungsi untuk mengambil data penggun
    fetchCycleHistory(); // Memanggil fungsi untuk mengambil data sejarah siklus
  }

  void fetchUserData() async {
    if (userId.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          fullname.value = userDoc['fullname'] ?? "User";
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Fungsi untuk mengambil data siklus
  void fetchCycleHistory() async {
    try {
      final year = DateFormat('yyyy')
          .format(DateTime.now()); // Mendapatkan tahun sekarang

      List<Map<String, dynamic>> history = []; // Menyimpan riwayat siklus

      // Loop melalui 12 bulan
      for (int monthIndex = 1; monthIndex <= 12; monthIndex++) {
        final month = monthIndex
            .toString()
            .padLeft(2, '0'); // Format bulan dengan dua digit

        // Ambil data dari Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('periods')
            .doc(year)
            .collection(month)
            .doc('active')
            .get();

        if (doc.exists) {
          final data = doc.data()!;

          // Mengambil tanggal mulai dan selesai
          final start = (data['start_date'] as Timestamp).toDate();
          final end = (data['end_date'] as Timestamp).toDate();

          // Menangani 'notes', apakah berupa Map atau List
          final notesData = data['notes'];
          Map<String, dynamic> notes = {};

          if (notesData is Map) {
            notes = Map<String, dynamic>.from(notesData);
          } else if (notesData is List) {
            // Mengubah List menjadi Map dengan indeks sebagai key
            notes = {
              for (var i = 0; i < notesData.length; i++) '$i': notesData[i]
            };
          }

          // Menghitung panjang periode dan selisih hari
          final period = end.difference(start).inDays;
          final daysDifference = DateTime.now().difference(start).inDays;

          // Menambahkan data siklus ke dalam history
          history.add({
            'month': month,
            'startDate': DateFormat('d MMMM yyyy').format(start),
            'periodLength': "$period days",
            'daysAgo': "$daysDifference days ago",
            'notes': notes,
          });
        }
      }

      // Menyimpan hasil riwayat siklus ke dalam state reaktif
      cycleHistory.value = history;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch cycle history: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
