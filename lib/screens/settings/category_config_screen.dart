import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/vault_provider.dart';
import '../../providers/theme_provider.dart';

class CategoryConfigScreen extends StatelessWidget {
  const CategoryConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vault = Provider.of<VaultProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, vault, accentColor, isDark),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              itemCount: vault.categories.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final category = vault.categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A20) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(
                      category,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _actionButton(Icons.edit_outlined, () => _showCategoryDialog(context, vault, accentColor, isDark, oldName: category), accentColor),
                        const SizedBox(width: 8),
                        _actionButton(Icons.delete_outline_rounded, () => vault.removeCategory(category), const Color(0xFFFF6B6B)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VaultProvider vault, Color accentColor, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A20) : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Categories',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showCategoryDialog(context, vault, accentColor, isDark),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.add_rounded, color: accentColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, VaultProvider vault, Color accentColor, bool isDark, {String? oldName}) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A20) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          oldName == null ? 'Add Category' : 'Edit Category',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.outfit(),
          decoration: InputDecoration(
            hintText: 'e.g. Shopping',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor, width: 2)),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                if (oldName == null) {
                  vault.addCategory(controller.text);
                } else {
                  vault.editCategory(oldName, controller.text);
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
