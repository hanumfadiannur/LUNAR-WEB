import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PeriodHistogram extends StatelessWidget {
  const PeriodHistogram({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final idToken = box.read('idToken');

    return FutureBuilder<List<int>>(
      future: fetchPeriodDataFromApi(idToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        } else {
          List<int> periodDays = snapshot.data!;
          double screenWidth = MediaQuery.of(context).size.width;
          double barWidth = screenWidth / 30;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Number of Period Days in Year",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: screenWidth > 600 ? 250 : 180,
                  width: screenWidth,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      barGroups: _getBarGroups(periodDays, barWidth),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec'
                              ];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  List<BarChartGroupData> _getBarGroups(List<int> periodDays, double barWidth) {
    return List.generate(
      periodDays.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: periodDays[index].toDouble(),
            color: getHeatmapColor(periodDays[index]),
            width: barWidth,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 10,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Color getHeatmapColor(int value) {
    if (value <= 3) return const Color.fromARGB(255, 219, 175, 202);
    if (value <= 6) return const Color(0xFFFFCCCF);
    if (value <= 9) return const Color(0xFFF45F69);
    return Colors.red;
  }

  Future<List<int>> fetchPeriodDataFromApi(String idToken) async {
    List<int> periodDays = [];

    try {
      var response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/api/user/cycle-history'), // Ganti 10.0.2.2 kalau emulator
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> history = decoded['history'] ?? [];

        for (int monthIndex = 1; monthIndex <= 12; monthIndex++) {
          final monthStr = monthIndex.toString().padLeft(2, '0');

          // Cari data bulan yang sesuai
          final monthData = history.firstWhere(
            (element) => element['month'] == monthStr,
            orElse: () => null,
          );

          if (monthData != null && monthData['periodLength'] != null) {
            // Contoh format periodLength: "6 days"
            final periodLengthStr = monthData['periodLength'] as String;
            final periodLengthNum =
                int.tryParse(periodLengthStr.split(' ').first) ?? 0;
            periodDays.add(periodLengthNum);
          } else {
            periodDays.add(0);
          }
        }
      } else {
        throw Exception('Failed to load cycle history');
      }
    } catch (e) {
      print('Error loading cycle history: $e');
      // Kalau error, return list 0 untuk 12 bulan
      return List.filled(12, 0);
    }

    return periodDays;
  }
}
