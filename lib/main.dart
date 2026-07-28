import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: Container(
          color: context.appSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            children: [
              _NavTab(
                icon: Icons.play_arrow,
                label: "REELS",
                isSelected: selectedIndex == 0,
                onTap: () => onItemTapped(0),
              ),
              const SizedBox(width: 8),
              _NavTab(
                icon: Icons.dashboard,
                label: "DASHBOARD",
                isSelected: selectedIndex == 1,
                onTap: () => onItemTapped(1),
              ),
              const SizedBox(width: 8),
              _NavTab(
                icon: Icons.menu,
                label: "MENU",
                isSelected: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
            ],
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
            color: isSelected ? context.appAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? context.appOnAccent : context.appText,
                size: 20,
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? context.appOnAccent : context.appText,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.8,
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
      body: ListView(
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
      body: ListView(
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
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
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
              );
            },
          ),
        ],
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
    return ListTile(
      leading: Icon(icon, color: context.appAccent),
      title: Text(label, style: TextStyle(color: context.appText)),
      trailing: Icon(Icons.chevron_right, color: context.appMutedText),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }
}
