import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodHistogram extends StatelessWidget {
  const PeriodHistogram({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final String year = DateFormat('yyyy').format(DateTime.now());

    return FutureBuilder<List<int>>(
      future: fetchPeriodData(userId, year),
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

  Future<List<int>> fetchPeriodData(String userId, String year) async {
    List<int> periodDays = [];

    for (int monthIndex = 1; monthIndex <= 12; monthIndex++) {
      final month = monthIndex.toString().padLeft(2, '0');

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('periods')
            .doc(year)
            .collection(month)
            .doc('active')
            .get();

        if (doc.exists) {
          final data = doc.data();
          final periodLength = data?['periodLength'];
          periodDays.add(periodLength is int ? periodLength : 0);
        } else {
          periodDays.add(0);
        }
      } catch (e) {
        periodDays.add(0);
      }
    }

    return periodDays;
  }
}
