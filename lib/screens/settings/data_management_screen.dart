import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_colors.dart';
import '../../providers/vault_provider.dart';
import '../../providers/theme_provider.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final vault = Provider.of<VaultProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context, accentColor, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('EXPORT DATA'),
                      _buildCard(
                        title: 'Export Vault',
                        subtitle: 'Save a backup of all your saved passwords and categories to a secure JSON file.',
                        icon: Icons.upload_file_rounded,
                        accentColor: accentColor,
                        isDark: isDark,
                        buttonLabel: 'EXPORT JSON',
                        buttonIcon: Icons.download_rounded,
                        onTap: () => _handleExport(context, vault, accentColor),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle('IMPORT DATA'),
                      _buildCard(
                        title: 'Import Vault',
                        subtitle: 'Restore your vault from an Orbit JSON backup file. Identical existing passwords will be safely skipped.',
                        icon: Icons.restore_page_rounded,
                        accentColor: accentColor,
                        isDark: isDark,
                        buttonLabel: 'UPLOAD JSON FILE',
                        buttonIcon: Icons.upload_rounded,
                        onTap: () => _handleImport(context, vault, accentColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: CircularProgressIndicator(color: accentColor),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 4),
          Text(
            'Data Management',
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
      padding: const EdgeInsets.only(bottom: 16, left: 4),
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

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required String buttonLabel,
    required IconData buttonIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(buttonIcon, size: 20),
              label: Text(buttonLabel, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, VaultProvider vault, Color accentColor) async {
    setState(() => _isLoading = true);
    try {
      final data = vault.exportVault();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Export Orbit Vault',
        fileName: 'orbit_vault_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (outputFile != null) {
        if (context.mounted) {
          _showMessageDialog(
            context: context,
            title: 'Export Successful',
            message: 'Your vault backup has been securely saved to:\n$outputFile',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showMessageDialog(
          context: context,
          title: 'Export Failed',
          message: 'An error occurred while exporting data:\n$e',
          icon: Icons.error_rounded,
          color: AppColors.error,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleImport(BuildContext context, VaultProvider vault, Color accentColor) async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        dialogTitle: 'Select Orbit Backup JSON',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        if (!filePath.toLowerCase().endsWith('.json')) {
          if (context.mounted) {
            _showMessageDialog(
              context: context,
              title: 'Validation Error',
              message: 'Invalid file format. Only .json backup files are accepted.',
              icon: Icons.warning_rounded,
              color: AppColors.warning,
            );
          }
          return;
        }

        final content = await File(filePath).readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        
        final resultStats = vault.importVault(data);
        final imported = resultStats['imported'] ?? 0;
        final duplicates = resultStats['duplicates'] ?? 0;

        if (context.mounted) {
          _showMessageDialog(
            context: context,
            title: 'Import Complete',
            message: 'Successfully imported $imported passwords.\nSkipped $duplicates identical duplicate passwords.',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showMessageDialog(
          context: context,
          title: 'Import Failed',
          message: 'Failed to read or parse the JSON file. Ensure it is a valid Orbit backup.\n$e',
          icon: Icons.error_rounded,
          color: AppColors.error,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _showMessageDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('OK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
