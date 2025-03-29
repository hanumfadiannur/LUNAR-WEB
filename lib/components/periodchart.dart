import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PeriodHistogram extends StatelessWidget {
  const PeriodHistogram({super.key});

  @override
  Widget build(BuildContext context) {
    List<int> periodDays = [7, 5, 6, 4, 8, 6, 7, 5, 6, 4, 9, 7];

    double screenWidth = MediaQuery.of(context).size.width;
    double barWidth = screenWidth / 30; // Lebar batang dinamis

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
                    sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(),
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                  topTitles: AxisTitles(
                    // Hapus title atas
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    // Hapus title kanan
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
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
    if (value <= 3) return Colors.green;
    if (value <= 6) return const Color(0xFFFFCCCF);
    if (value <= 9) return const Color(0xFFF45F69);
    return Colors.red;
  }
}
