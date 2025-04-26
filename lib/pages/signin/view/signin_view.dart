import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/signin_controller.dart';
import 'package:lunar/routes/app_routes.dart';

class SignInView extends GetView<SignInController> {
  SignInView({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink[100]!, Colors.pink[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.nightlight_round,
                      size: 48,
                      color: Colors.pink[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Lunar',
                      style: GoogleFonts.dmSans(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.pink[800],
                      )),
                  const SizedBox(height: 8),
                  Text('Sync with your rhythm',
                      style: GoogleFonts.dmSans(
                          color: Colors.pink[600], fontSize: 14)),
                  const SizedBox(height: 40),

                  // Form fields
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text("Welcome back!",
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.pink[800],
                              )),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: controller.emailController,
                            validator: controller.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.pink),
                              labelStyle:
                                  GoogleFonts.dmSans(color: Colors.pink[800]),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => TextFormField(
                              controller: controller.passwordController,
                              validator: controller.validatePassword,
                              obscureText: !controller.isPasswordVisible.value,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon:
                                    const Icon(Icons.lock, color: Colors.pink),
                                labelStyle:
                                    GoogleFonts.dmSans(color: Colors.pink[800]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.pink,
                                  ),
                                  onPressed: () {
                                    controller.isPasswordVisible.toggle();
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => controller.submit(_formKey),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink[400],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                textStyle: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text("Login"),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.dmSans(),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.toNamed(AppRoutes.signup);
                                },
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.pink[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
