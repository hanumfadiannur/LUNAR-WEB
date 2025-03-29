import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lunar/components/periodchart.dart';
import 'package:lunar/components/sidebarmenu.dart';
import 'package:lunar/pages/calender_page.dart';
import 'package:lunar/pages/content_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunar/pages/history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final String todayDate = DateFormat("d MMM").format(DateTime.now());

  final List<Map<String, dynamic>> contentList = [
    {
      "title": "What’s 'Normal'? Menstrual Cycle Length and Variation",
      "description":
          "A 'normal' menstrual cycle typically ranges from 21 to 35 days, with an average of 28 days. However, variations of 2–7 days are common...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Signs Your Period is Coming: Common PMS Symptoms",
      "description":
          "Common PMS symptoms include mood swings, bloating, breast tenderness, fatigue, and acne. These usually appear 1–2 weeks before menstruation...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Heavy vs. Light Flow: What’s Considered Normal?",
      "description":
          "Menstrual flow can vary from cycle to cycle. A normal flow ranges between 30–80 ml of blood per period. If you need to change your pad/tampon...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Period Pain: When Should You Be Concerned?",
      "description":
          "Mild to moderate period cramps are common due to uterine contractions. However, severe pain that interferes with daily activities...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Irregular Periods: When Should You Worry?",
      "description":
          "If your periods are consistently irregular, extremely short (less than 21 days), or too long (more than 35 days), it may indicate an issue...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "What Causes Missed or Skipped Periods?",
      "description":
          "Missing a period can happen for many reasons beyond pregnancy. Some common causes include high stress levels, extreme weight loss or gain...",
      "expanded": false,
      "color": const Color(0xFFFFE4E6),
    },
  ];

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 15),
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildNavigationIcons(),
              const SizedBox(height: 10),
              _buildContentSection(),
              const SizedBox(height: 20),
              PeriodHistogram(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: signUserOut,
          icon: const Icon(Icons.notifications, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today",
                  style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(todayDate,
                    style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Day 1",
              style: GoogleFonts.dmSans(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            "Your period has started, get ready to face it comfortably!",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Color(0xFFF45F69), // Warna ditentukan dalam TextStyle
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton('lib/images/Calender Icon.svg', 'Calendar',
            () => _navigateTo(CalendarPage())),
        const SizedBox(width: 20), // Mengurangi jarak antar ikon
        _buildIconButton('lib/images/History Icon.svg', 'History',
            () => _navigateTo(HistoryPage())),
        const SizedBox(width: 20),
        _buildIconButton('lib/images/Content Icon.svg', 'Content',
            () => _navigateTo(const ContentPage())),
      ],
    );
  }

  Widget _buildIconButton(String assetPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(assetPath),
          const SizedBox(height: 8),
          Text(
            label,
            style:
                GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _navigateTo(const ContentPage()),
          child: Text(
            'Content',
            style:
                GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: contentList.length,
            itemBuilder: (context, index) {
              var content = contentList[index];
              return _buildContentCard(content);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return GestureDetector(
      onTap: () => _navigateTo(const ContentPage()),
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: content["color"],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Text(content["title"],
                  style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}


/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lunar/components/periodchart.dart';
import 'package:lunar/components/sidebarmenu.dart';
import 'package:lunar/pages/calender_page.dart';
import 'package:lunar/pages/content_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final String todayDate = DateFormat("d MMM").format(DateTime.now());

  final List<Map<String, dynamic>> contentList = [
    {
      "title": "What’s 'Normal'? Menstrual Cycle Length and Variation",
      "description":
          "A 'normal' menstrual cycle typically ranges from 21 to 35 days...",
      "color": const Color(0xFFFFE4E6),
    },
    {
      "title": "Signs Your Period is Coming: Common PMS Symptoms",
      "description":
          "Common PMS symptoms include mood swings, bloating, breast tenderness...",
      "color": const Color(0xFFFFE4E6),
    },
  ];

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatusCard(),
              const SizedBox(height: 25),
              _buildNavigationIcons(),
              const SizedBox(height: 10),
              _buildContentSection(),
              const SizedBox(height: 20),
              PeriodHistogram(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: signUserOut,
          icon: const Icon(Icons.notifications, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today",
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(todayDate,
                    style: const GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Day 1",
              style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
              "Your period has started, get ready to face it comfortably!",
              style: GoogleFonts.dmSans(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNavigationIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton('lib/images/Calender Icon.svg', 'Calendar',
            () => _navigateTo(CalendarPage())),
        _buildIconButton('lib/images/History Icon.svg', 'History', () {}),
        _buildIconButton('lib/images/Content Icon.svg', 'Content',
            () => _navigateTo(const ContentPage())),
      ],
    );
  }

  Widget _buildIconButton(String assetPath, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            SvgPicture.asset(assetPath, width: 100, height: 100),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _navigateTo(const ContentPage()),
          child: const Text(
            'Content',
            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: contentList.length,
            itemBuilder: (context, index) {
              var content = contentList[index];
              return _buildContentCard(content);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return GestureDetector(
      onTap: () => _navigateTo(const ContentPage()),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.91,
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: content["color"],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Text(content["title"],
                  style: const GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
*/