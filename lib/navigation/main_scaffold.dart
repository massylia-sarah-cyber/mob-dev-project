import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/dashboard_screen.dart';
import '../screens/main/favorites_screen.dart';
import '../screens/main/player_screen.dart';
import '../screens/main/about_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static _MainScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainScaffoldState>();
  }

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlayerScreen(),
    const FavoritesScreen(),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer.withValues(alpha: 0.8),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'Home'),
                      _buildNavItem(1, Icons.play_circle_rounded, 'Player'),
                      _buildNavItem(2, Icons.favorite_rounded, 'Favorites'),
                      _buildNavItem(3, Icons.dashboard_rounded, 'Dashboard'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_filled_rounded, size: 56, color: Colors.white),
                  const SizedBox(height: 16),
                  Text('MPLAY', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 4)),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: AppColors.onSurfaceVariant),
            title: const Text('Home', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              changeTab(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
            title: const Text('Profile', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              changeTab(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.onSurfaceVariant),
            title: const Text('About Mplay', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
            title: const Text('Settings', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Log Out', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10),
                ],
              )
            : const BoxDecoration(
                color: Colors.transparent,
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                letterSpacing: 2,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
