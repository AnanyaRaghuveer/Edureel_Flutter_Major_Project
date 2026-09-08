import 'package:flutter/material.dart';
import 'dart:ui';
import 'app_state.dart';
import 'app_theme.dart';
import 'reel_screen.dart';
import 'dashboard_screen.dart';
import 'pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  void onItemTapped(int index) => setState(() => selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          ReelScreen(
            onStateChanged: () => setState(() {}),
            isActive: selectedIndex == 0,
          ),
          DashboardScreen(
            onNavigateToFeed: () => setState(() => selectedIndex = 0),
          ),
          const _MenuScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: context.appNavigation,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: context.isDarkMode
                      ? const Color(0x4DFFFFFF)
                      : const Color(0x26000000),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDarkMode ? 0.34 : 0.12,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              child: Row(
                children: [
                  _NavTab(
                    icon: Icons.play_arrow_rounded,
                    label: "REELS",
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemTapped(0),
                  ),
                  _NavTab(
                    icon: Icons.grid_view_rounded,
                    label: "DASHBOARD",
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemTapped(1),
                  ),
                  _NavTab(
                    icon: Icons.person_outline_rounded,
                    label: "MENU",
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemTapped(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? (context.isDarkMode
                      ? const Color(0xFF303030)
                      : const Color(0xFFEAEAEA))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: context.isDarkMode ? 0.28 : 0.10,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? (context.isDarkMode ? context.appOnDark : context.appText)
                    : context.appText.withValues(alpha: 0.72),
                size: 19,
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (context.isDarkMode
                            ? context.appOnDark
                            : context.appText)
                      : context.appText.withValues(alpha: 0.72),
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuScreen extends StatelessWidget {
  const _MenuScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AppVisualBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Profile',
              page: const ProfilePage(),
            ),
            _MenuItem(
              icon: Icons.favorite_border,
              label: 'Liked Videos',
              page: const LikedVideosPage(),
            ),
            _MenuItem(
              icon: Icons.bookmark_border,
              label: 'Saved Videos',
              page: const SavedVideosPage(),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              page: const _SettingsPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AppVisualBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: appThemeMode,
              builder: (context, themeMode, child) {
                final isDarkMode = themeMode == ThemeMode.dark;
                return GlassPanel(
                  padding: EdgeInsets.zero,
                  radius: 20,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    secondary: Icon(
                      isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: context.appAccent,
                    ),
                    title: Text(
                      isDarkMode ? 'Dark mode' : 'Light mode',
                      style: TextStyle(color: context.appText),
                    ),
                    subtitle: Text(
                      isDarkMode
                          ? 'Dark appearance is on'
                          : 'Light appearance is on',
                      style: TextStyle(color: context.appMutedText),
                    ),
                    value: isDarkMode,
                    activeThumbColor: context.appAccent,
                    onChanged: (enabled) {
                      appThemeMode.value = enabled
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.page,
  });

  final IconData icon;
  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        radius: 20,
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appAccent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.appAccent),
          ),
          title: Text(label, style: TextStyle(color: context.appText)),
          trailing: Icon(Icons.chevron_right, color: context.appMutedText),
        ),
      ),
    );
  }
}
