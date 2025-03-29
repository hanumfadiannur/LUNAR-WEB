import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lunar/components/sidebarmenu.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final user = FirebaseAuth.instance.currentUser!;

  // List warna yang diperbolehkan
  final List<Color> allowedColors = [
    const Color(0xFF79A9DF),
    const Color(0xFFFF689B),
    const Color(0xFFD8FFB9),
    const Color(0xFFFE9DA5),
  ];

  // Konten dummy
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

  // Toggle content expansion
  void toggleContent(int index) {
    setState(() {
      contentList[index]["expanded"] = !contentList[index]["expanded"];
    });
  }

  // Sign out method
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
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Spacer(),
                  IconButton(
                    onPressed: signUserOut,
                    icon: const Icon(Icons.notifications, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Content Section
              const Text(
                "Content",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // List of Content
              Column(
                children: List.generate(contentList.length, (index) {
                  final content = contentList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: content["color"],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content["title"],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),

                        // Look Content / Hide Content (toggle expansion)
                        GestureDetector(
                          onTap: () => toggleContent(index),
                          child: Text(
                            content["expanded"]
                                ? "Hide content"
                                : "Look content",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        // Expandable content
                        if (content["expanded"]) ...[
                          const SizedBox(height: 10),
                          Text(
                            content["description"],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
