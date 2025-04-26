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
import 'package:lunar/routes/app_routes.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while waiting for connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Only navigate if connection is done and no error
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          // Delay navigation to avoid calling it during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (user == null) {
              Get.offAllNamed(AppRoutes.signin);
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          });
        }

        // Return a blank scaffold while waiting
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}
