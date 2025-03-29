import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String startDate = "";
  String periodLength = "";
  String daysAgo = "";

  @override
  void initState() {
    super.initState();
    fetchCycleHistory();
  }

  void fetchCycleHistory() {
    DateTime startDateTime = DateTime(2024, 12, 17); // Contoh data
    int periodDays = 7;

    DateTime today = DateTime.now();
    int daysDifference = today.difference(startDateTime).inDays;

    setState(() {
      startDate =
          "${startDateTime.day} ${DateFormat('MMMM').format(startDateTime)}";
      periodLength = "$periodDays days";
      daysAgo = "$daysDifference days ago";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //const SizedBox(height: 15),
            const Text(
              "Hello, Luna!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text(
              "Cycle History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildCycleHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleHistory() {
    return Column(
      children: [
        _buildHistoryCard(Icons.access_time, "Started $startDate", daysAgo),
        _buildHistoryCard(
          Icons.water_drop,
          "Period Length: $periodLength",
          "Normal",
        ),
      ],
    );
  }

  Widget _buildHistoryCard(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
