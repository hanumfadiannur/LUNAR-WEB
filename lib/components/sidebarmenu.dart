import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:lunar/routes/app_routes.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  Future<Map<String, dynamic>> fetchUserData() async {
    final storage = GetStorage();
    final idToken = storage.read('idToken');
    if (idToken == null) {
      throw Exception("No token found");
    }

    var response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user/cycle-status'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return UserAccountsDrawerHeader(
                  accountName:
                      Text('Loading...', style: TextStyle(color: Colors.black)),
                  accountEmail: Text('', style: TextStyle(color: Colors.black)),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Color(0xFFF45F69),
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  decoration: BoxDecoration(color: Color(0xFFFFCCCF)),
                );
              } else if (snapshot.hasError) {
                return UserAccountsDrawerHeader(
                  accountName:
                      Text('User', style: TextStyle(color: Colors.black)),
                  accountEmail: Text('Error loading user',
                      style: TextStyle(color: Colors.black)),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Color(0xFFF45F69),
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  decoration: BoxDecoration(color: Color(0xFFFFCCCF)),
                );
              } else {
                final data = snapshot.data!;
                final fullname = data['fullname'] ?? 'User';
                final email =
                    data['email'] ?? ''; // kalau backend sediain email

                return UserAccountsDrawerHeader(
                  accountName:
                      Text(fullname, style: TextStyle(color: Colors.black)),
                  accountEmail:
                      Text(email, style: TextStyle(color: Colors.black)),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.profile);
                    },
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFF45F69),
                      child: Icon(Icons.person, size: 40, color: Colors.black),
                    ),
                  ),
                  decoration: BoxDecoration(color: Color(0xFFFFCCCF)),
                  onDetailsPressed: () {
                    Get.toNamed(AppRoutes.profile);
                  },
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: Text("Home"),
            onTap: () {
              Get.toNamed(AppRoutes.home);
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: Colors.black),
            title: Text("History"),
            onTap: () {
              Get.toNamed(AppRoutes.history);
            },
          ),
          ListTile(
            leading: Icon(Icons.article, color: Colors.black),
            title: Text("Content"),
            onTap: () {
              Get.toNamed(AppRoutes.content);
            },
          ),
        ],
      ),
    );
  }
}
