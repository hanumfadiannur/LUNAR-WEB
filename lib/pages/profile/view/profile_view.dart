import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lunar/components/sidebarmenu.dart';
import 'package:lunar/pages/profile/controller/profile_controller.dart';
import 'package:lunar/routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

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

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController();
    nameController.text = controller.name.value; // Menampilkan nama saat ini

    Get.defaultDialog(
      title: "Edit Full Name",
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter your full name"),
          ),
        ],
      ),
      onCancel: () {},
      onConfirm: () {
        controller.updateFullName(nameController.text);
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarMenu(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Container(
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
                            child: Icon(Icons.person,
                                size: 60, color: Colors.black)),
                        const SizedBox(height: 10),
                        Text(controller.name.value,
                            style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text(controller.email.value,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: Colors.black54)),
                        const SizedBox(height: 10),
                        Text("Cycle Length: ${controller.cycleLength} days",
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        Text("Period Length: ${controller.periodLength} days",
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        if (controller.lastPeriodDate.value != null)
                          Text(
                            "Last Period: ${DateFormat('yyyy-MM-dd').format(controller.lastPeriodDate.value!)}",
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87),
                          ),
                      ],
                    ),
                  );
                }
              }),
              const SizedBox(height: 20),
              _buildProfileOption(
                title: "Edit Full Name",
                icon: Icons.edit,
                onTap: _showEditNameDialog,
              ),
              _buildProfileOption(
                title: "Log Out",
                icon: Icons.logout,
                color: Colors.red,
                onTap: controller.signUserOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
