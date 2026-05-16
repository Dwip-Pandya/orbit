import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../main_shell.dart';

class MasterPasswordScreen extends StatefulWidget {
  const MasterPasswordScreen({super.key});

  @override
  State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isFirstLaunch && authProvider.biometricEnabled) {
      final success = await authProvider.authenticateWithBiometrics();
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isFirstLaunch = authProvider.isFirstLaunch;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F12) : AppColors.background,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [const Color(0xFF1A1A20), const Color(0xFF0F0F12)]
              : [Colors.white, accentColor.withValues(alpha: 0.05), accentColor.withValues(alpha: 0.1)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                _buildAnimatedIcon(accentColor, authProvider),
                const SizedBox(height: 48),
                Text(
                  isFirstLaunch ? 'Create Your Vault' : 'Welcome to Orbit',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isFirstLaunch
                      ? 'Secure your digital life with a single, strong master password.'
                      : (authProvider.biometricEnabled ? 'Unlock with fingerprint above or enter master password.' : 'Unlock your encrypted vault to access your passwords.'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 56),
                _buildInputField(
                  controller: _passwordController,
                  hint: 'Master Password',
                  icon: Icons.lock_rounded,
                  accentColor: accentColor,
                  isDark: isDark,
                  obscure: _obscurePassword,
                  error: _errorText,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                if (isFirstLaunch) ...[
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _confirmController,
                    hint: 'Confirm Password',
                    icon: Icons.check_circle_rounded,
                    accentColor: accentColor,
                    isDark: isDark,
                    obscure: _obscurePassword,
                    showToggle: false,
                  ),
                ],
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _handleContinue(authProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: Text(
                      isFirstLaunch ? 'CREATE VAULT' : 'UNLOCK VAULT',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (!isFirstLaunch) ...[
                  if (authProvider.biometricEnabled)
                    TextButton.icon(
                      onPressed: _checkBiometrics,
                      icon: Icon(Icons.fingerprint_rounded, color: accentColor, size: 20),
                      label: Text(
                        'Unlock with Fingerprint',
                        style: GoogleFonts.outfit(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Master Password?',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white38 : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(Color accentColor, AuthProvider authProvider) {
    return GestureDetector(
      onTap: (!authProvider.isFirstLaunch && authProvider.biometricEnabled) ? _checkBiometrics : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(Icons.fingerprint_rounded, size: 48, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    bool obscure = false,
    String? error,
    bool showToggle = true,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.outfit(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: accentColor.withValues(alpha: 0.6), size: 22),
        fillColor: isDark ? const Color(0xFF1A1A20) : Colors.white,
        filled: true,
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                onPressed: onToggle,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorText: error,
      ),
    );
  }

  void _handleContinue(AuthProvider authProvider) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorText = 'Password cannot be empty');
      return;
    }
    if (authProvider.isFirstLaunch) {
      final confirm = _confirmController.text;
      if (password != confirm) {
        setState(() => _errorText = 'Passwords do not match');
        return;
      }
      await authProvider.setupMasterPassword(password);
    } else {
      final success = await authProvider.unlock(password);
      if (!success) {
        setState(() => _errorText = 'Incorrect master password');
        return;
      }
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}

