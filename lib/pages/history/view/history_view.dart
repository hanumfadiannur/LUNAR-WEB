import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunar/components/sidebarmenu.dart';
import 'package:lunar/routes/app_routes.dart';
import '../controller/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarMenu(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 15),
              Text(
                "Cycle History",
                style: GoogleFonts.dmSans(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Obx(() {
                return Text(
                  "Hello, ${controller.fullname.value}!",
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                );
              }),
              const SizedBox(height: 10),
              _buildCycleHistory(),
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
          onPressed: () => Get.toNamed(AppRoutes.notification),
          icon: const Icon(Icons.notifications, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildCycleHistory() {
    return Obx(() {
      if (controller.cycleHistory.isEmpty) {
        return const Text("No cycle history found.");
      }

      return Column(
        children: controller.cycleHistory.map((cycle) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHistoryCard(
                Icons.calendar_month,
                "Month: ${cycle['month']}",
                "Started on ${cycle['startDate']}",
              ),
              _buildHistoryCard(
                Icons.water_drop,
                "Period Length",
                cycle['periodLength'],
              ),
              _buildHistoryCard(
                Icons.access_time,
                "Days Ago",
                cycle['daysAgo'],
              ),
              if (cycle['notes'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Notes: ${cycle['notes'].entries.map((e) => "${e.key}: ${e.value}").join(", ")}",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              const Divider(thickness: 1),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _buildHistoryCard(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.red.shade400),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
