// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lunar/pages/login_page.dart';
// import 'home_page.dart';

// class AuthPage extends StatelessWidget {
//   const AuthPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             //user is logged in
//             if (snapshot.hasData) {
//               return HomePage();
//             }

//             //user is Not logged in
//             else {
//               return LoginPage();
//             }
//           }),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lunar/pages/home/binding/home_binding.dart';
import 'package:lunar/pages/home/view/home_view.dart';
import 'package:lunar/pages/signin/binding/signin_binding.dart';
import 'package:lunar/pages/signin/view/signin_view.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            // Inject HomeBinding sebelum buka HomeView
            HomeBinding().dependencies();
            return const HomeView();
          } else {
            // Inject SignInBinding sebelum buka SignInView
            SignInBinding().dependencies();
            return const SignInView();
          }
        },
      ),
    );
  }
}
