import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'pages.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToFeed;
  const DashboardScreen({super.key, required this.onNavigateToFeed});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _navigateToSlide(int index) {
    jumpToSlide(index);
    widget.onNavigateToFeed();
  }

  @override
  Widget build(BuildContext context) {
    final totalSaved = savedFolders.values.fold<int>(0, (s, v) => s + v.length);

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      color: context.appText,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    userName.isEmpty ? 'User' : userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.appMutedText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),

              // ── Heading ──────────────────────────────────────────────────
              Text(
                "Learning Progress",
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: -1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Your daily knowledge intake at a glance.",
                style: TextStyle(color: context.appMutedText, fontSize: 14),
              ),
              SizedBox(height: 24),

              // ── Stats Grid ───────────────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                    icon: Icons.favorite,
                    iconColor: Colors.redAccent,
                    label: "Liked",
                    value: "${likedSlides.length}",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LikedVideosPage()),
                    ).then((_) => setState(() {})),
                  ),
                  SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.bookmark,
                    iconColor: context.appAccent,
                    label: "Saved",
                    value: "$totalSaved",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SavedVideosPage()),
                    ).then((_) => setState(() {})),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.folder,
                    iconColor: Color(0xFFFFB74D),
                    label: "Folders",
                    value: "${savedFolders.length}",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SavedVideosPage()),
                    ).then((_) => setState(() {})),
                  ),
                  SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.auto_stories,
                    iconColor: Color(0xFF9C7CFF),
                    label: "Topics",
                    value: "${topics.length}",
                  ),
                ],
              ),
              SizedBox(height: 24),

              // ── Deep Focus Card ──────────────────────────────────────────
              _InfoCard(
                gradient: LinearGradient(
                  colors: [
                    Color.alphaBlend(
                      context.appAccent.withValues(alpha: 0.18),
                      context.appSurface,
                    ),
                    context.appSurface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Row(
                  children: [
                    _IconBubble(Icons.psychology, context.appAccent),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Deep Focus",
                            style: TextStyle(
                              color: context.appText,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Keep going — you're on a streak!",
                            style: TextStyle(
                              color: context.appSubtleText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orangeAccent,
                      size: 28,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              // ── Accuracy Card ────────────────────────────────────────────
              _InfoCard(
                color: context.appSurface,
                child: Row(
                  children: [
                    _IconBubble(Icons.track_changes, context.appAccent),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Accuracy",
                            style: TextStyle(
                              color: context.appText,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Engage with slides for better recall.",
                            style: TextStyle(
                              color: context.appSubtleText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "--",
                      style: TextStyle(
                        color: context.appAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              // ── Completed & Streak ───────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      color: context.appSurface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: context.appAccent,
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "${likedSlides.length}",
                            style: TextStyle(
                              color: context.appText,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            "Completed",
                            style: TextStyle(
                              color: context.appSubtleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      color: context.appSurface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orangeAccent,
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "0",
                            style: TextStyle(
                              color: context.appText,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            "Day Streak",
                            style: TextStyle(
                              color: context.appSubtleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // ── Weekly Activity ──────────────────────────────────────────
              _InfoCard(
                color: context.appSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Activity",
                      style: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final days = ["M", "T", "W", "T", "F", "S", "S"];
                        final h = [0.4, 0.7, 0.5, 0.9, 0.3, 0.6, 0.2];
                        return Column(
                          children: [
                            Container(
                              width: 10,
                              height: 60 * h[i],
                              decoration: BoxDecoration(
                                color: context.appAccent.withValues(
                                  alpha: 0.5 + h[i] * 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              days[i],
                              style: TextStyle(
                                color: context.appSubtleText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // ── Continue Learning ────────────────────────────────────────
              Text(
                "Continue Learning",
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              ...List.generate(
                topics.length,
                (i) =>
                    _ContinueCard(index: i, onTap: () => _navigateToSlide(i)),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final VoidCallback? onTap;
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: context.appText,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: context.appSubtleText, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final LinearGradient? gradient;
  const _InfoCard({required this.child, this.color, this.gradient});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBubble(this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: color, size: 24),
  );
}

class _ContinueCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;
  const _ContinueCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(
              context.appAccent.withValues(alpha: 0.12),
              context.appSurface,
            ),
            context.appSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.appAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_circle_filled,
              color: context.appAccent,
              size: 22,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headings[index],
                  style: TextStyle(
                    color: context.appText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  topics[index],
                  style: TextStyle(color: context.appAccent, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: context.appFaintText, size: 16),
        ],
      ),
    ),
  );
}
