import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/vault_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/password_entry.dart';
import './edit_password_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Map<String, bool> _visiblePasswords = {};

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vault = Provider.of<VaultProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredEntries = vault.entries.where((e) {
      final matchesSearch = e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.username.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || e.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final categories = ['All', ...vault.categories];

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, accentColor, isDark),
          _buildSearchBar(accentColor, isDark),
          _buildCategoryFilter(categories, accentColor, isDark),
          Expanded(
            child: filteredEntries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      return _buildPasswordCard(filteredEntries[index], accentColor, isDark);
                    },
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
            child: Icon(Icons.shield_rounded, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'My Vault',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<VaultProvider>(
            builder: (context, vault, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${vault.totalCount} items',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color accentColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.outfit(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search passwords...',
          prefixIcon: const Icon(Icons.search_rounded, size: 22),
          fillColor: isDark ? const Color(0xFF1A1A20) : Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories, Color accentColor, bool isDark) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : (isDark ? const Color(0xFF1A1A20) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordCard(PasswordEntry entry, Color accentColor, bool isDark) {
    final isVisible = _visiblePasswords[entry.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showPasswordDetailsModal(context, entry, accentColor, isDark),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          entry.title.isNotEmpty ? entry.title[0].toUpperCase() : '?',
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(entry.username, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Provider.of<VaultProvider>(context, listen: false).toggleFavorite(entry.id),
                      icon: Icon(
                        entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: entry.isFavorite ? const Color(0xFFFF6B6B) : AppColors.textSecondary.withValues(alpha: 0.3),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF25252D) : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isVisible ? entry.password : '•' * 12,
                          style: GoogleFonts.jetBrainsMono(fontSize: 14, letterSpacing: isVisible ? 0.5 : 3),
                        ),
                      ),
                      _smallAction(
                        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        () => setState(() => _visiblePasswords[entry.id] = !isVisible),
                      ),
                      const SizedBox(width: 4),
                      _smallAction(Icons.copy_outlined, () {
                        Clipboard.setData(ClipboardData(text: entry.password));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password copied', style: GoogleFonts.outfit()), behavior: SnackBarBehavior.floating));
                      }),
                      const SizedBox(width: 4),
                      _smallAction(Icons.delete_outline_rounded, () {
                        Provider.of<VaultProvider>(context, listen: false).removeEntry(entry.id);
                      }, color: const Color(0xFFFF6B6B)),
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

  Widget _smallAction(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
      ),
    );
  }

  void _showPasswordDetailsModal(BuildContext context, PasswordEntry entry, Color accentColor, bool isDark) {
    bool isPasswordVisibleInModal = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(modalContext).padding.bottom + 28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A20) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            entry.title.isNotEmpty ? entry.title[0].toUpperCase() : '?',
                            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: accentColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(entry.category, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EditPasswordScreen(entry: entry)));
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(Icons.edit_rounded, color: accentColor, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _modalDetailRow(modalContext, 'USERNAME / EMAIL / CODE', entry.username, Icons.person_outline_rounded, accentColor, isDark, onCopy: () {
                    Clipboard.setData(ClipboardData(text: entry.username));
                    ScaffoldMessenger.of(modalContext).showSnackBar(SnackBar(content: Text('Username copied', style: GoogleFonts.outfit())));
                  }),
                  const SizedBox(height: 20),
                  _modalDetailRow(
                    modalContext,
                    'PASSWORD',
                    isPasswordVisibleInModal ? entry.password : '••••••••••••',
                    Icons.lock_outline_rounded,
                    accentColor,
                    isDark,
                    isPassword: true,
                    isPasswordVisible: isPasswordVisibleInModal,
                    onToggleVisibility: () => setModalState(() => isPasswordVisibleInModal = !isPasswordVisibleInModal),
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: entry.password));
                      ScaffoldMessenger.of(modalContext).showSnackBar(SnackBar(content: Text('Password copied', style: GoogleFonts.outfit())));
                    },
                  ),
                  if (entry.website != null && entry.website!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _modalDetailRow(modalContext, 'WEBSITE URL', entry.website!, Icons.link_rounded, accentColor, isDark, onCopy: () {
                      Clipboard.setData(ClipboardData(text: entry.website!));
                      ScaffoldMessenger.of(modalContext).showSnackBar(SnackBar(content: Text('Website URL copied', style: GoogleFonts.outfit())));
                    }),
                  ],
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _modalDetailRow(modalContext, 'NOTES', entry.notes!, Icons.notes_rounded, accentColor, isDark),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditPasswordScreen(entry: entry)));
                      },
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: Text('EDIT ENTRY', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
          },
        );
      },
    );
  }

  Widget _modalDetailRow(BuildContext context, String label, String value, IconData icon, Color accentColor, bool isDark,
      {bool isPassword = false, bool isPasswordVisible = false, VoidCallback? onToggleVisibility, VoidCallback? onCopy}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withValues(alpha: 0.6), letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF25252D) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  value,
                  style: isPassword ? GoogleFonts.jetBrainsMono(fontSize: 15, letterSpacing: isPasswordVisible ? 0 : 2) : GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              if (isPassword && onToggleVisibility != null) ...[
                GestureDetector(
                  onTap: onToggleVisibility,
                  child: Padding(padding: const EdgeInsets.all(4), child: Icon(isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 8),
              ],
              if (onCopy != null) ...[
                GestureDetector(
                  onTap: onCopy,
                  child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.copy_rounded, size: 20, color: AppColors.textSecondary)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 72, color: AppColors.textSecondary.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            'Your vault is empty',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
