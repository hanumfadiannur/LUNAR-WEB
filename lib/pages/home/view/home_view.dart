import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lunar/components/periodchart.dart';
import 'package:lunar/components/sidebarmenu.dart';
import 'package:lunar/pages/content_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lunar/routes/app_routes.dart';
import '../controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
        Obx(() {
          return Text(
            'Hello, ${controller.fullname.value}!',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          );
        }),
        const Spacer(),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.notification),
          icon: const Icon(Icons.notifications, color: Colors.black),
        ),
        const SizedBox(width: 10),
        // Display Fullname here
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
                child: Text(controller.formattedDate,
                    style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Text(controller.currentCycleStatus.value,
              style: GoogleFonts.dmSans(
                  fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.currentCycleMessage.value,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Color(0xFFF45F69),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNavigationIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton('lib/images/Calender Icon.svg', 'Calendar',
            () => Get.toNamed(AppRoutes.calendar)),
        const SizedBox(width: 20),
        _buildIconButton('lib/images/History Icon.svg', 'History',
            () => Get.toNamed(AppRoutes.history)),
        const SizedBox(width: 20),
        _buildIconButton('lib/images/Content Icon.svg', 'Content',
            () => Get.toNamed(AppRoutes.content)),
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
          onTap: () => controller.navigateTo(const ContentPage()),
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
            itemCount: controller.contentList.length,
            itemBuilder: (context, index) {
              var content = controller.contentList[index];
              return _buildContentCard(content);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return GestureDetector(
      onTap: () => controller.navigateTo(const ContentPage()),
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
}
