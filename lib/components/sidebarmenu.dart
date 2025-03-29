import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunar/pages/content_page.dart';
import 'package:lunar/pages/history_page.dart';
import 'package:lunar/pages/home_page.dart';
import 'package:lunar/pages/profile_page.dart'; // Import ProfilePage

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.exists ? userDoc['name'] ?? "User" : "User";
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFFF45F69),
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                ),
                decoration: const BoxDecoration(color: Color(0xFFFFCCCF)),
                onDetailsPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text("Home"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.black),
            title: const Text("History"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article, color: Colors.black),
            title: const Text("Content"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContentPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
