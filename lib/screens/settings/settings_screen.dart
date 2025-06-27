import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui' as ui;
import '../auth/welcome_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Beta';
  String _userName = '';
  String _userEmail = '';
  String _userId = '';
  bool _isLoading = true;

  // FastAPI backend URL
  final String baseUrl = 'http://192.168.1.8:5000';

  // Secure storage for JWT tokens
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
    _getAppVersion();
    _loadUserData();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');

      if (userId == null || userName == null || userEmail == null) {
        _handleAuthError();
        return;
      }

      // Get JWT token for authenticated request
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token != null) {
        // Fetch fresh user data from FastAPI with JWT authentication
        final response = await http.get(
          Uri.parse('$baseUrl/api/users/me'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _userId = data['user']['id'];
            _userName = data['user']['name'];
            _userEmail = data['user']['email'];
            _isLoading = false;
          });

          // Update stored data
          await prefs.setString('user_name', _userName);
          await prefs.setString('user_email', _userEmail);
        } else {
          // Use stored data if API fails
          setState(() {
            _userId = userId;
            _userName = userName;
            _userEmail = userEmail;
            _isLoading = false;
          });
        }
      } else {
        // Use stored data if no token
        setState(() {
          _userId = userId;
          _userName = userName;
          _userEmail = userEmail;
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error loading user data: $error');
      // Fallback to stored data
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getString('user_id') ?? '';
        _userName = prefs.getString('user_name') ?? '';
        _userEmail = prefs.getString('user_email') ?? '';
        _isLoading = false;
      });
    }
  }

  void _handleAuthError() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Set scaffold background color
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        backgroundColor: const Color(0xFF5170FF),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensure full height
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('account'.tr()),
                        _buildProfileCard(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('app_preferences'.tr()),
                        _buildLanguageSelector(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('data_privacy'.tr()),

                        _buildSettingItem(
                          'prescription_history'.tr(),
                          'view_manage_prescriptions'.tr(),
                          Icons.history,
                              () => Navigator.pushNamed(context, '/history'),
                        ),

                        // Removed delete account section

                        const SizedBox(height: 24),
                        _buildSectionTitle('app_info'.tr()),

                        _buildSettingItem(
                          'app_version'.tr(),
                          'v$_appVersion',
                          Icons.info,
                              () => _showVersionInfo(),
                          showTrailingIcon: false,
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout button fixed at bottom
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildLogoutButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(Icons.language, color: Colors.white),
          title: Text(
            'language'.tr(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'change_app_language'.tr(),
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          trailing: DropdownButton<ui.Locale>(
            value: context.locale,
            dropdownColor: const Color(0xFF1E3A8A),
            style: GoogleFonts.poppins(color: Colors.white),
            underline: Container(),
            items: [
              DropdownMenuItem(
                value: const ui.Locale('en'),
                child: Text(
                  'english'.tr(),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: const ui.Locale('ar'),
                child: Text(
                  'arabic'.tr(),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              )
            ],
            onChanged: (ui.Locale? locale) async {
              if (locale != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('language', locale.languageCode);
                context.setLocale(locale);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('language_changed_successfully'.tr()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: _userName.isNotEmpty
                ? Center(
              child: Text(
                _userName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
                : const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName.isEmpty ? 'loading'.tr() : _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail.isEmpty ? 'loading'.tr() : _userEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    'active_user'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.green[300],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        Color? textColor,
        bool showTrailingIcon = true,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ListTile(
          leading: Icon(icon, color: textColor ?? Colors.white),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.white,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          trailing: showTrailingIcon
              ? const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout),
        label: Text(
          'log_out'.tr(),
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'log_out'.tr(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'are_you_sure_logout'.tr(),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await _secureStorage.deleteAll();

              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5170FF),
            ),
            child: Text('log_out'.tr()),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'app_information'.tr(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'version'.tr()}: $_appVersion'),
            SizedBox(height: 8),
            Text('${'build'.tr()}: 2025.1.0'),
            SizedBox(height: 8),
            Text('${'backend'.tr()}: FastAPI'),
            SizedBox(height: 8),
            Text('${'database'.tr()}: MongoDB'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }
}