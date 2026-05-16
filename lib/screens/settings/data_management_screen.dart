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
                      _sectionTitle('AUTOMATED BACKUP SCHEDULE'),
                      _buildScheduleSelector(context, vault, accentColor, isDark),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 32),
                      _sectionTitle('AUTOMATED BACKUP HISTORY'),
                      _buildBackupHistoryList(context, vault, accentColor, isDark),
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

  Widget _buildScheduleSelector(BuildContext context, VaultProvider vault, Color accentColor, bool isDark) {
    final options = [
      {'key': 'daily', 'label': 'Daily'},
      {'key': 'weekly', 'label': 'Weekly'},
      {'key': 'monthly', 'label': 'Monthly'},
      {'key': 'never', 'label': 'Never'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Automatic JSON Backup',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Orbit will automatically backup your encrypted vault to local storage at the selected interval.',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((opt) {
              final isSelected = vault.backupSchedule == opt['key'];
              return ChoiceChip(
                label: Text(
                  opt['label']!,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                selected: isSelected,
                selectedColor: accentColor,
                backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (_) => vault.setBackupSchedule(opt['key']!),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                setState(() => _isLoading = true);
                final path = await vault.createAutomatedBackup();
                setState(() => _isLoading = false);
                if (path != null && context.mounted) {
                  _showMessageDialog(
                    context: context,
                    title: 'Backup Created',
                    message: 'Automated backup successfully saved to:\n$path',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  );
                }
              },
              icon: Icon(Icons.backup_rounded, color: accentColor, size: 20),
              label: Text(
                'CREATE BACKUP NOW',
                style: GoogleFonts.outfit(color: accentColor, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupHistoryList(BuildContext context, VaultProvider vault, Color accentColor, bool isDark) {
    return FutureBuilder<List<File>>(
      future: vault.getAutomatedBackupFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: accentColor));
        }

        final files = snapshot.data ?? [];
        if (files.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A20) : Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: Text(
              'No automated backups created yet.',
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
          );
        }

        return Column(
          children: files.map((file) {
            final name = file.path.split('/').last.split('\\').last;
            final lastMod = file.lastModifiedSync();
            final formattedTime = '${lastMod.year}-${lastMod.month.toString().padLeft(2, '0')}-${lastMod.day.toString().padLeft(2, '0')} ${lastMod.hour.toString().padLeft(2, '0')}:${lastMod.minute.toString().padLeft(2, '0')}';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A20) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.history_rounded, color: accentColor),
                ),
                title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text(formattedTime, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                trailing: const Icon(Icons.more_vert_rounded, size: 20),
                onTap: () => _showBackupActionSheet(context, vault, file, accentColor, isDark),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showBackupActionSheet(BuildContext context, VaultProvider vault, File file, Color accentColor, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A20) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('Backup Action', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.restore_rounded, color: AppColors.success),
                title: Text('Restore Vault from this Backup', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  try {
                    final content = await file.readAsString();
                    final data = jsonDecode(content) as Map<String, dynamic>;
                    final stats = vault.importVault(data);
                    if (context.mounted) {
                      _showMessageDialog(
                        context: context,
                        title: 'Restore Complete',
                        message: 'Successfully imported ${stats['imported']} passwords.\nSkipped ${stats['duplicates']} duplicates.',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      _showMessageDialog(context: context, title: 'Restore Failed', message: e.toString(), icon: Icons.error_rounded, color: AppColors.error);
                    }
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.download_rounded, color: accentColor),
                title: Text('Export & Save File', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  try {
                    final bytes = await file.readAsBytes();
                    final outputFile = await FilePicker.saveFile(
                      dialogTitle: 'Export Backup File',
                      fileName: file.path.split('/').last.split('\\').last,
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                      bytes: bytes,
                    );
                    if (outputFile != null && context.mounted) {
                      _showMessageDialog(context: context, title: 'Saved Successful', message: outputFile, icon: Icons.check_circle_rounded, color: AppColors.success);
                    }
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
              ),
            ],
          ),
        );
      },
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

