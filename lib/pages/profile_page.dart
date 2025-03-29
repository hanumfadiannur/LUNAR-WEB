import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunar/components/sidebarmenu.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String name = "User";
  String email = "user@example.com";
  int cycleLength = 0;
  int periodLength = 0;
  DateTime? lastPeriodDate; // Gunakan DateTime

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Ambil data pengguna dari Firestore
  Future<void> _fetchUserData() async {
    if (user != null) {
      setState(() {
        email = user!.email ?? "user@example.com";
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc['name'] ?? "User";
            cycleLength = userDoc['cycleLength'] ?? 0;
            periodLength = userDoc['periodLength'] ?? 0;

            // Konversi lastPeriodDate ke DateTime jika ada
            String? lastPeriodStr = userDoc['lastPeriodDate'];
            if (lastPeriodStr != null) {
              lastPeriodDate = DateTime.parse(lastPeriodStr);
            }
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              width: 380,
              decoration: BoxDecoration(
                color: const Color(0xFFFBC5CA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFF45F69),
                      child: Icon(Icons.person, size: 60, color: Colors.black)),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Cycle Length: $cycleLength days",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Period Length: $periodLength days",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (lastPeriodDate != null) // Tampilkan hanya jika ada data
                    Text(
                      "Last Period: ${DateFormat('yyyy-MM-dd').format(lastPeriodDate!)}",
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Options
            _buildProfileOption(
                title: "Edit Profile", icon: Icons.person, onTap: () {}),
            _buildProfileOption(
                title: "Settings", icon: Icons.settings, onTap: () {}),
            _buildProfileOption(
                title: "More Options", icon: Icons.more_horiz, onTap: () {}),
            const SizedBox(height: 20),

            // Tombol Logout
            _buildProfileOption(
              title: "Log Out",
              icon: Icons.logout,
              color: Colors.red,
              onTap: signUserOut,
            ),
          ],
        ),
      ),
    );
  }

  // Sign out method dengan navigasi ke login
  void signUserOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, '/login'); // Pastikan route sudah ada
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  Widget _buildProfileOption({
    required String title,
    required IconData icon,
    Color color = Colors.black,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.dmSans(fontSize: 16, color: color),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
