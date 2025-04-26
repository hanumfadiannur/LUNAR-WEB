import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunar/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful! Please login.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // After successful registration, navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Registration failed';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                // Moon-inspired logo
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
                  style: GoogleFonts.comfortaa(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.pink[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sync with your rhythm',
                  style: GoogleFonts.comfortaa(
                    color: Colors.pink[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Form
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
                            style: GoogleFonts.comfortaa(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.pink[800],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              prefixIcon:
                                  const Icon(Icons.person, color: Colors.pink),
                              labelStyle: GoogleFonts.comfortaa(
                                color: Colors.pink[800],
                              ),
                            ),
                            style: GoogleFonts.comfortaa(),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.pink),
                              labelStyle: GoogleFonts.comfortaa(
                                color: Colors.pink[800],
                              ),
                            ),
                            style: GoogleFonts.comfortaa(),
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.pink),
                              labelStyle: GoogleFonts.comfortaa(
                                color: Colors.pink[800],
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.pink,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            style: GoogleFonts.comfortaa(),
                            validator: _validatePassword,
                            obscureText: !_isPasswordVisible,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink[400],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                textStyle: GoogleFonts.comfortaa(
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
                      style: GoogleFonts.comfortaa(),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.comfortaa(
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

/*import 'package:firebase_auth/firebase_auth.dart';
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
*/
