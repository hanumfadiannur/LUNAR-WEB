import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import '../../../components/cycle_input_dialog.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;

  final storage = GetStorage();

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
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': emailController.text.trim(),
            'password': passwordController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final hasCycleData = data['hasCycleData'] == true;

          final uid = data['uid'];
          final idToken = data['idToken'];

          storage.write('uid', uid);
          storage.write('idToken', idToken);

          if (!hasCycleData) {
            await Get.dialog(
              CycleInputDialog(
                userId: uid,
                idToken: idToken,
                onDataSaved: () {
                  Get.offAllNamed(AppRoutes.home);
                },
              ),
              barrierDismissible: false,
            );
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
        } else {
          final error = jsonDecode(response.body);
          Get.snackbar('Error', error['error'] ?? 'Login failed',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Error', 'Login failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    }
  }
}
