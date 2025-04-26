import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ui' as ui;
import '../auth/welcome_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  String _appVersion = 'Beta';
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _getAppVersion();
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Save any pending changes when app goes to background
      if (_autoSaveEnabled) {
        _saveAllSettings();
      }
    }
  }

  void autoSave(Function saveFunction) {
    if (_autoSaveTimer != null) {
      _autoSaveTimer!.cancel();
    }

    _autoSaveTimer = Timer(Duration(seconds: 1), () {
      if (_autoSaveEnabled) {
        saveFunction();
      }
    });
  }

  void _showAutoSaveNotification() {
    if (_autoSaveEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings_saved'.tr()),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _saveAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setBool('auto_save_enabled', _autoSaveEnabled);
    // Save other settings as needed
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _autoSaveEnabled = prefs.getBool('auto_save_enabled') ?? true;
    });
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
      final token = prefs.getString('token');

      if (token == null) {
        // No token found, user is not logged in
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (Route<dynamic> route) => false,
        );
        return;
      }

      // Make API request to get user profile
      final response = await http.get(
        Uri.parse('http://192.168.1.131:5000/api/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userName = data['user']['name'];
          _userEmail = data['user']['email'];
          _isLoading = false;
        });
      } else {
        // Token might be invalid or expired
        _handleAuthError();
      }
    } catch (error) {
      print('Error loading user data: $error');
      setState(() => _isLoading = false);
    }
  }

  void _handleAuthError() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold, color: Colors.white
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('account'.tr()),
                _buildProfileCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('app_preferences'.tr()),
                _buildLanguageSelector(),
                const SizedBox(height: 8),
                _buildSettingSwitch(
                  'dark_mode'.tr(),
                  'dark_mode_desc'.tr(),
                  _darkModeEnabled,
                      (value) {
                    setState(() => _darkModeEnabled = value);
                    autoSave(() async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('dark_mode_enabled', value);
                      _showAutoSaveNotification();
                    });
                  },
                  Icons.dark_mode,
                ),
                _buildSettingSwitch(
                  'auto_save'.tr(),
                  'auto_save_desc'.tr(),
                  _autoSaveEnabled,
                      (value) {
                    setState(() => _autoSaveEnabled = value);
                    // Auto-save setting itself should be saved immediately
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setBool('auto_save_enabled', value);
                    });
                  },
                  Icons.save,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('data_privacy'.tr()),
                _buildSettingItem(
                  'privacy_policy'.tr(),
                  'privacy_policy_desc'.tr(),
                  Icons.privacy_tip,
                      () {},
                ),
                _buildSettingItem(
                  'delete_account'.tr(),
                  'delete_account_desc'.tr(),
                  Icons.delete_forever,
                  _showDeleteAccountDialog,
                  textColor: Colors.red,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('support'.tr()),
                _buildSettingItem(
                  'contact_us'.tr(),
                  'contact_us_desc'.tr(),
                  Icons.mail,
                      () {},
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('about'.tr()),
                _buildSettingItem(
                  'app_version'.tr(),
                  'v$_appVersion',
                  Icons.info,
                      () {},
                  showTrailingIcon: false,
                ),
                const SizedBox(height: 24),
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final isArabic = context.locale.languageCode == 'ar';

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
            'change_language_desc'.tr(),
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

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (Route<dynamic> route) => false,
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
      ),
      child: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )
          : Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: _userName.isNotEmpty
                ? Text(
              _userName[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                  _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.green,
          secondary: Icon(icon, color: Colors.white),
        ),
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
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
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
              ? const Icon(Icons.arrow_forward_ios, color: Colors.white70)
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
        title: Text('log_out'.tr()),
        content: Text('logout_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear the token
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');

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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_account'.tr()),
        content: Text('delete_account_warning'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}