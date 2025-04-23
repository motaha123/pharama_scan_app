import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _PrescriptionHistoryScreenState createState() => _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<HistoryScreen> {
  List<Prescription> _prescriptions = [];
  List<Prescription> _filteredPrescriptions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.dateDesc;
  FilterOption _currentFilterOption = FilterOption.all;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoading = true;
    });

    // In a real app, you would fetch this data from a database or backend
    // For demo purposes, we'll use some mock data
    await Future.delayed(Duration(milliseconds: 800)); // Simulating network delay

    List<Prescription> mockPrescriptions = [
      Prescription(
        id: '1',
        imagePath: 'assets/images/prescription1.jpg',
        dateScanned: DateTime.now().subtract(Duration(days: 2)),
        recognizedText: 'Amoxicillin 500mg\nTake 1 tablet 3 times daily for 7 days',
        doctorName: 'Dr. Ahmed Hassan',
        status: PrescriptionStatus.filled,
        pharmacy: 'El Ezaby Pharmacy',
        medications: [
          Medication(
            name: 'Amoxicillin',
            dosage: '500mg',
            frequency: '3 times daily',
            duration: '7 days',
          ),
        ],
      ),
      Prescription(
        id: '2',
        imagePath: 'assets/images/prescription2.jpg',
        dateScanned: DateTime.now().subtract(Duration(days: 5)),
        recognizedText: 'Paracetamol 500mg\nTake as needed for pain, max 4 per day',
        doctorName: 'Dr. Sara Mahmoud',
        status: PrescriptionStatus.sentToPharmacy,
        pharmacy: 'Seif Pharmacy',
        medications: [
          Medication(
            name: 'Paracetamol',
            dosage: '500mg',
            frequency: 'As needed',
            duration: 'Max 4 per day',
          ),
        ],
      ),
      Prescription(
        id: '3',
        imagePath: 'assets/images/prescription3.jpg',
        dateScanned: DateTime.now().subtract(Duration(days: 12)),
        recognizedText: 'Vitamin D 1000 IU\nTake 1 tablet daily\nOmega-3 Fish Oil 1000mg\nTake 1 capsule daily',
        doctorName: 'Dr. Mohamed Kamal',
        status: PrescriptionStatus.unprocessed,
        medications: [
          Medication(
            name: 'Vitamin D',
            dosage: '1000 IU',
            frequency: 'Daily',
            duration: 'Ongoing',
          ),
          Medication(
            name: 'Omega-3 Fish Oil',
            dosage: '1000mg',
            frequency: 'Daily',
            duration: 'Ongoing',
          ),
        ],
      ),
      Prescription(
        id: '4',
        imagePath: 'assets/images/prescription4.jpg',
        dateScanned: DateTime.now().subtract(Duration(days: 20)),
        recognizedText: 'Lisinopril 10mg\nTake 1 tablet daily in the morning',
        doctorName: 'Dr. Laila Adel',
        status: PrescriptionStatus.filled,
        pharmacy: 'Roshdy Pharmacy',
        medications: [
          Medication(
            name: 'Lisinopril',
            dosage: '10mg',
            frequency: 'Daily in the morning',
            duration: 'Ongoing',
          ),
        ],
      ),
    ];

    setState(() {
      _prescriptions = mockPrescriptions;
      _applyFiltersAndSort();
      _isLoading = false;
    });
  }

  void _applyFiltersAndSort() {
    // First apply search filter
    if (_searchQuery.isEmpty) {
      _filteredPrescriptions = List.from(_prescriptions);
    } else {
      _filteredPrescriptions = _prescriptions.where((prescription) {
        return prescription.recognizedText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            prescription.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            prescription.medications.any((med) => med.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Then apply status filter
    if (_currentFilterOption != FilterOption.all) {
      PrescriptionStatus statusFilter;
      switch (_currentFilterOption) {
        case FilterOption.filled:
          statusFilter = PrescriptionStatus.filled;
          break;
        case FilterOption.sentToPharmacy:
          statusFilter = PrescriptionStatus.sentToPharmacy;
          break;
        case FilterOption.unprocessed:
          statusFilter = PrescriptionStatus.unprocessed;
          break;
        default:
          statusFilter = PrescriptionStatus.unprocessed;
      }

      _filteredPrescriptions = _filteredPrescriptions.where((p) => p.status == statusFilter).toList();
    }

    // Finally sort the filtered list
    switch (_currentSortOption) {
      case SortOption.dateAsc:
        _filteredPrescriptions.sort((a, b) => a.dateScanned.compareTo(b.dateScanned));
        break;
      case SortOption.dateDesc:
        _filteredPrescriptions.sort((a, b) => b.dateScanned.compareTo(a.dateScanned));
        break;
      case SortOption.doctorAZ:
        _filteredPrescriptions.sort((a, b) => a.doctorName.compareTo(b.doctorName));
        break;
      case SortOption.doctorZA:
        _filteredPrescriptions.sort((a, b) => b.doctorName.compareTo(a.doctorName));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prescription History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5170FF),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
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
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFiltersAndSort();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search prescriptions...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip(FilterOption.all, 'All'),
                    SizedBox(width: 8),
                    _buildFilterChip(FilterOption.filled, 'Filled'),
                    SizedBox(width: 8),
                    _buildFilterChip(FilterOption.sentToPharmacy, 'Sent to Pharmacy'),
                    SizedBox(width: 8),
                    _buildFilterChip(FilterOption.unprocessed, 'Unprocessed'),
                  ],
                ),
              ),

              SizedBox(height: 8),

              // Prescriptions List
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : _filteredPrescriptions.isEmpty
                    ? Center(
                  child: Text(
                    'No prescriptions found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _filteredPrescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = _filteredPrescriptions[index];
                    return _buildPrescriptionCard(prescription);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to scan page
          Navigator.pop(context);
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add_a_photo, color: Color(0xFF1E3A8A)),
      ),
    );
  }

  Widget _buildFilterChip(FilterOption option, String label) {
    return FilterChip(
      selected: _currentFilterOption == option,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _currentFilterOption = selected ? option : FilterOption.all;
          _applyFiltersAndSort();
        });
      },
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: Colors.white,
      checkmarkColor: Color(0xFF1E3A8A),
      labelStyle: GoogleFonts.poppins(
        color: _currentFilterOption == option ? Color(0xFF1E3A8A) : Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () => _showPrescriptionDetails(prescription),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prescription Header with Date and Status
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF5170FF).withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(prescription.dateScanned),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  _buildStatusChip(prescription.status),
                ],
              ),
            ),

            // Prescription Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prescription Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      prescription.imagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[500],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),

                  // Prescription Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${prescription.doctorName}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          prescription.medications.map((m) => m.name).join(', '),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        if (prescription.pharmacy != null && prescription.pharmacy!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.local_pharmacy,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  prescription.pharmacy!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PrescriptionStatus status) {
    Color backgroundColor;
    String label;

    switch (status) {
      case PrescriptionStatus.filled:
        backgroundColor = Colors.green;
        label = 'Filled';
        break;
      case PrescriptionStatus.sentToPharmacy:
        backgroundColor = Colors.orange;
        label = 'Sent';
        break;
      case PrescriptionStatus.unprocessed:
        backgroundColor = Colors.grey;
        label = 'New';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showPrescriptionDetails(Prescription prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF5170FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prescription Details',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      _buildStatusChip(prescription.status),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Scanned on ${DateFormat('MMMM dd, yyyy').format(prescription.dateScanned)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Information
                    _buildDetailSection(
                      title: 'Doctor',
                      content: prescription.doctorName,
                      icon: Icons.person,
                    ),
                    Divider(),

                    // Pharmacy Information (if any)
                    if (prescription.pharmacy != null && prescription.pharmacy!.isNotEmpty) ...[
                      _buildDetailSection(
                        title: 'Pharmacy',
                        content: prescription.pharmacy!,
                        icon: Icons.local_pharmacy,
                      ),
                      Divider(),
                    ],

                    // Medications
                    Text(
                      'Medications',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Medication Cards
                    ...prescription.medications.map((medication) => _buildMedicationCard(medication)),

                    SizedBox(height: 24),

                    // Original Prescription Image
                    Text(
                      'Original Prescription',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        prescription.imagePath,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[500],
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // Recognized Text
                    Text(
                      'Recognized Text',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        prescription.recognizedText,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Share Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implement share functionality
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Prescription shared'))
                        );
                      },
                      icon: Icon(Icons.share),
                      label: Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF1E3A8A),
                        side: BorderSide(color: Color(0xFF1E3A8A)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),

                  // Send to Pharmacy Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: prescription.status == PrescriptionStatus.unprocessed
                          ? () {
                        // Navigate to pharmacy locator
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/pharmacy_locator');
                      }
                          : null,
                      icon: Icon(Icons.local_pharmacy),
                      label: Text('Send to Pharmacy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF5170FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF5170FF),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Color(0xFF5170FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.name,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: 8),
          _buildMedicationDetail('Dosage', medication.dosage),
          SizedBox(height: 4),
          _buildMedicationDetail('Frequency', medication.frequency),
          SizedBox(height: 4),
          _buildMedicationDetail('Duration', medication.duration),
        ],
      ),
    );
  }

  Widget _buildMedicationDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label + ':',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            SizedBox(height: 16),
            _buildSortOption(SortOption.dateDesc, 'Newest First'),
            _buildSortOption(SortOption.dateAsc, 'Oldest First'),
            _buildSortOption(SortOption.doctorAZ, 'Doctor (A-Z)'),
            _buildSortOption(SortOption.doctorZA, 'Doctor (Z-A)'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(SortOption option, String label) {
    return RadioListTile<SortOption>(
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      value: option,
      groupValue: _currentSortOption,
      activeColor: Color(0xFF5170FF),
      onChanged: (SortOption? value) {
        if (value != null) {
          setState(() {
            _currentSortOption = value;
            _applyFiltersAndSort();
          });
          Navigator.pop(context);
        }
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter By Status',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            SizedBox(height: 16),
            _buildFilterOption(FilterOption.all, 'All Prescriptions'),
            _buildFilterOption(FilterOption.filled, 'Filled Prescriptions'),
            _buildFilterOption(FilterOption.sentToPharmacy, 'Sent to Pharmacy'),
            _buildFilterOption(FilterOption.unprocessed, 'Unprocessed Prescriptions'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(FilterOption option, String label) {
    return RadioListTile<FilterOption>(
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      value: option,
      groupValue: _currentFilterOption,
      activeColor: Color(0xFF5170FF),
      onChanged: (FilterOption? value) {
        if (value != null) {
          setState(() {
            _currentFilterOption = value;
            _applyFiltersAndSort();
          });
          Navigator.pop(context);
        }
      },
    );
  }
}

// Model Classes

class Prescription {
  final String id;
  final String imagePath;
  final DateTime dateScanned;
  final String recognizedText;
  final String doctorName;
  final PrescriptionStatus status;
  final String? pharmacy;
  final List<Medication> medications;

  Prescription({
    required this.id,
    required this.imagePath,
    required this.dateScanned,
    required this.recognizedText,
    required this.doctorName,
    required this.status,
    this.pharmacy,
    required this.medications,
  });
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });
}

enum PrescriptionStatus {
  unprocessed,
  sentToPharmacy,
  filled,
}

enum SortOption {
  dateDesc,
  dateAsc,
  doctorAZ,
  doctorZA,
}

enum FilterOption {
  all,
  unprocessed,
  sentToPharmacy,
  filled,
}
