import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/theme_provider.dart';

class AutofillConfigScreen extends StatefulWidget {
  const AutofillConfigScreen({super.key});

  @override
  State<AutofillConfigScreen> createState() => _AutofillConfigScreenState();
}

class _AutofillConfigScreenState extends State<AutofillConfigScreen> {
  final _testEmailController = TextEditingController();
  final _testPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, accentColor, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntegrationCard(accentColor, isDark),
                  const SizedBox(height: 32),
                  _sectionTitle('HOW TO ENABLE ON ANDROID'),
                  _buildStepsCard(accentColor, isDark),
                  const SizedBox(height: 32),
                  _sectionTitle('TEST AUTOFILL INTEGRATION'),
                  _buildTestCard(accentColor, isDark),
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
            'Autofill Integration',
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

  Widget _buildIntegrationCard(Color accentColor, bool isDark) {
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
                child: Icon(Icons.aod_rounded, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'System Autofill Service',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Orbit deep-links into the Android OS Autofill framework. Whenever you open Chrome or another mobile app, Orbit can automatically fill your saved emails, usernames, and passwords seamlessly.',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(Color accentColor, bool isDark) {
    final steps = [
      'Open your phone\'s System Settings.',
      'Navigate to Passwords & Accounts or System > Languages & Input.',
      'Select Autofill service.',
      'Choose Orbit from the provider list and tap Confirm.',
    ];

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
        children: List.generate(steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    steps[index],
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTestCard(Color accentColor, bool isDark) {
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
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulate Website Login',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap inside the input fields below to test OS autofill prompts.',
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _testEmailController,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              style: GoogleFonts.outfit(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Email / Username',
                prefixIcon: Icon(Icons.person_rounded, size: 20, color: accentColor.withValues(alpha: 0.6)),
                fillColor: isDark ? const Color(0xFF25252D) : Colors.black.withValues(alpha: 0.03),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testPasswordController,
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              style: GoogleFonts.outfit(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: Icon(Icons.lock_rounded, size: 20, color: accentColor.withValues(alpha: 0.6)),
                fillColor: isDark ? const Color(0xFF25252D) : Colors.black.withValues(alpha: 0.03),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  TextInput.finishAutofillContext();
                  setState(() {
                    _testEmailController.text = 'demo_user@orbit.io';
                    _testPasswordController.text = 'OrbitSecure#2026';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulated autofill context complete!')),
                  );
                },
                icon: const Icon(Icons.bolt_rounded, size: 20),
                label: Text('SIMULATE AUTOFILL FILLING', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
