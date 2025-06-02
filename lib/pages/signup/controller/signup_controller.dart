import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lunar/routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final url = Uri.parse('http://127.0.0.1:8000/api/register');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullname': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        // Berhasil
        Get.snackbar(
          'Success',
          'Registration successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.signin);
      } else {
        // Gagal
        final error = json.decode(response.body);
        Get.snackbar('Error', error['error'] ?? 'Something went wrong');
      }
    }
  }
}
