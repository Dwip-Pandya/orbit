import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../core/app_colors.dart';
import '../../providers/theme_provider.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> with AutomaticKeepAliveClientMixin {
  double _length = 16;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useNumbers = true;
  bool _useSymbols = true;
  String _generatedPassword = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+=-[]{}|;:,.<>?';

    String allowedChars = '';
    if (_useUppercase) allowedChars += upper;
    if (_useLowercase) allowedChars += lower;
    if (_useNumbers) allowedChars += numbers;
    if (_useSymbols) allowedChars += symbols;

    if (allowedChars.isEmpty) {
      setState(() => _generatedPassword = '');
      return;
    }

    final Random random = Random.secure();
    String result = '';
    for (int i = 0; i < _length; i++) {
      result += allowedChars[random.nextInt(allowedChars.length)];
    }

    setState(() => _generatedPassword = result);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, accentColor, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildPasswordDisplay(accentColor, isDark),
                  const SizedBox(height: 28),
                  _buildSettings(accentColor, isDark),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _generatePassword,
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    label: Text('GENERATE NEW', style: GoogleFonts.outfit(letterSpacing: 1.2)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child: Icon(Icons.auto_awesome_rounded, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            'Generator',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordDisplay(Color accentColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF25252D) : AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _generatedPassword.isEmpty ? '—' : _generatedPassword,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _strengthBadge(accentColor),
              const Spacer(),
              IconButton(
                onPressed: () {
                  if (_generatedPassword.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: _generatedPassword));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied!', style: GoogleFonts.outfit())),
                    );
                  }
                },
                icon: Icon(Icons.copy_rounded, color: accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _strengthBadge(Color accentColor) {
    Color color;
    String label;
    if (_length < 8) {
      color = AppColors.error;
      label = 'Weak';
    } else if (_length < 12) {
      color = AppColors.warning;
      label = 'Fair';
    } else if (_length < 16) {
      color = AppColors.success;
      label = 'Strong';
    } else {
      color = accentColor;
      label = 'Unbreakable';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Length', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                _length.toInt().toString(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: accentColor),
              ),
            ],
          ),
          Slider(
            value: _length,
            min: 4,
            max: 32,
            divisions: 28,
            activeColor: accentColor,
            onChanged: (val) {
              setState(() => _length = val);
              _generatePassword();
            },
          ),
          const SizedBox(height: 16),
          _toggleRow('Uppercase', _useUppercase, accentColor, (v) {
            setState(() => _useUppercase = v);
            _generatePassword();
          }),
          _toggleRow('Lowercase', _useLowercase, accentColor, (v) {
            setState(() => _useLowercase = v);
            _generatePassword();
          }),
          _toggleRow('Numbers', _useNumbers, accentColor, (v) {
            setState(() => _useNumbers = v);
            _generatePassword();
          }),
          _toggleRow('Symbols', _useSymbols, accentColor, (v) {
            setState(() => _useSymbols = v);
            _generatePassword();
          }),
        ],
      ),
    );
  }

  Widget _toggleRow(String title, bool value, Color accentColor, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accentColor,
        ),
      ],
    );
  }
}
