import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lunar/routes/app_routes.dart';

class SignUpController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+(com|net|org|co\.id)$')
        .hasMatch(value)) {
      return 'Please enter a valid email with .com or similar domain';
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

  void submitForm(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      try {
        // Step 1: Register user with email & password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Step 2: Get UID
        String uid = userCredential.user!.uid;

        // Step 3: Save additional data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullname': nameController.text.trim(),
          'email': emailController.text.trim(),
          'created_at': FieldValue.serverTimestamp(),
          'cycleLength': 27, // Default cycle length
          'lastPeriodStartDate': null,
          'lastPeriodEndDate': null,
        });

        // Show success snackbar
        Get.snackbar(
          'Success',
          'Registration successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.pink[100],
          colorText: Colors.black,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );

        Get.offAllNamed(AppRoutes
            .signin); // Redirect to sign-in page after successful registration
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Something went wrong';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak.';
        }

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
      }
    }
  }
}
