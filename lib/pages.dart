import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'widgets.dart';

// ── Profile Page ──────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _nameController = TextEditingController(text: userName);
  final _phoneController = TextEditingController(text: "");
  final _emailController = TextEditingController(text: "");

  // Predefined interest chips
  final List<String> _allInterests = [
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
  final Set<String> _selectedInterests = {};

  bool _saved = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    setState(() {
      userName = _nameController.text.trim();
      _saved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Profile saved!",
          style: TextStyle(color: context.appOnAccent),
        ),
        backgroundColor: context.appAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(color: context.appText, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: context.appText),
        actions: [
          TextButton(
            onPressed: _saveProfile,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: context.appAccent.withOpacity(0.2),
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
                      padding: EdgeInsets.all(6),
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
            ),
            SizedBox(height: 32),

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
            SizedBox(height: 28),

            // ── Fields of Interest ──────────────────────────────────────
            _SectionLabel("Fields of Interest"),
            SizedBox(height: 6),
            Text(
              "Select topics you want to learn",
              style: TextStyle(color: context.appSubtleText, fontSize: 13),
            ),
            SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allInterests.map((interest) {
                final selected = _selectedInterests.contains(interest);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? context.appAccent : context.appSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? context.appAccent : context.appBorder,
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
                          interest,
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
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appAccent,
                  foregroundColor: context.appOnAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Save Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
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
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 17,
        letterSpacing: 0.3,
      ),
    );
  }
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
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF18191C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.white38, size: 20),
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
  const LikedVideosPage({super.key});

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
      backgroundColor: Color(0xFF111214),
      appBar: AppBar(
        backgroundColor: Color(0xFF111214),
        elevation: 0,
        title: Text(
          "Liked Videos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: liked.isEmpty && likedReelItems.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              message: "No liked slides yet",
              sub: "Tap ♥ on any card in the feed",
            )
          : ListView(
              padding: EdgeInsets.all(18),
              children: [
                ...likedReelItems.map(
                  (reel) =>
                      ReelListTile(reel: reel, accentColor: Colors.redAccent),
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
    );
  }
}

// ── Saved Videos Page (Folder List) ──────────────────────────────────────────
class SavedVideosPage extends StatefulWidget {
  const SavedVideosPage({super.key});

  @override
  _SavedVideosPageState createState() => _SavedVideosPageState();
}

class _SavedVideosPageState extends State<SavedVideosPage> {
  void _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1F24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("New Folder", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Folder name...",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2563eb)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              "Create",
              style: TextStyle(
                color: Color(0xFF2563eb),
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
      backgroundColor: Color(0xFF111214),
      appBar: AppBar(
        backgroundColor: Color(0xFF111214),
        elevation: 0,
        title: Text(
          "Saved Videos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.create_new_folder_outlined,
              color: Color(0xFF2563eb),
            ),
            onPressed: _createFolder,
          ),
        ],
      ),
      body: folderNames.isEmpty
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
                      builder: (_) => FolderDetailPage(folderName: folderName),
                    ),
                  ).then((_) => setState(() {})),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF18191C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF2563eb).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2563eb).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.folder,
                            color: Color(0xFF2563eb),
                            size: 24,
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "$count saved item${count == 1 ? '' : 's'}",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createFolder,
        backgroundColor: Color(0xFF2563eb),
        child: Icon(Icons.create_new_folder_outlined, color: Colors.black),
      ),
    );
  }
}

// ── Folder Detail Page ────────────────────────────────────────────────────────
class FolderDetailPage extends StatefulWidget {
  final String folderName;
  const FolderDetailPage({super.key, required this.folderName});

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
      backgroundColor: Color(0xFF111214),
      appBar: AppBar(
        backgroundColor: Color(0xFF111214),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.folder, color: Color(0xFF2563eb), size: 20),
            SizedBox(width: 8),
            Text(
              widget.folderName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: slides.isEmpty && reels.isEmpty
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
                    accentColor: const Color(0xFF2563eb),
                  ),
                ),
                ...slides.map(
                  (slide) => SlideCard(
                    slideIndex: slide,
                    accentColor: const Color(0xFF2563eb),
                    trailingIcon: Icons.bookmark,
                  ),
                ),
              ],
            ),
    );
  }
}

class ReelListTile extends StatelessWidget {
  const ReelListTile({
    super.key,
    required this.reel,
    required this.accentColor,
  });

  final SavedReel reel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF18191C),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accentColor.withOpacity(0.35)),
    ),
    child: Row(
      children: [
        Icon(Icons.play_circle_fill, color: accentColor, size: 34),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            reel.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(Icons.video_library_outlined, color: Colors.white54),
      ],
    ),
  );
}
