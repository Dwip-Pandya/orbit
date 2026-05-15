import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/vault_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/password_entry.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> with AutomaticKeepAliveClientMixin {
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'General';
  bool _showPassword = false;
  double _strength = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  void _updateStrength() {
    final password = _passwordController.text;
    double strength = 0;
    if (password.isEmpty) {
      strength = 0;
    } else {
      if (password.length >= 8) strength += 0.25;
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    }
    setState(() => _strength = strength);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final vault = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, accentColor, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('ACCOUNT INFO', isDark, [
                    _buildLabel('Account Title'),
                    _buildField(_titleController, 'e.g. Instagram', Icons.title_rounded, accentColor, isDark),
                    const SizedBox(height: 20),
                    _buildLabel('Username / Email'),
                    _buildField(_usernameController, 'e.g. user@orbit.com', Icons.person_outline_rounded, accentColor, isDark),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('SECURITY', isDark, [
                    _buildLabel('Password'),
                    _buildField(
                      _passwordController,
                      '••••••••',
                      Icons.lock_outline_rounded,
                      accentColor,
                      isDark,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),
                    _buildStrengthIndicator(accentColor),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('DETAILS', isDark, [
                    _buildLabel('Website / App URL'),
                    _buildField(_websiteController, 'www.example.com', Icons.link_rounded, accentColor, isDark),
                    const SizedBox(height: 20),
                    _buildLabel('Category'),
                    _buildCategoryDropdown(vault, accentColor, isDark),
                    const SizedBox(height: 20),
                    _buildLabel('Notes'),
                    _buildField(_notesController, 'Add any extra details here...', Icons.notes_rounded, accentColor, isDark, maxLines: 4),
                  ]),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'SAVE TO VAULT',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
            child: Icon(Icons.add_task_rounded, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            'Create New',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, Color accentColor, bool isDark,
      {bool isPassword = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_showPassword,
      maxLines: maxLines,
      style: GoogleFonts.outfit(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: accentColor.withValues(alpha: 0.5), size: 20),
        fillColor: isDark ? const Color(0xFF25252D) : AppColors.background.withValues(alpha: 0.5),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: () => setState(() => _showPassword = !_showPassword),
                child: Icon(
                  _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildStrengthIndicator(Color accentColor) {
    Color strengthColor;
    String label;
    if (_strength <= 0.25) {
      strengthColor = AppColors.error;
      label = 'Weak';
    } else if (_strength <= 0.5) {
      strengthColor = AppColors.warning;
      label = 'Fair';
    } else if (_strength <= 0.75) {
      strengthColor = AppColors.success;
      label = 'Strong';
    } else {
      strengthColor = accentColor;
      label = 'Unbreakable';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _strength,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: strengthColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(VaultProvider vault, Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF25252D) : AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: accentColor),
          style: GoogleFonts.outfit(fontSize: 15),
          dropdownColor: isDark ? const Color(0xFF1A1A20) : Colors.white,
          items: vault.categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields', style: GoogleFonts.outfit()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final entry = PasswordEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      website: _websiteController.text,
      notes: _notesController.text,
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    Provider.of<VaultProvider>(context, listen: false).addEntry(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved to your vault', style: GoogleFonts.outfit()),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _titleController.clear();
    _usernameController.clear();
    _passwordController.clear();
    _websiteController.clear();
    _notesController.clear();
    setState(() => _selectedCategory = 'General');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
