import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'auth_service.dart';
import 'api_service.dart';
import 'widgets.dart';

// ── Profile Page ──────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({required this.accessToken, super.key});

  final String accessToken;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _nameController = TextEditingController(text: userName);
  final _phoneController = TextEditingController(text: "");
  final _emailController = TextEditingController(text: "");
  final _institutionController = TextEditingController(text: "");

  // Predefined skill chips
  final List<String> _allSkills = [
    "Algorithms",
    "Data Structures",
    "Databases",
    "Operating Systems",
    "Networking",
    "Machine Learning",
    "Web Dev",
    "Mobile Dev",
    "Cybersecurity",
    "Cloud Computing",
  ];
  final Set<String> _selectedSkills = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await GoogleAuthService().fetchProfile(
        widget.accessToken,
      );
      if (!mounted) return;
      _nameController.text = profile.name;
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email;
      _institutionController.text = profile.institution ?? '';
      setState(() {
        _selectedSkills
          ..clear()
          ..addAll(profile.skills);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load profile: $error')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final profile = await GoogleAuthService().updateProfile(
        accessToken: widget.accessToken,
        profile: UserProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim(),
          institution: _institutionController.text.trim().isEmpty
              ? null
              : _institutionController.text.trim(),
          skills: _selectedSkills.toList(),
        ),
      );
      if (!mounted) return;
      userName = profile.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Profile saved!",
            style: TextStyle(color: context.appOnAccent),
          ),
          backgroundColor: context.appAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save profile: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "PROFILE",
          style: TextStyle(
            color: context.appSubtleText,
            fontSize: 12,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: context.appText),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text(
              "Save",
              style: TextStyle(
                color: context.appAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: AppVisualBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF293B41),
                          child: Icon(
                            Icons.person,
                            color: context.appAccent,
                            size: 52,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.appAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: context.appOnAccent,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _nameController.text.trim().isEmpty
                          ? 'Your learning profile'
                          : _nameController.text.trim(),
                      style: TextStyle(
                        color: context.appText,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'CURIOUS · CONSISTENT · IN PROGRESS',
                      style: TextStyle(
                        color: context.appSubtleText,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              GlassPanel(
                padding: const EdgeInsets.symmetric(vertical: 17),
                radius: 22,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _ProfileMetric('12h 40m', 'WATCHED'),
                    _ProfileMetric('24', 'LESSONS'),
                    _ProfileMetric('86%', 'PROGRESS'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Input Fields ────────────────────────────────────────────
              _SectionLabel("Personal Info"),
              SizedBox(height: 14),
              _ProfileField(
                controller: _nameController,
                label: "Full Name",
                hint: "e.g. Ananya Raghuveer",
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 16),
              _ProfileField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "e.g. +91 98765 43210",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              _ProfileField(
                controller: _emailController,
                label: "Email ID",
                hint: "e.g. ananya@email.com",
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              _ProfileField(
                controller: _institutionController,
                label: "Institution",
                hint: "e.g. University or college name",
                icon: Icons.school_outlined,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 28),

              // ── Skills ──────────────────────────────────────────────────
              _SectionLabel("Skills"),
              SizedBox(height: 6),
              Text(
                "Select your skills",
                style: TextStyle(color: context.appSubtleText, fontSize: 13),
              ),
              SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _allSkills.map((skill) {
                  final selected = _selectedSkills.contains(skill);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedSkills.remove(skill);
                      } else {
                        _selectedSkills.add(skill);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? context.appAccent
                            : context.appPanelTop,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? context.appAccent
                              : context.appCardBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected) ...[
                            Icon(
                              Icons.check,
                              color: context.appOnAccent,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                          ],
                          Text(
                            skill,
                            style: TextStyle(
                              color: selected
                                  ? context.appOnAccent
                                  : context.appMutedText,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 36),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _isSaving ? "Saving..." : "Save Profile",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.appText,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileMetric(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: context.appText,
          fontSize: 17,
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

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.appMutedText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        GlassPanel(
          padding: EdgeInsets.zero,
          radius: 16,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: context.appText, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: context.appSubtleText, fontSize: 14),
              prefixIcon: Icon(icon, color: context.appMutedText, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Liked Videos Page ─────────────────────────────────────────────────────────
class LikedVideosPage extends StatefulWidget {
  const LikedVideosPage({required this.onOpenReel, super.key});

  final ValueChanged<String> onOpenReel;

  @override
  _LikedVideosPageState createState() => _LikedVideosPageState();
}

class _LikedVideosPageState extends State<LikedVideosPage> {
  @override
  Widget build(BuildContext context) {
    final liked = likedSlides.toList()..sort();
    final likedReelItems = likedReels
        .map((id) => reelsById[id])
        .whereType<SavedReel>()
        .toList();
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "LIKED",
          style: TextStyle(
            color: context.appSubtleText,
            fontSize: 12,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: context.appText),
      ),
      body: AppVisualBackground(
        child: liked.isEmpty && likedReelItems.isEmpty
            ? EmptyState(
                icon: Icons.favorite_border,
                message: "No liked slides yet",
                sub: "Tap ♥ on any card in the feed",
              )
            : ListView(
                padding: EdgeInsets.all(18),
                children: [
                  ...likedReelItems.map(
                    (reel) => ReelListTile(
                      reel: reel,
                      accentColor: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onOpenReel(reel.id);
                      },
                    ),
                  ),
                  ...liked.map(
                    (slide) => SlideCard(
                      slideIndex: slide,
                      accentColor: Colors.redAccent,
                      trailingIcon: Icons.favorite,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Saved Videos Page (Folder List) ──────────────────────────────────────────
class SavedVideosPage extends StatefulWidget {
  const SavedVideosPage({required this.onOpenReel, super.key});

  final ValueChanged<String> onOpenReel;

  @override
  _SavedVideosPageState createState() => _SavedVideosPageState();
}

class _SavedVideosPageState extends State<SavedVideosPage> {
  void _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.appCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("New Folder", style: TextStyle(color: ctx.appText)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: ctx.appText),
          decoration: InputDecoration(
            hintText: "Folder name...",
            hintStyle: TextStyle(color: ctx.appSubtleText),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ctx.appBorder),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ctx.appAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: ctx.appMutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              "Create",
              style: TextStyle(
                color: ctx.appAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      setState(() => savedFolders.putIfAbsent(name, () => {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderNames = savedFolders.keys.toList();
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "MY LIBRARY",
          style: TextStyle(
            color: context.appSubtleText,
            fontSize: 12,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: context.appText),
        actions: [
          IconButton(
            icon: Icon(
              Icons.create_new_folder_outlined,
              color: context.appAccent,
            ),
            onPressed: _createFolder,
          ),
        ],
      ),
      body: AppVisualBackground(
        child: folderNames.isEmpty
            ? EmptyState(
                icon: Icons.folder_open,
                message: "No folders yet",
                sub: "Tap 🔖 on any feed card to save",
              )
            : ListView.builder(
                padding: EdgeInsets.all(18),
                itemCount: folderNames.length,
                itemBuilder: (context, i) {
                  final folderName = folderNames[i];
                  final count =
                      savedFolders[folderName]!.length +
                      (savedReelsByFolder[folderName]?.length ?? 0);
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FolderDetailPage(
                          folderName: folderName,
                          onOpenReel: widget.onOpenReel,
                        ),
                      ),
                    ).then((_) => setState(() {})),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        radius: 24,
                        gradient: LinearGradient(
                          colors: [context.appPanelTop, context.appPanelBottom],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF39585E),
                                    Color(0xFF17262B),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.folder_open_rounded,
                                color: context.appAccent,
                                size: 25,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    folderName,
                                    style: TextStyle(
                                      color: context.appText,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "$count saved item${count == 1 ? '' : 's'}",
                                    style: TextStyle(
                                      color: context.appMutedText,
                                      fontSize: 13,
                                    ),
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
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createFolder,
        backgroundColor: context.appAccent,
        child: Icon(
          Icons.create_new_folder_outlined,
          color: context.appOnAccent,
        ),
      ),
    );
  }
}

// ── Folder Detail Page ────────────────────────────────────────────────────────
class FolderDetailPage extends StatefulWidget {
  final String folderName;
  final ValueChanged<String> onOpenReel;
  const FolderDetailPage({
    super.key,
    required this.folderName,
    required this.onOpenReel,
  });

  @override
  _FolderDetailPageState createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  @override
  Widget build(BuildContext context) {
    final slides = (savedFolders[widget.folderName] ?? <int>{}).toList()
      ..sort();
    final reels = (savedReelsByFolder[widget.folderName] ?? <String>{})
        .map((id) => reelsById[id])
        .whereType<SavedReel>()
        .toList();
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.folder, color: context.appAccent, size: 20),
            SizedBox(width: 8),
            Text(
              widget.folderName,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: context.appText),
      ),
      body: AppVisualBackground(
        child: slides.isEmpty && reels.isEmpty
            ? EmptyState(
                icon: Icons.bookmark_border,
                message: "Folder is empty",
                sub: "Save slides from the feed here",
              )
            : ListView(
                padding: EdgeInsets.all(18),
                children: [
                  ...reels.map(
                    (reel) => ReelListTile(
                      reel: reel,
                      accentColor: context.appAccent,
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        widget.onOpenReel(reel.id);
                      },
                    ),
                  ),
                  ...slides.map(
                    (slide) => SlideCard(
                      slideIndex: slide,
                      accentColor: context.appAccent,
                      trailingIcon: Icons.bookmark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ReelListTile extends StatelessWidget {
  const ReelListTile({
    super.key,
    required this.reel,
    required this.accentColor,
    required this.onTap,
  });

  final SavedReel reel;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 20,
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          Color.alphaBlend(
            accentColor.withValues(alpha: 0.14),
            context.appPanelTop,
          ),
          context.appPanelBottom,
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle_fill, color: accentColor, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reel.title,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.video_library_outlined, color: context.appMutedText),
        ],
      ),
    ),
  );
}
