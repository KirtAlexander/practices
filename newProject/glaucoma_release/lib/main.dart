import 'package:flutter/material.dart';
import 'package:glaucoma_release/patient_details.dart';
import 'package:glaucoma_release/add_patient.dart';
import 'package:glaucoma_release/statistics.dart';
import 'models/patient.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
      ),
      home: const HomePage(),
       onGenerateRoute: (settings) {
        if (settings.name == '/statistics') {
          // Extract patients from arguments and pass it to StatisticsPage
          final List<Patient>? patients = settings.arguments as List<Patient>?;
          return MaterialPageRoute(
            builder: (context) => StatisticsPage(patients: patients),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Patient> patients = [
    Patient(
      name: 'Juan Pérez',
      address: 'Calle 123, Ciudad',
      phone: '123456789',
      email: 'juan@example.com',
      eps: 'EPS A',
      doctor: 'Dr. García',
      eyePressureMeasurements: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
      ),
      drawer: _buildDrawer(),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          return _buildPatientCard(patients[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddPatient();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(patient.name),
        subtitle: Text('EPS: ${patient.eps} - Médico: ${patient.doctor}'),
        onTap: () {
          _navigateToPatientDetails(patient);
        },
      ),
    );
  }

  void _navigateToPatientDetails(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsPage(patient),
      ),
    );
  }

  void _navigateToAddPatient() async {
    final newPatient = await showDialog<Patient>(
      context: context,
      builder: (BuildContext context) {
        return AddPatientDialog();
      },
    );

    if (newPatient != null) {
      setState(() {
        patients.add(newPatient);
      });
    }
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Pacientes'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Estadísticas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/statistics',
                  arguments: patients );
            },
          ),
        ],
      ),
    );
  }
}
