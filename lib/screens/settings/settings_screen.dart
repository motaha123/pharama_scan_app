import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  String _selectedLanguage = 'English';
  String _appVersion = 'Beta';
  final List<String> _languages = ['English', 'Arabic'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _autoSaveEnabled = prefs.getBool('auto_save_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setBool('auto_save_enabled', _autoSaveEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5170FF),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Account'),
                _buildProfileCard(),
                SizedBox(height: 24),

                _buildSectionTitle('App Preferences'),
                _buildSettingSwitch(
                  'Dark Mode',
                  'Toggle dark theme for the app',
                  _darkModeEnabled,
                      (value) {
                    setState(() {
                      _darkModeEnabled = value;
                      _saveSettings();
                      // Here you would implement dark mode toggling
                    });
                  },
                  Icons.dark_mode,
                ),
                _buildSettingSwitch(
                  'Auto-Save',
                  'Automatically save scanned prescriptions',
                  _autoSaveEnabled,
                      (value) {
                    setState(() {
                      _autoSaveEnabled = value;
                      _saveSettings();
                    });
                  },
                  Icons.save,
                ),
                SizedBox(height: 8),

                _buildLanguageSelector(),

                SizedBox(height: 24),

                _buildSectionTitle('Data & Privacy'),
                _buildSettingItem(
                  'Data Storage',
                  'Manage how your prescription data is stored',
                  Icons.storage,
                      () {
                    // Navigate to data storage settings
                  },
                ),
                _buildSettingItem(
                  'Privacy Policy',
                  'Read our privacy policy',
                  Icons.privacy_tip,
                      () {
                    // Navigate to privacy policy
                  },
                ),
                _buildSettingItem(
                  'Delete Account',
                  'Permanently delete your account and data',
                  Icons.delete_forever,
                      () {
                    _showDeleteAccountDialog();
                  },
                  textColor: Colors.red,
                ),

                SizedBox(height: 24),

                _buildSectionTitle('Support'),
                _buildSettingItem(
                  'Help Center',
                  'Get help with using the app',
                  Icons.help,
                      () {
                    // Navigate to help center
                  },
                ),
                _buildSettingItem(
                  'Report a Problem',
                  'Let us know if something isn\'t working',
                  Icons.report_problem,
                      () {
                    // Navigate to problem reporting
                  },
                ),
                _buildSettingItem(
                  'Contact Us',
                  'Get in touch with our support team',
                  Icons.mail,
                      () {
                    // Navigate to contact form or email
                  },
                ),

                SizedBox(height: 24),

                _buildSectionTitle('About'),
                _buildSettingItem(
                  'App Version',
                  'v$_appVersion',
                  Icons.info,
                      () {
                    // Show app version info
                  },
                  showTrailingIcon: false,
                ),
                _buildSettingItem(
                  'Terms of Service',
                  'Read our terms of service',
                  Icons.description,
                      () {
                    // Navigate to terms of service
                  },
                ),

                SizedBox(height: 24),

                _buildLogoutButton(),

                SizedBox(height: 40),
              ],
            ),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Omar',  // Replace with actual user name
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'user@example.com',  // Replace with actual user email
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Navigate to profile edit screen
            },
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
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.white.withOpacity(0.3),
          secondary: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
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
          leading: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
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
              ? Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.7),
            size: 16,
          )
              : null,
          onTap: onTap,
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
          leading: Icon(
            Icons.language,
            color: Colors.white,
            size: 28,
          ),
          title: Text(
            'Language',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Select your preferred language',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          trailing: DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: Color(0xFF1E3A8A),
            iconEnabledColor: Colors.white,
            underline: Container(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedLanguage = newValue;
                  _saveSettings();
                });
              }
            },
            items: _languages.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog();
        },
        icon: Icon(Icons.logout),
        label: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E3A8A),
          padding: EdgeInsets.symmetric(vertical: 12),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform logout logic
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5170FF),
              ),
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
              'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform account deletion logic
                Navigator.of(context).pop();
                // Show confirmation and navigate to welcome screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account deleted successfully')),
                );
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
