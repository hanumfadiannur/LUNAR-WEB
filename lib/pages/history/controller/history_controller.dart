import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

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

    final box = GetStorage();
    final idToken = box.read('idToken');
    if (idToken != null) {
      fetchUserData(idToken);
      fetchCycleHistory(idToken);
    }
  }

  Future<void> fetchUserData(String idToken) async {
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
      } else {
        print(
            'Failed to fetch cycle status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cycle status: $e');
    }
  }

  // Fungsi untuk mengambil data siklus
  void fetchCycleHistory(String idToken) async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/cycle-history'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        var data = response.body;
        final decoded = jsonDecode(data);

        // Ubah list dynamic jadi List<Map<String, dynamic>>
        final List<Map<String, dynamic>> history =
            (decoded['history'] as List<dynamic>? ?? [])
                .map((e) => Map<String, dynamic>.from(e))
                .toList();

        cycleHistory.assignAll(history);
      } else {
        throw Exception('Failed to load cycle history');
      }
    } catch (e) {
      print('Error loading cycle history: $e');
    }
  }
}
