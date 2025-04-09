import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  runApp(const NotificationApp());
}

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cycle Tracker',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Roboto'),
      home: const HomeScreen(), // Ganti ke HomeScreen sebagai halaman utama
      routes: {'/notifications': (context) => const NotificationsScreen()},
    );
  }
}

// Tambahkan HomeScreen sebagai halaman utama
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Lihat Notifikasi'),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'upcoming',
      'message': 'Your new menstrual cycle will start in 2 days.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'additionalText':
          'Get ready and don\'t forget to mark it on your calendar!',
    },
    {
      'type': 'started',
      'message': 'Hey, your period just started! 🌟',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'additionalText':
          'Take it easy today, and don\'t forget to mark it on your calendar.',
    },
  ];

  @override
  void initState() {
    super.initState();
    timeago.setDefaultLocale('en');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Tombol back (<)
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            ..._notifications.map((notification) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationCard(
                    type: notification['type'],
                    message: notification['message'],
                    additionalText: notification['additionalText'],
                  ),
                  const SizedBox(height: 8),
                  _buildTimeAgoText(notification['timestamp']),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String type,
    required String message,
    required String additionalText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        type == 'started' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(additionalText, style: const TextStyle(fontSize: 16)),
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
