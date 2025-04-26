import '../screens/prescription/history_screen.dart';
import 'medication.dart';

class Prescription {
  final String id;
  final String imagePath;
  final DateTime dateScanned;
  final String recognizedText;
  final String doctorName;
  final List<Medication> medications;

  Prescription({
    required this.id,
    required this.imagePath,
    required this.dateScanned,
    required this.recognizedText,
    required this.doctorName,
    required this.medications,
  });
}