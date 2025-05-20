import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;
  final box = GetStorage();

  var name = "User".obs;
  var email = "user@example.com".obs;
  var cycleLength = 0.obs;
  var periodLength = 0.obs;
  var lastPeriodDate = Rxn<DateTime>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final storage = GetStorage();
    final idToken = storage.read('idToken');
    if (idToken != null) {
      fetchUserDataFromApi(idToken);
    }
  }

  Future<void> fetchUserDataFromApi(String idToken) async {
    try {
      isLoading.value = true;
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user/cycle-status'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        name.value = data['fullname'] ?? "User";
        email.value = data['email'] ?? "user.example.com";
        cycleLength.value = data['cycleLength'] ?? 0;
        periodLength.value = data['periodLength'] ?? 0;
      } else {
        print(
            'Failed to fetch cycle status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cycle status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void signUserOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await box.erase(); // clear storage
      Get.offAllNamed('/signin');
    } catch (e) {
      Get.snackbar("Error", "Failed to sign out.");
    }
  }

  Future<void> updateFullName(String newFullName) async {
    final storage = GetStorage();
    final idToken = storage.read('idToken');
    final uid = storage.read('uid');
    if (idToken == null || uid == null) {
      Get.snackbar("Error", "User not authenticated.");
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/api/user/update-fullname');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'firebase_uid': uid,
          'fullname': newFullName,
        }),
      );

      if (response.statusCode == 200) {
        print('Full name berhasil diupdate!');
        Get.snackbar("Success", "Full name updated.");
      } else {
        print('Gagal update full name: ${response.statusCode}');
      }
    } catch (e) {
      print('Error update full name: $e');
    }
  }
}
