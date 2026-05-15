import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/theme_provider.dart';
import 'home/home_screen.dart';
import 'vault/vault_screen.dart';
import 'add/add_password_screen.dart';
import 'generator/generator_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late PageController _pageController;
  late AnimationController _navController;
  late Animation<double> _navAnimation;

  final List<Widget> _pages = const [
    VaultScreen(),
    AddPasswordScreen(),
    HomeScreen(),
    GeneratorScreen(),
    SettingsScreen(),
  ];

  final List<IconData> _icons = [
    Icons.shield_rounded,
    Icons.add_box_rounded,
    Icons.home_rounded,
    Icons.auto_awesome_rounded,
    Icons.settings_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 2);
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _navAnimation = Tween<double>(begin: 2.0, end: 2.0).animate(
      CurvedAnimation(parent: _navController, curve: Curves.easeOutCubic),
    );
  }

  void _onPageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _navAnimation = Tween<double>(begin: _navAnimation.value, end: index.toDouble()).animate(
        CurvedAnimation(parent: _navController, curve: Curves.easeOutCubic),
      );
    });
    _navController.forward(from: 0);
  }

  void _navigateToPage(int index) {
    if (_currentIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(accentColor, isDark),
    );
  }

  Widget _buildBottomNav(Color accentColor, bool isDark) {
    final double width = MediaQuery.of(context).size.width;
    final double itemWidth = width / 5;
    final navColor = isDark ? const Color(0xFF1A1A20) : Colors.white;

    return AnimatedBuilder(
      animation: _navAnimation,
      builder: (context, child) {
        return Container(
          height: 80,
          width: width,
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Custom Curved Background with Continuous Path Logic
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(width, 80),
                  painter: CurvedNavPainter(
                    animatedIndex: _navAnimation.value,
                    color: navColor,
                    accentColor: accentColor,
                  ),
                ),
              ),
              
              // 2. Zero-Gap Alignment: Active Icon docked perfectly into the dip
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutBack,
                left: _currentIndex * itemWidth + (itemWidth - 64) / 2,
                top: -14, // Top at -32, Bottom at 32 (Docked 12px deep into the 44px dip)
                child: GestureDetector(
                  onTap: () => _navigateToPage(_currentIndex),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      // 3. Shadow Integration: Merged shadows
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _icons[_currentIndex],
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              // Icons Row
              Row(
                children: List.generate(5, (index) {
                  final isSelected = _currentIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToPage(index),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 0.0 : 0.5,
                          child: Icon(
                            _icons[index],
                            size: 26,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CurvedNavPainter extends CustomPainter {
  final double animatedIndex;
  final Color color;
  final Color accentColor;

  CurvedNavPainter({
    required this.animatedIndex,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final itemWidth = size.width / 5;
    final centerX = animatedIndex * itemWidth + itemWidth / 2;

    // Parameters for the smooth merge
    const double dipWidth = 72;
    const double dipHeight = 44;

    path.moveTo(0, 0);
    
    // Start drawing the bar top edge
    path.lineTo(centerX - dipWidth, 0);

    // Continuous Path: Creating the cradled 'dip'
    path.cubicTo(
      centerX - 40, 0,
      centerX - 35, dipHeight,
      centerX, dipHeight,
    );
    path.cubicTo(
      centerX + 35, dipHeight,
      centerX + 40, 0,
      centerX + dipWidth, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Shadow Integration: Draw a unified shadow for the entire shape
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.15), 10, false);
    canvas.drawPath(path, paint);

    // Drawing a small colored 'bridge' to enhance the merged look
    final bridgePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Optional: add a subtle ring around the dip to show the "physical connection"
    final ringPath = Path();
    ringPath.moveTo(centerX - 40, 0);
    ringPath.cubicTo(
      centerX - 35, 0,
      centerX - 30, dipHeight - 2,
      centerX, dipHeight - 2,
    );
    ringPath.cubicTo(
      centerX + 30, dipHeight - 2,
      centerX + 35, 0,
      centerX + 40, 0,
    );
    // canvas.drawPath(ringPath, bridgePaint); // Uncomment for extra detail if needed
  }

  @override
  bool shouldRepaint(covariant CurvedNavPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex || oldDelegate.color != color;
  }
}
