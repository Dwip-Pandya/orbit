import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/theme_provider.dart';

class AccentColorScreen extends StatefulWidget {
  const AccentColorScreen({super.key});

  @override
  State<AccentColorScreen> createState() => _AccentColorScreenState();
}

class _AccentColorScreenState extends State<AccentColorScreen> {
  final List<Map<String, dynamic>> _allColors = [
    {'name': 'Royal Blue', 'color': Color(0xFF5B67F1)},
    {'name': 'Indigo Mist', 'color': Color(0xFF6C63FF)},
    {'name': 'Electric Violet', 'color': Color(0xFF7C4DFF)},
    {'name': 'Deep Purple', 'color': Color(0xFF8E44AD)},
    {'name': 'Cyber Lavender', 'color': Color(0xFF9B59B6)},
    {'name': 'Sky Blue', 'color': Color(0xFF4A90E2)},
    {'name': 'Ocean Blue', 'color': Color(0xFF007AFF)},
    {'name': 'Azure Glow', 'color': Color(0xFF3A86FF)},
    {'name': 'Neon Blue', 'color': Color(0xFF2563EB)},
    {'name': 'Sapphire', 'color': Color(0xFF0F52BA)},
    {'name': 'Aqua Cyan', 'color': Color(0xFF00BCD4)},
    {'name': 'Turquoise', 'color': Color(0xFF1ABC9C)},
    {'name': 'Mint Green', 'color': Color(0xFF2ECC71)},
    {'name': 'Emerald', 'color': Color(0xFF27AE60)},
    {'name': 'Lime Green', 'color': Color(0xFF84CC16)},
    {'name': 'Soft Olive', 'color': Color(0xFF6B8E23)},
    {'name': 'Golden Yellow', 'color': Color(0xFFF4B400)},
    {'name': 'Amber', 'color': Color(0xFFFFB300)},
    {'name': 'Orange Glow', 'color': Color(0xFFFF9800)},
    {'name': 'Sunset Orange', 'color': Color(0xFFFF7043)},
    {'name': 'Coral Red', 'color': Color(0xFFFF6B6B)},
    {'name': 'Crimson', 'color': Color(0xFFDC3545)},
    {'name': 'Rose Pink', 'color': Color(0xFFFF4D8D)},
    {'name': 'Hot Pink', 'color': Color(0xFFE91E63)},
    {'name': 'Magenta', 'color': Color(0xFFD633FF)},
    {'name': 'Soft Peach', 'color': Color(0xFFFF9E80)},
    {'name': 'Blush Pink', 'color': Color(0xFFF78FB3)},
    {'name': 'Lavender', 'color': Color(0xFFB388FF)},
    {'name': 'Periwinkle', 'color': Color(0xFF8FA8FF)},
    {'name': 'Ice Blue', 'color': Color(0xFFA7C7FF)},
    {'name': 'Arctic Cyan', 'color': Color(0xFF7FDBFF)},
    {'name': 'Teal Blue', 'color': Color(0xFF008080)},
    {'name': 'Sea Green', 'color': Color(0xFF2E8B57)},
    {'name': 'Forest Green', 'color': Color(0xFF228B22)},
    {'name': 'Neon Mint', 'color': Color(0xFF00E5A8)},
    {'name': 'Lemon Lime', 'color': Color(0xFFCDDC39)},
    {'name': 'Soft Gold', 'color': Color(0xFFD4AF37)},
    {'name': 'Bronze', 'color': Color(0xFFCD7F32)},
    {'name': 'Burnt Orange', 'color': Color(0xFFD97706)},
    {'name': 'Ruby Red', 'color': Color(0xFFC2185B)},
    {'name': 'Wine Purple', 'color': Color(0xFF722F37)},
    {'name': 'Plum', 'color': Color(0xFF8E4585)},
    {'name': 'Midnight Blue', 'color': Color(0xFF1E3A8A)},
    {'name': 'Slate Blue', 'color': Color(0xFF5A67D8)},
    {'name': 'Graphite', 'color': Color(0xFF4B5563)},
    {'name': 'Charcoal', 'color': Color(0xFF36454F)},
    {'name': 'Steel Blue', 'color': Color(0xFF4682B4)},
    {'name': 'Frost Violet', 'color': Color(0xFFA78BFA)},
    {'name': 'Soft Cyan', 'color': Color(0xFF67E8F9)},
    {'name': 'Neon Purple', 'color': Color(0xFF9333EA)},
  ];

  List<Map<String, dynamic>> _filteredColors = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredColors = _allColors;
    _searchController.addListener(_filterColors);
  }

  void _filterColors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredColors = _allColors
          .where((c) => c['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, accentColor, isDark),
          _buildSearchBar(accentColor, isDark),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
              itemCount: _filteredColors.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final name = _filteredColors[index]['name'];
                final color = _filteredColors[index]['color'];
                final isSelected = accentColor.value == color.value;

                return GestureDetector(
                  onTap: () => _showConfirmation(context, color, name, themeProvider),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A20) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? Border.all(color: color, width: 2) : null,
                    ),
                    child: Row(
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                              : null,
                        ),
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

  Widget _buildHeader(BuildContext context, Color accentColor, bool isDark) {
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
          Text(
            'Accent Color',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color accentColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.outfit(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search 50 premium colors...',
          prefixIcon: Icon(Icons.search_rounded, color: accentColor),
          fillColor: isDark ? const Color(0xFF1A1A20) : Colors.white,
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context, Color color, String name, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              child: Icon(Icons.palette_rounded, color: color, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Switch to $name?',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Apply this color across the app?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
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
                  onPressed: () {
                    provider.setAccentColor(color);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Confirm', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
