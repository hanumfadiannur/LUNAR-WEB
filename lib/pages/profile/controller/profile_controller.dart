import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;
  var name = "User".obs;
  var email = "user@example.com".obs;
  var cycleLength = 0.obs;
  var periodLength = 0.obs;
  var lastPeriodDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void fetchUserData() async {
    if (user != null) {
      email.value = user!.email ?? "user@example.com";

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          name.value = userDoc['fullname'] ?? "User";
          cycleLength.value = userDoc['cycleLength'] ?? 0;

          Timestamp? startTimestamp = userDoc['lastPeriodStartDate'];
          Timestamp? endTimestamp = userDoc['lastPeriodEndDate'];

          if (startTimestamp != null && endTimestamp != null) {
            DateTime startDate = startTimestamp.toDate();
            DateTime endDate = endTimestamp.toDate();

            // Simpan jarak hari sebagai periodLength
            int length = endDate.difference(startDate).inDays +
                1; // Tambah 1 hari untuk menghitung panjang periode
            periodLength.value = length;

            // Optional: simpan juga ke Firestore kalau mau update di database
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .update({'periodLength': length});

            print("Period Length: $length hari");
          }
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

  Future<void> updateFullName(String newFullName) async {
    try {
      if (user != null) {
        // Memperbarui fullname di Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'fullname': newFullName});

        // Update nama di aplikasi setelah berhasil
        name.value = newFullName;

        // Memberi feedback sukses
        Get.snackbar(
          "Success",
          "Full name updated successfully.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update full name. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void signUserOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/signin');
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to sign out. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
