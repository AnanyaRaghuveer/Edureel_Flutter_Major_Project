import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'pages.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToFeed;
  const DashboardScreen({super.key, required this.onNavigateToFeed});

  @override
  Widget build(BuildContext context) {
    final name = userName.trim().isEmpty ? 'there' : userName.trim();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppVisualBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Good morning, $name!',
                        style: TextStyle(
                          color: context.appText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _HeaderIcon(
                      icon: Icons.notifications_none_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _HeaderIcon(
                      icon: Icons.person_outline_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle('Today\'s Goal'),
                const SizedBox(height: 10),
                _GoalCard(onContinue: onNavigateToFeed),
                const SizedBox(height: 24),
                _SectionTitle('Continue Learning'),
                const SizedBox(height: 10),
                _LearningCard(onContinue: onNavigateToFeed),
                const SizedBox(height: 24),
                _SectionTitle('My Subjects'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: const [
                    _SubjectChip('DBMS', Icons.storage_rounded),
                    _SubjectChip('OS', Icons.memory_rounded),
                    _SubjectChip('AI / ML', Icons.auto_awesome_rounded),
                    _SubjectChip('CN', Icons.hub_rounded),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle('Upcoming'),
                const SizedBox(height: 10),
                _UpcomingCard(),
                const SizedBox(height: 24),
                _SectionTitle('Your Progress'),
                const SizedBox(height: 10),
                _ProgressCard(),
                const SizedBox(height: 24),
                _SectionTitle('Ask AI Tutor'),
                const SizedBox(height: 10),
                _TutorCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatbotPlaceholderPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: context.appText,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIcon({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(9),
    radius: 14,
    onTap: onTap,
    child: Icon(icon, color: context.appMutedText, size: 20),
  );
}

class _GoalCard extends StatelessWidget {
  final VoidCallback onContinue;
  const _GoalCard({required this.onContinue});
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    radius: 20,
    gradient: LinearGradient(
      colors: [
        context.appAccent.withValues(alpha: .25),
        context.appPanelBottom,
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _RoundIcon(Icons.track_changes_rounded, context.appAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Build a consistent learning habit',
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              '28 / 45 min',
              style: TextStyle(
                color: context.appAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Bar(value: .62, color: context.appAccent),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: _ActionButton(label: 'Continue Learning', onTap: onContinue),
        ),
      ],
    ),
  );
}

class _LearningCard extends StatelessWidget {
  final VoidCallback onContinue;
  const _LearningCard({required this.onContinue});
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    radius: 20,
    child: Row(
      children: [
        _RoundIcon(Icons.menu_book_rounded, const Color(0xFFB0B0B0)),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DBMS',
                style: TextStyle(
                  color: context.appAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'SQL & Normalization',
                style: TextStyle(
                  color: context.appText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _Bar(value: .65, color: const Color(0xFFB0B0B0)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ActionButton(label: 'Continue', onTap: onContinue),
      ],
    ),
  );
}

class _SubjectChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SubjectChip(this.label, this.icon);
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    radius: 15,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: context.appAccent, size: 17),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _UpcomingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    radius: 20,
    child: Row(
      children: [
        _RoundIcon(Icons.quiz_outlined, context.appAccent),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DBMS Quiz',
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'SQL & Normalization',
                style: TextStyle(color: context.appSubtleText, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          'Tomorrow',
          style: TextStyle(
            color: context.appAccent,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
    radius: 20,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _Metric('24', 'Lessons'),
        _Metric('12h 40m', 'Study time'),
        _Metric('86%', 'Average'),
        _Metric('7', 'Day streak', fire: true),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  final String value, label;
  final bool fire;
  const _Metric(this.value, this.label, {this.fire = false});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        fire ? '🔥 $value' : value,
        style: TextStyle(
          color: context.appText,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: context.appSubtleText, fontSize: 10)),
    ],
  );
}

class _TutorCard extends StatelessWidget {
  final VoidCallback onTap;
  const _TutorCard({required this.onTap});

  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    radius: 20,
    onTap: onTap,
    gradient: LinearGradient(
      colors: [
        const Color(0xFF555555).withValues(alpha: .24),
        context.appPanelBottom,
      ],
    ),
    child: Row(
      children: [
        _RoundIcon(Icons.smart_toy_outlined, const Color(0xFFB0B0B0)),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            'What do you want to learn today?',
            style: TextStyle(
              color: context.appText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(Icons.arrow_forward_rounded, color: context.appAccent),
      ],
    ),
  );
}

class ChatbotPlaceholderPage extends StatelessWidget {
  const ChatbotPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: AppVisualBackground(
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_rounded, color: context.appText),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(28),
                    radius: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoundIcon(
                          Icons.smart_toy_outlined,
                          const Color(0xFFB0B0B0),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'AI Tutor',
                          style: TextStyle(
                            color: context.appText,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your personal learning assistant is coming soon.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.appSubtleText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _RoundIcon(this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .18),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: color, size: 22),
  );
}

class _Bar extends StatelessWidget {
  final double value;
  final Color color;
  const _Bar({required this.value, required this.color});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: LinearProgressIndicator(
      value: value,
      minHeight: 8,
      backgroundColor: context.appFaintText.withValues(alpha: .18),
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.appAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.appOnAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
