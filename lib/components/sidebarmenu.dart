import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lunar/routes/app_routes.dart'; // Import ProfilePage

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.exists ? userDoc['fullname'] ?? "User" : "User";
    }
    return "User";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<String>(
            future: getUserName(),
            builder: (context, snapshot) {
              String displayName = snapshot.data ?? "User";
              return UserAccountsDrawerHeader(
                accountName:
                    Text(displayName, style: TextStyle(color: Colors.black)),
                accountEmail: Text(user?.email ?? "No Email",
                    style: TextStyle(color: Colors.black)),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.profile);
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFFF45F69),
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                ),
                decoration: const BoxDecoration(color: Color(0xFFFFCCCF)),
                onDetailsPressed: () {
                  Get.toNamed(AppRoutes.profile);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text("Home"),
            onTap: () {
              Get.toNamed(AppRoutes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.black),
            title: const Text("History"),
            onTap: () {
              Get.toNamed(AppRoutes.history);
            },
          ),
          ListTile(
            leading: const Icon(Icons.article, color: Colors.black),
            title: const Text("Content"),
            onTap: () {
              Get.toNamed(AppRoutes.content);
            },
          ),
        ],
      ),
    );
  }
}
