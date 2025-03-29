import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunar/components/mybutton.dart';
import 'package:lunar/components/mytextfield.dart';
import 'package:lunar/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  DateTime? lastPeriodDate;

  void pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        lastPeriodDate = pickedDate;
      });
    }
  }

  void signUpUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      showCustomDialog('Error', 'Passwords do not match!');
      return;
    }
    if (lastPeriodDate == null) {
      showCustomDialog('Error', 'Please select your last period date.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await createUserProfile(userCredential.user!.uid);

      Navigator.pop(context); // Close loading dialog

      // Redirect ke LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showCustomDialog(
          'Registration Failed', e.message ?? 'An error occurred.');
    }
  }

  Future<void> createUserProfile(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'email': emailController.text,
      'name': nameController.text,
      'cycleLength': 28, // Default cycle length
      'periodLength': 5, // Default period length
      'lastPeriodDate': DateFormat('yyyy-MM-dd').format(lastPeriodDate!),
      'createdAt': Timestamp.now(),
    });

    // Simpan first period record
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('period_records')
        .add({
      'periodDate': DateFormat('yyyy-MM-dd').format(lastPeriodDate!),
      'periodLength': 5, // Default period length
      'notes': '',
      'createdAt': Timestamp.now(),
    });
  }

  void showCustomDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxTextFieldWidth = screenWidth > 500 ? 400 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(Icons.person_add, size: 100),
                const SizedBox(height: 50),
                Text("Create Your Account",
                    style: TextStyle(color: Colors.grey[800], fontSize: 20)),
                const SizedBox(height: 25),

                // Input Name
                SizedBox(
                  width: maxTextFieldWidth,
                  child: MyTextField(
                    controller: nameController,
                    hintText: 'Name',
                    obscureText: false,
                  ),
                ),

                const SizedBox(height: 10),

                // Input Email
                SizedBox(
                  width: maxTextFieldWidth,
                  child: MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                ),

                const SizedBox(height: 10),

                // Input Password
                SizedBox(
                  width: maxTextFieldWidth,
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: maxTextFieldWidth,
                    child: GestureDetector(
                      onTap: pickDate,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                lastPeriodDate == null
                                    ? "Select Last Period Date"
                                    : DateFormat('yyyy-MM-dd')
                                        .format(lastPeriodDate!),
                                style: TextStyle(color: Colors.black),
                                overflow: TextOverflow
                                    .ellipsis, // Prevents text overflow
                              ),
                            ),
                            Icon(Icons.calendar_today, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sign Up Button
                SizedBox(
                  width: maxTextFieldWidth,
                  child: MyButton(
                    onTap: signUpUser,
                    text: 'Sign Up',
                  ),
                ),

                const SizedBox(height: 20),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(color: Colors.grey[700])),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(' Login!',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
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
