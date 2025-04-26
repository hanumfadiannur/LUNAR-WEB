import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controller/notification_controller.dart';
import 'package:lunar/components/sidebarmenu.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    timeago.setDefaultLocale('en');

    return Scaffold(
      drawer: const SidebarMenu(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (controller.notifications.isEmpty) {
              return const Center(child: Text('No notifications.'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  ...controller.notifications.map((notification) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationCard(notification),
                        const SizedBox(height: 8),
                        _buildTimeAgoText(notification['timestamp']),
                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final message = notification['message'];
    final additionalText = notification['additionalText'];
    final type = notification['type'];

    Color backgroundColor;
    switch (type) {
      case 'started':
        backgroundColor = Colors.pink[100]!;
        break;
      case 'upcoming':
        backgroundColor = const Color(0xFFFFCCCF);
        break;
      case 'delayed':
        backgroundColor = Colors.red[100]!;
        break;
      case 'finished':
        backgroundColor = Colors.green[100]!;
        break;
      default:
        backgroundColor = Colors.grey[200]!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(additionalText, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTimeAgoText(DateTime timestamp) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 30)),
      builder: (context, snapshot) {
        return Text(
          timeago.format(timestamp),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        );
      },
    );
  }
}
