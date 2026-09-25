import 'package:flutter/material.dart';
import 'dart:ui';
import 'app_state.dart';
import 'app_theme.dart';
import 'auth_service.dart';
import 'reel_screen.dart';
import 'dashboard_screen.dart';
import 'pages.dart';
import 'config/api_config.dart';
import 'services/rag_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  runApp(const MyApp());
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
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = GoogleAuthService();
  AuthSession? _session;
  String? _errorMessage;
  bool _isSigningIn = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final session = await _auth.loadSavedSession();
      if (!mounted || session == null) return;
      userName = session.name;
      setState(() => _session = session);
    } catch (_) {
      // If there is no saved Google session, show the normal sign-in screen.
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });
    try {
      final session = await _auth.signIn();
      if (!mounted) return;
      await _auth.saveSession(session);
      userName = session.name;
      setState(() => _session = session);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } finally {
      await _auth.clearSavedSession();
      // Clear the local session even if the Google SDK reports an error, so
      // the user is never left inside EduReel with stale credentials.
      likedReels.clear();
      reelsById.clear();
      savedReelsByFolder.clear();
      if (mounted) setState(() => _session = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session != null) {
      return HomeScreen(accessToken: session.accessToken, onSignOut: _signOut);
    }
    return _GoogleSignInScreen(
      isSigningIn: _isSigningIn,
      errorMessage: _errorMessage,
      onSignIn: _signIn,
    );
  }
}

class _GoogleSignInScreen extends StatelessWidget {
  const _GoogleSignInScreen({
    required this.isSigningIn,
    required this.errorMessage,
    required this.onSignIn,
  });

  final bool isSigningIn;
  final String? errorMessage;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppVisualBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: GlassPanel(
              padding: const EdgeInsets.all(24),
              radius: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: context.appAccent,
                    size: 52,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to EduReel',
                    style: TextStyle(
                      color: context.appText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to keep your learning experience personal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.appMutedText),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSigningIn ? null : onSignIn,
                      icon: isSigningIn
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(
                        isSigningIn ? 'Signing in...' : 'Continue with Google',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.accessToken,
    required this.onSignOut,
    super.key,
  });

  final String accessToken;
  final Future<void> Function() onSignOut;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 1;
  String? _reelToOpen;

  void onItemTapped(int index) => setState(() => selectedIndex = index);

  void _openReel(String reelId) {
    setState(() {
      _reelToOpen = reelId;
      selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          ReelScreen(
            accessToken: widget.accessToken,
            onStateChanged: () => setState(() {}),
            isActive: selectedIndex == 0,
            reelToOpenId: _reelToOpen,
            onReelOpened: () => setState(() => _reelToOpen = null),
          ),
          DashboardScreen(
            accessToken: widget.accessToken,
            onNavigateToFeed: () => setState(() => selectedIndex = 0),
          ),
          _MenuScreen(
            accessToken: widget.accessToken,
            onSignOut: widget.onSignOut,
            onOpenReel: _openReel,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: context.appNavigation,
                borderRadius: BorderRadius.circular(28),
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
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
                      ? const Color(0xFF31454B)
                      : const Color(0xFFEAEAEA))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF7EADB4,
                      ).withValues(alpha: context.isDarkMode ? 0.18 : 0.10),
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
                  fontWeight: FontWeight.w600,
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
  const _MenuScreen({
    required this.accessToken,
    required this.onSignOut,
    required this.onOpenReel,
  });

  final String accessToken;
  final Future<void> Function() onSignOut;
  final ValueChanged<String> onOpenReel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppVisualBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 130),
            children: [
              Text(
                'YOUR SPACE',
                style: TextStyle(
                  color: context.appSubtleText,
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A quieter place\nfor your learning.',
                style: TextStyle(
                  color: context.appText,
                  fontSize: 30,
                  height: 1.05,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF293B41),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFFB9D4D9),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.trim().isEmpty
                              ? 'EduReel learner'
                              : userName.trim(),
                          style: TextStyle(
                            color: context.appText,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your personal media library',
                          style: TextStyle(
                            color: context.appSubtleText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: context.appSubtleText,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GlassPanel(
                padding: const EdgeInsets.symmetric(vertical: 18),
                radius: 22,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _SpaceMetric('24', 'LESSONS'),
                    _SpaceMetric('12h', 'WATCHED'),
                    _SpaceMetric('86%', 'PROGRESS'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'LIBRARY',
                style: TextStyle(
                  color: context.appSubtleText,
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Profile',
                page: ProfilePage(accessToken: accessToken),
              ),
              _MenuItem(
                icon: Icons.favorite_border,
                label: 'Liked Videos',
                page: LikedVideosPage(onOpenReel: onOpenReel),
              ),
              _MenuItem(
                icon: Icons.bookmark_border,
                label: 'Saved Videos',
                page: SavedVideosPage(onOpenReel: onOpenReel),
              ),
              const SizedBox(height: 24),
              Text(
                'PREFERENCES',
                style: TextStyle(
                  color: context.appSubtleText,
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _MenuItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                page: _SettingsPage(onSignOut: onSignOut),
              ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out'),
                style: TextButton.styleFrom(
                  foregroundColor: context.appSubtleText,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpaceMetric extends StatelessWidget {
  final String value;
  final String label;
  const _SpaceMetric(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: context.appText,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: TextStyle(
          color: context.appSubtleText,
          fontSize: 9,
          letterSpacing: 1.1,
        ),
      ),
    ],
  );
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await widget.onSignOut();
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

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
            const SizedBox(height: 24),
            _BackendConfigurationCard(),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _isSigningOut ? null : _signOut,
              icon: _isSigningOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
              label: Text(
                _isSigningOut ? 'Logging out...' : 'Log out of Google',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackendConfigurationCard extends StatefulWidget {
  @override
  State<_BackendConfigurationCard> createState() =>
      _BackendConfigurationCardState();
}

class _BackendConfigurationCardState extends State<_BackendConfigurationCard> {
  late final _controller = TextEditingController(text: ApiConfig.baseUrl);
  bool _testing = false;
  String? _status;
  bool? _connected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await ApiConfig.saveBaseUrl(_controller.text);
      if (mounted)
        setState(() {
          _status = 'Backend URL saved.';
          _connected = null;
        });
    } catch (error) {
      if (mounted)
        setState(() {
          _status = error.toString().replaceFirst('FormatException: ', '');
          _connected = false;
        });
    }
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _status = null;
    });
    try {
      final connected = await RagApiService().testConnection();
      if (mounted)
        setState(() {
          _connected = connected;
          _status = connected ? 'Connected ✓' : 'Backend unavailable ✗';
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _connected = false;
          _status = 'Backend unavailable ✗';
        });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    radius: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Backend Configuration',
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Change Backend URL',
          style: TextStyle(color: context.appMutedText, fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.url,
          style: TextStyle(color: context.appText),
          decoration: const InputDecoration(labelText: 'Backend URL'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _save,
                child: const Text('Save URL'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _testing ? null : _test,
                child: _testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Test Connection'),
              ),
            ),
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: 10),
          Text(
            _status!,
            style: TextStyle(
              color: _connected == true
                  ? Colors.green
                  : _connected == false
                  ? Colors.redAccent
                  : context.appMutedText,
            ),
          ),
        ],
      ],
    ),
  );
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: context.appAccent, size: 21),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.appText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                color: context.appSubtleText,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
