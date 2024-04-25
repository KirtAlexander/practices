import 'package:glaucoma_release/models/eye_pressure.dart';

class Patient {
  String name;
  String address;
  String phone;
  String email;
  String eps;
  String doctor;
  List<EyePressureMeasurement> eyePressureMeasurements; // Lista de mediciones de presión intraocular

  Patient({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.eps,
    required this.doctor,
    this.eyePressureMeasurements = const [],
  });

double getAverageLeftEyePressure() {
    if (eyePressureMeasurements.isEmpty) {
      return 0.0;
    }

    double sum = 0.0;
    for (var measurement in eyePressureMeasurements) {
      sum += measurement.leftEye;
    }

    return sum / eyePressureMeasurements.length;
  }

  double getAverageRightEyePressure() {
    if (eyePressureMeasurements.isEmpty) {
      return 0.0;
    }

    double sum = 0.0;
    for (var measurement in eyePressureMeasurements) {
      sum += measurement.rightEye;
    }

    return sum / eyePressureMeasurements.length;
  }
}
