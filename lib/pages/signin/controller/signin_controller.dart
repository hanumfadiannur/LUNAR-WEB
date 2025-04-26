import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lunar/components/cycle_input_dialog.dart';

import '../../../routes/app_routes.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void submit(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      try {
        // Sign in user
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          final data = userDoc.data();
          final hasCycleData = data != null &&
              data['cycleLength'] != null &&
              data['lastPeriodStartDate'] != null &&
              data['lastPeriodEndDate'] != null;

          // Jika belum ada data siklus menstruasi
          if (!hasCycleData) {
            await Get.dialog(
              CycleInputDialog(
                  userId: user.uid), // custom dialog yang kamu buat
              barrierDismissible: false,
            );
          }

          // Snackbar success login
          Get.snackbar('Success', 'Login successful!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);

          // Redirect ke home
          Get.offAllNamed(AppRoutes.home);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        }

        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    }
  }
}
