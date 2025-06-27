import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _prescriptions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'date';
  String _userId = '';

  // Add secure storage for JWT tokens
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );



  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? '';
    if (_userId.isNotEmpty) {
      await _fetchPrescriptionHistory();
    } else {
      setState(() => _isLoading = false);
    }
  }

  // UPDATED: Add JWT authentication to fetch prescription history
  Future<void> _fetchPrescriptionHistory() async {
    try {
      // Get JWT token from secure storage
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      // Use the new JWT-authenticated endpoint
      final response = await http.get(
        Uri.parse('http://192.168.1.8:5000/api/prescriptions/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Add JWT token
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final prescriptionsData = responseData['prescriptions'] as List<dynamic>;

        setState(() {
          _prescriptions = prescriptionsData
              .map((prescription) => prescription as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load prescription history: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching prescription history: $error');
      setState(() => _isLoading = false);

      // Handle authentication errors specifically
      if (error.toString().contains('authentication') ||
          error.toString().contains('login again')) {
        _showErrorSnackBar('Session expired. Please login again.');
        // Optionally navigate to login screen
        // Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showErrorSnackBar('failed_to_load_history'.tr());
      }
    }
  }

  // Custom SnackBar for Success Messages
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5170FF), // Your app's primary blue
                Color(0xFF1E3A8A), // Your app's secondary blue
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5170FF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.done,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Custom SnackBar for Error Messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E3A8A), // Your app's secondary blue
                Color(0xFFE53E3E), // Red for error indication
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Updated to use prescription name from backend
  String _getPrescriptionName(Map<String, dynamic> prescription) {
    // Use the prescription_name from backend if available
    if (prescription['prescription_name'] != null) {
      return prescription['prescription_name'];
    }

    // Fallback: use prescription_number if available
    if (prescription['prescription_number'] != null) {
      return 'Prescription ${prescription['prescription_number']}';
    }

    // Final fallback: use index + 1
    final index = _prescriptions.indexOf(prescription);
    return 'prescription_name'.tr(args: [(index + 1).toString()]);
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
        return Icons.water_drop;
      default:
        return Icons.medication;
    }
  }

  Future<void> _deletePrescription(String prescriptionId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'delete_prescription'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'delete_prescription_confirmation'.tr(),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'action_cannot_be_undone'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'delete'.tr(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _performDelete(prescriptionId);
    }
  }

  Future<void> _performDelete(String prescriptionId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF5170FF),
                ),
                const SizedBox(height: 16),
                Text(
                  'deleting_prescription'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Get JWT token from secure storage
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      final response = await http.delete(
        Uri.parse('http://192.168.1.8:5000/api/prescriptions/$prescriptionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Add JWT token
        },
        // Remove user_id from body since backend gets it from JWT token
      );

      Navigator.pop(context); // Hide loading

      if (response.statusCode == 200) {
        setState(() {
          _prescriptions.removeWhere((prescription) => prescription['id'] == prescriptionId);
        });
        _showSuccessSnackBar('prescription_deleted_successfully'.tr());
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to delete prescription');
      }
    } catch (error) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('Error deleting prescription: $error');

      if (error.toString().contains('authentication') ||
          error.toString().contains('login again')) {
        _showErrorSnackBar('Session expired. Please login again.');
      } else {
        _showErrorSnackBar('failed_to_delete_prescription'.tr());
      }
    }
  }

  // Updated filtering and sorting with backend prescription names
  List<Map<String, dynamic>> get _filteredPrescriptions {
    var filtered = _prescriptions.where((prescription) {
      final searchLower = _searchQuery.toLowerCase();
      final recognizedText = (prescription['recognized_text'] ?? '').toString().toLowerCase();
      final medications = prescription['medications'] as List<dynamic>? ?? [];
      final medicationNames = medications
          .map((med) => (med['name'] ?? '').toString().toLowerCase())
          .join(' ');

      // Search by prescription name from backend
      final prescriptionName = _getPrescriptionName(prescription).toLowerCase();

      return prescriptionName.contains(searchLower) ||
          recognizedText.contains(searchLower) ||
          medicationNames.contains(searchLower);
    }).toList();

    // Sort prescriptions with proper numbering
    switch (_sortBy) {
      case 'name':
      // Sort by prescription number from backend
        filtered.sort((a, b) {
          final numberA = a['prescription_number'] ?? 0;
          final numberB = b['prescription_number'] ?? 0;
          return numberA.compareTo(numberB);
        });
        break;
      case 'status':
        filtered.sort((a, b) => (a['status'] ?? '').toString().compareTo(
            (b['status'] ?? '').toString()));
        break;
      case 'date':
      default:
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['scan_date'] ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b['scan_date'] ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA); // Most recent first
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'prescription_history'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF5170FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchPrescriptionHistory();
            },
          ),
        ],
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
            child: Column(
              children: [
                // Search and Filter Section
                _buildSearchAndFilter(),

                // Prescriptions List
                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : _filteredPrescriptions.isEmpty
                      ? _buildEmptyState()
                      : _buildPrescriptionsList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'search_prescriptions'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF5170FF)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sort Options
          Row(
            children: [
              Text(
                'sort_by'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() => _sortBy = value ?? 'date');
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'date',
                      child: Text('date'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('name'.tr()),
                    ),
                    DropdownMenuItem(
                      value: 'status',
                      child: Text('status'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'no_prescriptions_found'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'scan_first_prescription'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(Icons.add_a_photo),
            label: Text('scan_prescription'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredPrescriptions.length,
      itemBuilder: (context, index) {
        final prescription = _filteredPrescriptions[index];
        return _buildPrescriptionCard(prescription);
      },
    );
  }

  // Updated to use prescription data instead of index
  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final medications = prescription['medications'] as List<dynamic>? ?? [];
    final scanDate = DateTime.tryParse(prescription['scan_date'] ?? '') ?? DateTime.now();
    final prescriptionName = _getPrescriptionName(prescription);

    return Dismissible(
      key: Key(prescription['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'delete'.tr(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('delete_prescription_title'.tr(args: [prescriptionName])),
            content: Text('delete_prescription_confirmation'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'delete'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _performDelete(prescription['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showPrescriptionDetails(prescription, prescriptionName),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Icon(
                      Icons.document_scanner,
                      color: const Color(0xFF5170FF),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prescriptionName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy - HH:mm').format(scanDate),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(prescription['status'] ?? 'processed'),
                  ],
                ),

                const SizedBox(height: 12),

                // Medications Preview
                if (medications.isNotEmpty) ...[
                  Text(
                    'medications'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: medications.take(3).map((med) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5170FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getFormIcon(med['form'] ?? 'tablet'),
                              size: 12,
                              color: const Color(0xFF5170FF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              med['name'] ?? 'unknown'.tr(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF5170FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (medications.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'more_medications'.tr(args: [(medications.length - 3).toString()]),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showPrescriptionDetails(prescription, prescriptionName),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: Text('view_details'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5170FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deletePrescription(prescription['id']),
                      icon: const Icon(Icons.delete, size: 16),
                      label: Text('delete'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String translatedStatus;
    switch (status.toLowerCase()) {
      case 'processed':
        color = Colors.green;
        translatedStatus = 'processed'.tr();
        break;
      case 'unprocessed':
        color = Colors.orange;
        translatedStatus = 'unprocessed'.tr();
        break;
      case 'error':
        color = Colors.red;
        translatedStatus = 'error'.tr();
        break;
      default:
        color = Colors.grey;
        translatedStatus = status.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        translatedStatus,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showPrescriptionDetails(Map<String, dynamic> prescription, String prescriptionName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          prescriptionName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: _buildPrescriptionDetailsContent(prescription),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionDetailsContent(Map<String, dynamic> prescription) {
    final medications = prescription['medications'] as List<dynamic>? ?? [];
    final scanDate = DateTime.tryParse(prescription['scan_date'] ?? '') ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Info
        _buildDetailSection(
          'basic_information'.tr(),
          [
            _buildDetailRow('scan_date'.tr(), DateFormat('MMMM dd, yyyy - HH:mm').format(scanDate)),
            _buildDetailRow('status'.tr(), prescription['status'] ?? 'processed'),
          ],
        ),

        const SizedBox(height: 20),

        // Recognized Text
        if (prescription['recognized_text'] != null && prescription['recognized_text'].toString().isNotEmpty)
          _buildDetailSection(
            'recognized_text'.tr(),
            [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  prescription['recognized_text'],
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 20),

        // Medications
        if (medications.isNotEmpty)
          _buildDetailSection(
            'medications'.tr(),
            medications.map((med) => _buildMedicationDetailCard(med)).toList(),
          ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildMedicationDetailCard(Map<String, dynamic> medication) {
    final confidence = (medication['confidence'] ?? 0.0) as double;
    final form = medication['form'] ?? 'tablet';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5170FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFormIcon(form),
                color: const Color(0xFF5170FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medication['name'] ?? 'unknown_medication'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(confidence),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(confidence * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (medication['form'] != null && medication['form'] != 'N/A')
            _buildDetailRow('form'.tr(), medication['form'].toString()),
          if (medication['dosage'] != null && medication['dosage'] != 'N/A')
            _buildDetailRow('dosage'.tr(), medication['dosage'].toString()),
          if (medication['frequency'] != null && medication['frequency'] != 'N/A')
            _buildDetailRow('frequency'.tr(), medication['frequency'].toString()),
          if (medication['alternatives'] != null &&
              medication['alternatives'] != 'N/A' &&
              medication['alternatives'] != 'No alternatives available')
            _buildDetailRow('alternatives'.tr(), medication['alternatives'].toString()),
          if (medication['conflicts'] != null &&
              medication['conflicts'] != 'N/A' &&
              medication['conflicts'] != 'No conflicts listed')
            _buildDetailRow('conflicts'.tr(), medication['conflicts'].toString()),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}