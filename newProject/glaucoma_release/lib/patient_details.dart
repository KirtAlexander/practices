import 'package:flutter/material.dart';
import 'package:glaucoma_release/models/eye_pressure.dart';
import 'models/patient.dart'; // Asegúrate de tener la importación correcta

class PatientDetailsPage extends StatefulWidget {
  final Patient? patient;

  const PatientDetailsPage(this.patient, {Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  TextEditingController leftEyeController = TextEditingController();
  TextEditingController rightEyeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Paciente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      widget.patient?.name ?? "N/A",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                              'Dirección: ${widget.patient?.address ?? "N/A"}'),
                          const SizedBox(height: 8),
                          Text('Teléfono: ${widget.patient?.phone ?? "N/A"}'),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Correo Electrónico: ${widget.patient?.email ?? "N/A"}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 8),
                          Text('EPS: ${widget.patient?.eps ?? "N/A"}'),
                          const SizedBox(height: 8),
                          Text('Médico: ${widget.patient?.doctor ?? "N/A"}'),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Nueva Medición:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: leftEyeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Ojo Izquierdo',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: rightEyeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Ojo Derecho',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _addNewMeasurement();
                          },
                          child: const Text('Agregar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.patient?.eyePressureMeasurements != null &&
                        widget.patient!.eyePressureMeasurements.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.patient!.eyePressureMeasurements
                            .map((measurement) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Izquierdo: ${measurement.leftEye} mmHg',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                          'Derecho: ${measurement.rightEye} mmHg'),
                                      
                                    ],
                                  ),
                                ))
                            .toList(),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No hay mediciones registradas.'),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addNewMeasurement() {
  if (leftEyeController.text.isNotEmpty &&
      rightEyeController.text.isNotEmpty) {
    double leftEyeMeasurement = double.parse(leftEyeController.text);
    double rightEyeMeasurement = double.parse(rightEyeController.text);

    setState(() {
      widget.patient?.eyePressureMeasurements.add(
        EyePressureMeasurement(
          leftEye: leftEyeMeasurement,
          rightEye: rightEyeMeasurement,
        ),
      );
      leftEyeController.clear();
      rightEyeController.clear();
    });

    // Agregado: Para forzar la reconstrucción del widget
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {});
    });
  }
}

}
