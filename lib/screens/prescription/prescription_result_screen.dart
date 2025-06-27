import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrescriptionResultScreen extends StatelessWidget {
  final File image;
  final Map<String, dynamic> responseData;

  const PrescriptionResultScreen({
    Key? key,
    required this.image,
    required this.responseData,
  }) : super(key: key);

  // Helper function to safely convert any value to string
  String safeToString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  // Helper function to safely get double value
  double safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method to get appropriate icon based on medication form
  IconData _getFormIcon(String form) {
    switch (form.toLowerCase()) {
      case 'tablet':
        return Icons.medication;
      case 'capsule':
        return Icons.medication_liquid;
      case 'powder':
        return Icons.scatter_plot;
      case 'cream':
        return Icons.colorize;
      case 'inhaler':
        return Icons.air;
      case 'nasal spray':
        return FontAwesomeIcons.sprayCan;
      default:
        return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final medications = responseData['medications'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Results'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF5170FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5170FF),
              Color(0xFF1E3A8A),
            ],
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPrescriptionHeader(),
                          const SizedBox(height: 24),
                          _buildOriginalImage(),
                          const SizedBox(height: 24),
                          _buildRecognizedTextSection(),
                          const SizedBox(height: 24),
                          _buildMedicationsSection(medications),
                          const SizedBox(height: 24),
                          _buildProcessingInfo(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.document_scanner,
              color: const Color(0xFF5170FF),
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'prescription_analysis'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  Text(
                    'processed_on'.tr() + ' ${DateFormat('MMMM dd, yyyy - HH:mm').format(DateTime.now())}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 32, thickness: 2),
      ],
    );
  }

  Widget _buildOriginalImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'original_prescription'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            image,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildRecognizedTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recognized_text'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            safeToString(responseData['recognized_text']) == 'N/A'
                ? 'no_text_recognized'.tr()
                : safeToString(responseData['recognized_text']),
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsSection(List<dynamic> medications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'detected_medications'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        if (medications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Text(
              'no_medications_detected'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.orange[800],
              ),
            ),
          )
        else
          ...medications.map((medication) => _buildMedicationCard(medication as Map<String, dynamic>)).toList(),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final confidence = safeToDouble(medication['confidence']);
    final medicationName = safeToString(medication['name']);
    final dosage = safeToString(medication['dosage']);
    final frequency = safeToString(medication['frequency']);
    final form = safeToString(medication['form']);  // Added form field
    final alternatives = safeToString(medication['alternatives']);
    final conflicts = safeToString(medication['conflicts']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5170FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFormIcon(form),  // Dynamic icon based on form
                color: const Color(0xFF5170FF),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicationName == 'N/A' ? 'unknown_medication'.tr() : medicationName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    if (form != 'N/A')
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5170FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF5170FF).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          form.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5170FF),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(confidence),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(confidence * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMedicationDetail('form'.tr(), form),  // Added form display
          _buildMedicationDetail('dosage'.tr(), dosage),
          _buildMedicationDetail('frequency'.tr(), frequency),
          if (alternatives != 'N/A' && alternatives != 'No alternatives available')
            _buildMedicationDetail('alternatives'.tr(), alternatives),
          if (conflicts != 'N/A' && conflicts != 'No conflicts listed')
            _buildMedicationDetail('conflicts'.tr(), conflicts),
        ],
      ),
    );
  }

  Widget _buildMedicationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'processing_information'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'prescription_id'.tr() + ': ${safeToString(responseData['prescription_id'])}',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'processed_at'.tr() + ': ${safeToString(responseData['processed_at'])}',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.history),
            label: Text('view_history'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add_a_photo),
            label: Text('scan_another'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
