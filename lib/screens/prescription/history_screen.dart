import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../../models/medication.dart';
import '../../models/prescription.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      // Add mock prescriptions here
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
    }

    // Finally apply sorting
    _filteredPrescriptions.sort((a, b) {
      switch (_currentSortOption) {
        case SortOption.dateDesc:
          return b.dateScanned.compareTo(a.dateScanned);
        case SortOption.dateAsc:
          return a.dateScanned.compareTo(b.dateScanned);
        case SortOption.doctorAZ:
          return a.doctorName.compareTo(b.doctorName);
        case SortOption.doctorZA:
          return b.doctorName.compareTo(a.doctorName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'history'.tr(),
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
          child: Directionality(
            textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
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
                      hintText: 'search_prescriptions'.tr(),
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
                      _buildFilterChip(FilterOption.all, 'filter_all'.tr()),
                      SizedBox(width: 8),
                      _buildFilterChip(FilterOption.filled, 'filter_filled'.tr()),
                      SizedBox(width: 8),
                      _buildFilterChip(FilterOption.sentToPharmacy, 'filter_sent'.tr()),
                      SizedBox(width: 8),
                      _buildFilterChip(FilterOption.unprocessed, 'filter_unprocessed'.tr()),
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
                      'no_prescriptions'.tr(),
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
    final isArabic = context.locale.languageCode == 'ar';

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
                    DateFormat('MMM dd, yyyy', context.locale.toString()).format(prescription.dateScanned),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
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
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Icon(
                    isArabic ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
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
        label = 'status_filled'.tr();
        break;
      case PrescriptionStatus.sentToPharmacy:
        backgroundColor = Colors.orange;
        label = 'status_sent'.tr();
        break;
      case PrescriptionStatus.unprocessed:
        backgroundColor = Colors.grey;
        label = 'status_new'.tr();
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
    final isArabic = context.locale.languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Container(
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
                          'prescription_details'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'scanned_on'.tr() + ' ${DateFormat('MMMM dd, yyyy', context.locale.toString()).format(prescription.dateScanned)}',
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
                        title: 'doctor'.tr(),
                        content: prescription.doctorName,
                        icon: Icons.person,
                      ),
                      Divider(),
                      // Medications
                      Text(
                        'medications'.tr(),
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
                        'original_prescription'.tr(),
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
                        'recognized_text'.tr(),
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
                              SnackBar(content: Text('prescription_shared'.tr()))
                          );
                        },
                        icon: Icon(Icons.share),
                        label: Text('share'.tr()),
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
                        onPressed: () {
                          // Implement send to pharmacy functionality
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('sent_to_pharmacy'.tr()))
                          );
                        },
                        icon: Icon(Icons.local_pharmacy),
                        label: Text('send_to_pharmacy'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          _buildMedicationDetail('dosage'.tr(), medication.dosage),
          SizedBox(height: 4),
          _buildMedicationDetail('frequency'.tr(), medication.frequency),
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
    final isArabic = context.locale.languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sort_by'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              SizedBox(height: 16),
              _buildSortOption(SortOption.dateDesc, 'dateDesc'.tr()),
              _buildSortOption(SortOption.dateAsc, 'dateAsc'.tr()),
              _buildSortOption(SortOption.doctorAZ, 'doctorAZ'.tr()),
              _buildSortOption(SortOption.doctorZA, 'doctorZA'.tr()),
            ],
          ),
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
    final isArabic = context.locale.languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'filter_by_status'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              SizedBox(height: 16),
              _buildFilterOption(FilterOption.all, 'all_prescriptions'.tr()),
              _buildFilterOption(FilterOption.filled, 'filled_prescriptions'.tr()),
              _buildFilterOption(FilterOption.sentToPharmacy, 'sent_to_pharmacy_prescriptions'.tr()),
              _buildFilterOption(FilterOption.unprocessed, 'unprocessed_prescriptions'.tr()),
            ],
          ),
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