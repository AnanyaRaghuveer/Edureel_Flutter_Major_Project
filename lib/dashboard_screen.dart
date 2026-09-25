import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'api_service.dart';
import 'pages.dart';
import 'screens/academic_mentor_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String accessToken;
  final VoidCallback onNavigateToFeed;
  const DashboardScreen({
    super.key,
    required this.accessToken,
    required this.onNavigateToFeed,
  });

  @override
  Widget build(BuildContext context) {
    final name = userName.trim().isEmpty ? 'there' : userName.trim();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppVisualBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GOOD EVENING',
                            style: TextStyle(
                              color: context.appSubtleText,
                              fontSize: 11,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'What are you curious\nabout, $name?',
                            style: TextStyle(
                              color: context.appText,
                              fontSize: 28,
                              height: 1.05,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ProfileOrb(
                      onTap: () => _openPage(
                        context,
                        ProfilePage(accessToken: accessToken),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  radius: 18,
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: context.appSubtleText,
                        size: 21,
                      ),
                      const SizedBox(width: 11),
                      Text(
                        'Search your learning universe',
                        style: TextStyle(
                          color: context.appSubtleText,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.tune_rounded,
                        color: context.appSubtleText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const _SectionTitle('FEATURED FOR YOU'),
                const SizedBox(height: 12),
                _FeaturedLearningCard(
                  title: headings[2],
                  category: topics[2].replaceFirst('TOPIC 3: ', ''),
                  onTap: () {
                    jumpToSlide(2);
                    onNavigateToFeed();
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle('CONTINUE LEARNING'),
                    Text(
                      'VIEW ALL',
                      style: TextStyle(
                        color: context.appAccent,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 174,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _ContinueCard(
                      index: index,
                      onTap: () {
                        jumpToSlide(index);
                        onNavigateToFeed();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const _SectionTitle('YOUR RHYTHM'),
                const SizedBox(height: 12),
                const _ProgressCard(),
                const SizedBox(height: 30),
                const _SectionTitle('EXPLORE THE STUDIO'),
                const SizedBox(height: 12),
                _StudioRow(
                  icon: Icons.today_rounded,
                  title: 'Today\'s Plan',
                  detail: '2 reels to study',
                  onTap: () => _openPage(
                    context,
                    TodaysPlanPage(
                      onOpenReel: (index) {
                        Navigator.pop(context);
                        jumpToSlide(index);
                        onNavigateToFeed();
                      },
                    ),
                  ),
                ),
                _StudioRow(
                  icon: Icons.menu_book_rounded,
                  title: 'My Subjects',
                  detail: '4 active subjects',
                  onTap: () => _openPage(context, const SubjectsPage()),
                ),
                _StudioRow(
                  icon: Icons.quiz_outlined,
                  title: 'Quizzes',
                  detail: 'Test yourself',
                  onTap: () =>
                      _openPage(context, QuizzesPage(accessToken: accessToken)),
                ),
                _StudioRow(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI Tutor',
                  detail: 'Ask anything',
                  onTap: () => _openPage(context, const AcademicMentorScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _ProfileOrb extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileOrb({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF293B41),
        border: Border.all(color: const Color(0x4DB9D4D9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Color(0xFFB9D4D9),
        size: 22,
      ),
    ),
  );
}

class _FeaturedLearningCard extends StatelessWidget {
  final String title;
  final String category;
  final VoidCallback onTap;
  const _FeaturedLearningCard({
    required this.title,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 236,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF28464D), Color(0xFF111D22)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -36,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x227EAEB6),
              ),
            ),
          ),
          Positioned(
            right: 28,
            top: 30,
            child: Icon(
              Icons.storage_rounded,
              size: 94,
              color: const Color(0x287EAEB6),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EDITOR\'S PICK',
                    style: TextStyle(
                      color: const Color(0xFFB9D4D9).withValues(alpha: .82),
                      fontSize: 10,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFFB9D4D9),
                      fontSize: 10,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 240,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.05,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB9D4D9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF102026),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ContinueCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;
  const _ContinueCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF314B50).withValues(alpha: .9),
                    const Color(0xFF18262B),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Text(
                      '0${index + 1}',
                      style: const TextStyle(
                        color: Color(0x55FFFFFF),
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xBFB9D4D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF102026),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topics[index].replaceFirst('TOPIC ${index + 1}: ', ''),
            style: TextStyle(
              color: context.appSubtleText,
              fontSize: 9,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            headings[index],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.appText,
              fontSize: 13,
              height: 1.15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class _StudioRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  const _StudioRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: context.appAccent, size: 21),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.appText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(color: context.appSubtleText, fontSize: 11),
                ),
              ],
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
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: context.appText,
      fontSize: 12,
      letterSpacing: 1.5,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(9),
    radius: 14,
    child: Icon(icon, color: context.appMutedText, size: 20),
  );
}

class _DashboardTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _DashboardTile({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 142,
    child: GlassPanel(
      padding: const EdgeInsets.all(13),
      radius: 20,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF789BA1).withValues(alpha: .16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.appAccent, size: 25),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: context.appText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: context.appSubtleText, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

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
  final String value;
  final String label;
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

class TodaysPlanPage extends StatelessWidget {
  final ValueChanged<int> onOpenReel;
  const TodaysPlanPage({super.key, required this.onOpenReel});

  @override
  Widget build(BuildContext context) => _DashboardDetailPage(
    title: 'Today\'s Plan',
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'A focused plan from your reels',
          style: TextStyle(
            color: context.appText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Complete these two short lessons to reach today\'s goal.',
          style: TextStyle(color: context.appSubtleText, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _PlanReelCard(index: 2, duration: '8 min', onTap: () => onOpenReel(2)),
        const SizedBox(height: 12),
        _PlanReelCard(index: 3, duration: '10 min', onTap: () => onOpenReel(3)),
      ],
    ),
  );
}

class _PlanReelCard extends StatelessWidget {
  final int index;
  final String duration;
  final VoidCallback onTap;
  const _PlanReelCard({
    required this.index,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(16),
    radius: 20,
    onTap: onTap,
    child: Row(
      children: [
        _RoundIcon(Icons.play_arrow_rounded, context.appAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topics[index].replaceFirst('TOPIC ${index + 1}: ', ''),
                style: TextStyle(
                  color: context.appAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                headings[index],
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$duration reel',
                style: TextStyle(color: context.appSubtleText, fontSize: 12),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_rounded, color: context.appAccent),
      ],
    ),
  );
}

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) => _DashboardDetailPage(
    title: 'My Subjects',
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        _SubjectCard(
          'DBMS',
          '6 of 10 lessons completed',
          Icons.storage_rounded,
          .60,
        ),
        _SubjectCard(
          'Operating Systems',
          '4 of 9 lessons completed',
          Icons.memory_rounded,
          .44,
        ),
        _SubjectCard(
          'AI / ML',
          '3 of 8 lessons completed',
          Icons.auto_awesome_rounded,
          .38,
        ),
        _SubjectCard(
          'Computer Networks',
          '5 of 10 lessons completed',
          Icons.hub_rounded,
          .50,
        ),
      ],
    ),
  );
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  const _SubjectCard(this.title, this.subtitle, this.icon, this.progress);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        children: [
          Row(
            children: [
              _RoundIcon(icon, context.appAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.appSubtleText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.appAccent),
            ],
          ),
          const SizedBox(height: 14),
          _Bar(value: progress, color: context.appAccent),
        ],
      ),
    ),
  );
}

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({required this.accessToken, super.key});

  final String accessToken;

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  ReelQuiz? _quiz;
  String? _error;
  bool _loading = true;
  int? selectedAnswer;
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final reels = await EduReelApi().getList('/api/reels');
      if (reels.isEmpty) throw StateError('No reels are available for a quiz.');
      final firstReel = Map<String, dynamic>.from(reels.first as Map);
      final reelId = (firstReel['id'] as num).toInt();
      final response = await EduReelApi().getJson('/api/reels/$reelId/quiz');
      if (!mounted) return;
      setState(() {
        _quiz = ReelQuiz.fromJson(response);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _DashboardDetailPage(
    title: 'Quizzes',
    child: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text(_error!, textAlign: TextAlign.center))
        : _quiz == null || _quiz!.questions.isEmpty
        ? const Center(child: Text('No quiz questions available.'))
        : ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                _quiz!.title,
                style: TextStyle(
                  color: context.appText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_quiz!.description?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Text(
                  _quiz!.description!,
                  style: TextStyle(color: context.appMutedText),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                'Question 1 of ${_quiz!.questions.length}',
                style: TextStyle(
                  color: context.appAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              GlassPanel(
                padding: const EdgeInsets.all(18),
                radius: 20,
                child: Text(
                  _quiz!.questions.first.question,
                  style: TextStyle(
                    color: context.appText,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ..._quiz!.questions.first.options.asMap().entries.map(
                (entry) => _QuizAnswer(
                  label: entry.value.text,
                  isSelected: selectedAnswer == entry.key,
                  isCorrect: false,
                  showResult: false,
                  onTap: () => setState(() {
                    if (!submitted) selectedAnswer = entry.key;
                  }),
                ),
              ),
              const SizedBox(height: 10),
              AppPrimaryButton(
                onPressed: selectedAnswer == null || submitted
                    ? null
                    : () => setState(() => submitted = true),
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(submitted ? 'Answer submitted' : 'Submit answer'),
              ),
            ],
          ),
  );
}

class _QuizAnswer extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;
  const _QuizAnswer({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncorrectSelection = showResult && isSelected && !isCorrect;
    final color = showResult && isCorrect
        ? Colors.green
        : isIncorrectSelection
        ? Colors.redAccent
        : context.appAccent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        radius: 16,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected || (showResult && isCorrect)
                  ? color
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                showResult && isCorrect
                    ? Icons.check_circle_rounded
                    : isIncorrectSelection
                    ? Icons.cancel_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: color,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatbotPlaceholderPage extends StatelessWidget {
  const ChatbotPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) => _DashboardDetailPage(
    title: 'AI Tutor',
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: GlassPanel(
          padding: const EdgeInsets.all(28),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundIcon(Icons.smart_toy_outlined, context.appAccent),
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
                style: TextStyle(color: context.appSubtleText, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DashboardDetailPage extends StatelessWidget {
  final String title;
  final Widget child;
  const _DashboardDetailPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appBackground,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: context.appBackground,
      foregroundColor: context.appText,
      surfaceTintColor: Colors.transparent,
    ),
    body: AppVisualBackground(child: SafeArea(top: false, child: child)),
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
