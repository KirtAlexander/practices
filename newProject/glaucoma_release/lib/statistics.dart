import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/patient.dart';


class StatisticsPage extends StatelessWidget {
  final List<Patient>? patients;

  const StatisticsPage({Key? key, this.patients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Presión Ocular de Pacientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: _buildPieChartSections(patients),
                ),
              ),
            ),
          
          ]
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<Patient>? patients) {
    final List<PieChartSectionData> sections = [];

    for (int index = 0; index < (patients?.length ?? 0); index++) {
      final double leftEyePressure = patients![index].getAverageLeftEyePressure();
      final double rightEyePressure = patients[index].getAverageRightEyePressure();

      sections.add(
        PieChartSectionData(
          color: index.isEven ? Colors.blueAccent : Colors.redAccent,
          value: leftEyePressure + rightEyePressure,
          title: '${(leftEyePressure + rightEyePressure).toStringAsFixed(1)} mmHg',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
      );
    }

    return sections;
  }


}