import 'package:flutter/material.dart';
import 'models/patient.dart'; // Asegúrate de tener la importación correcta

class AddPatientDialog extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController epsController = TextEditingController();
  final TextEditingController doctorController = TextEditingController();

  AddPatientDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Nuevo Paciente'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField('Nombre', nameController),
            _buildTextField('Dirección', addressController),
            _buildTextField('Teléfono', phoneController),
            _buildTextField('Correo Electrónico', emailController),
            _buildTextField('EPS', epsController),
            _buildTextField('Médico', doctorController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cerrar el diálogo
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            // Crear un nuevo paciente y pasarlo de vuelta a la pantalla principal
            final newPatient = Patient(
              name: nameController.text,
              address: addressController.text,
              phone: phoneController.text,
              email: emailController.text,
              eps: epsController.text,
              doctor: doctorController.text,
              eyePressureMeasurements: []
            );
            Navigator.pop(context, newPatient);
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
        ),
      ),
    );
  }
}
