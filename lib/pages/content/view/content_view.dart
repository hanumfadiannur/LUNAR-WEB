import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lunar/components/sidebarmenu.dart';
import '../../../routes/app_routes.dart';
import '../controller/content_controller.dart';

class ContentView extends StatelessWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContentController>();

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
                    onPressed: () => Get.toNamed(AppRoutes.notification),
                    icon: const Icon(Icons.notifications, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Content",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Obx(() => Column(
                    children:
                        List.generate(controller.contentList.length, (index) {
                      final content = controller.contentList[index];
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
                            GestureDetector(
                              onTap: () => controller.toggleContent(index),
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
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
