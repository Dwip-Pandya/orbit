import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../splash/splash_screen.dart';
import 'accent_color_screen.dart';
import 'category_config_screen.dart';
import 'data_management_screen.dart';
import 'autofill_config_screen.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  bool _autoLock = true;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, accentColor, isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              physics: const BouncingScrollPhysics(),
              children: [
                _sectionTitle('SECURITY'),
                _settingsTile(
                  Icons.fingerprint_rounded,
                  'Biometric Unlock',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Unlock vault with fingerprint',
                  trailing: Switch(
                    value: authProvider.biometricEnabled,
                    onChanged: (v) => authProvider.toggleBiometric(v),
                    activeColor: accentColor,
                  ),
                ),
                _settingsTile(
                  Icons.security_rounded,
                  'Screenshot Protection',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Block screenshots & hide preview',
                  trailing: Switch(
                    value: authProvider.screenshotProtection,
                    onChanged: (v) => authProvider.toggleScreenshotProtection(v),
                    activeColor: accentColor,
                  ),
                ),
                _settingsTile(
                  Icons.lock_outline_rounded,
                  'Change Master Password',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Update your vault password',
                  onTap: () => _showChangePasswordDialog(context, accentColor, isDark),
                ),
                _settingsTile(
                  Icons.category_outlined,
                  'Category Configuration',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Manage vault categories',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryConfigScreen()),
                  ),
                ),
                _settingsTile(
                  Icons.timer_outlined,
                  'Auto-lock',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Lock vault when inactive',
                  trailing: Switch(
                    value: _autoLock,
                    onChanged: (v) => setState(() => _autoLock = v),
                    activeColor: accentColor,
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('OS INTEGRATION'),
                _settingsTile(
                  Icons.aod_rounded,
                  'Autofill Service',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Configure Android autofill integration',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AutofillConfigScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('APPEARANCE'),
                _settingsTile(
                  Icons.dark_mode_outlined,
                  'Dark Mode',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Switch between light and dark',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (v) => themeProvider.toggleTheme(),
                    activeColor: accentColor,
                  ),
                ),
                _settingsTile(
                  Icons.palette_outlined,
                  'Accent Color',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Personalize app theme',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccentColorScreen()),
                  ),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('DATA'),
                _settingsTile(
                  Icons.save_alt_rounded,
                  'Data Management',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Import and export vault backups',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DataManagementScreen()),
                  ),
                ),
                _settingsTile(
                  Icons.delete_forever_outlined,
                  'Clear All Data',
                  accentColor,
                  isDark: isDark,
                  subtitle: 'Remove all saved passwords',
                  iconColor: const Color(0xFFFF6B6B),
                  onTap: () {},
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text(
                      'Lock Vault',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                      foregroundColor: const Color(0xFFFF6B6B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
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


  Widget _buildHeader(BuildContext context, Color accentColor, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.settings_rounded, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            'Settings',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, Color accentColor,
      {required bool isDark, String? subtitle, Widget? trailing, VoidCallback? onTap, Color? iconColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? accentColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? accentColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
              )
            : null,
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withValues(alpha: 0.4), size: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, Color accentColor, bool isDark) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A20) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Master Password',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(oldPasswordController, 'Current Password', Icons.lock_outline_rounded, accentColor, isDark),
              const SizedBox(height: 16),
              _dialogField(newPasswordController, 'New Password', Icons.password_rounded, accentColor, isDark),
              const SizedBox(height: 16),
              _dialogField(confirmPasswordController, 'Confirm Password', Icons.check_circle_outline_rounded, accentColor, isDark),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match')),
                        );
                      }
                      return;
                    }
                    final success = await Provider.of<AuthProvider>(context, listen: false)
                        .changeMasterPassword(oldPasswordController.text, newPasswordController.text);
                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password changed successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incorrect current password')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String hint, IconData icon, Color accentColor, bool isDark) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: GoogleFonts.outfit(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: accentColor.withValues(alpha: 0.5)),
        filled: true,
        fillColor: isDark ? const Color(0xFF25252D) : AppColors.background.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}
