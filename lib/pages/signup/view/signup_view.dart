import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunar/routes/app_routes.dart';
import '../controller/signup_controller.dart';

class SignUpView extends GetView<SignUpController> {
  SignUpView({super.key});
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                Text(
                  'Lunar',
                  style: GoogleFonts.dmSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.pink[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sync with your rhythm',
                  style: GoogleFonts.dmSans(
                    color: Colors.pink[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Create account",
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.pink[800],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              prefixIcon:
                                  const Icon(Icons.person, color: Colors.pink),
                              labelStyle:
                                  GoogleFonts.dmSans(color: Colors.pink[800]),
                            ),
                            style: GoogleFonts.dmSans(),
                            validator: controller.validateName,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.pink),
                              labelStyle:
                                  GoogleFonts.dmSans(color: Colors.pink[800]),
                            ),
                            style: GoogleFonts.dmSans(),
                            validator: controller.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          Obx(() => TextFormField(
                                controller: controller.passwordController,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.pink),
                                  labelStyle: GoogleFonts.dmSans(
                                      color: Colors.pink[800]),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.isPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.pink,
                                    ),
                                    onPressed: () {
                                      controller.isPasswordVisible.value =
                                          !controller.isPasswordVisible.value;
                                    },
                                  ),
                                ),
                                style: GoogleFonts.dmSans(),
                                validator: controller.validatePassword,
                                obscureText:
                                    !controller.isPasswordVisible.value,
                              )),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => controller.submitForm(_formKey),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink[400],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                textStyle: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text("Sign Up"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.dmSans(),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.signin);
                      },
                      child: Text(
                        "Login",
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
      ),
    );
  }
}
