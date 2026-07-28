import 'package:flutter/material.dart';
import 'app_state.dart';

// ── Shared slide card used in liked/saved pages ───────────────────────────────
class SlideCard extends StatelessWidget {
  final int slideIndex;
  final Color accentColor;
  final IconData trailingIcon;

  const SlideCard({super.key, 
    required this.slideIndex,
    required this.accentColor,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF18191C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF2563eb).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF2563eb).withOpacity(0.4)),
                  ),
                  child: Text(
                    topics[slideIndex],
                    style: TextStyle(color: Color(0xFF2563eb), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Spacer(),
                Icon(trailingIcon, color: accentColor, size: 18),
              ],
            ),
            SizedBox(height: 10),
            Text(headings[slideIndex],
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, height: 1.2)),
            SizedBox(height: 6),
            Text(descriptions[slideIndex],
                style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 12),
            Container(
              width: 50, height: 3,
              decoration: BoxDecoration(color: Color(0xFF2563eb), borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state placeholder ───────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;

  const EmptyState({super.key, required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white12, size: 64),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text(sub, style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Save to folder bottom sheet ───────────────────────────────────────────────
class SaveToFolderSheet extends StatefulWidget {
  final int slideIndex;
  const SaveToFolderSheet({super.key, required this.slideIndex});

  @override
  _SaveToFolderSheetState createState() => _SaveToFolderSheetState();
}

class _SaveToFolderSheetState extends State<SaveToFolderSheet> {
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
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563eb))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text("Create", style: TextStyle(color: Color(0xFF2563eb), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      setState(() {
        savedFolders.putIfAbsent(name, () => {});
        savedFolders[name]!.add(widget.slideIndex);
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to "$name"'),
          backgroundColor: Color(0xFF2563eb),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1B1F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          SizedBox(height: 20),
          Text("Save to Folder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 6),
          Text("Choose an existing folder or create a new one.",
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          SizedBox(height: 20),
          // Create new folder tile
          ListTile(
            onTap: _createFolder,
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Color(0xFF2563eb).withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(Icons.create_new_folder_outlined, color: Color(0xFF2563eb), size: 22),
            ),
            title: Text("Create New Folder", style: TextStyle(color: Color(0xFF2563eb), fontWeight: FontWeight.bold)),
          ),
          if (savedFolders.isNotEmpty) ...[
            Divider(color: Colors.white12),
            SizedBox(height: 4),
            ...savedFolders.keys.map((folderName) {
              final isSaved = savedFolders[folderName]!.contains(widget.slideIndex);
              return ListTile(
                onTap: () {
                  setState(() {
                    if (isSaved) {
                      savedFolders[folderName]!.remove(widget.slideIndex);
                    } else {
                      savedFolders[folderName]!.add(widget.slideIndex);
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSaved ? 'Removed from "$folderName"' : 'Saved to "$folderName"'),
                      backgroundColor: Color(0xFF2563eb),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSaved ? Color(0xFF2563eb).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSaved ? Icons.folder : Icons.folder_outlined,
                    color: isSaved ? Color(0xFF2563eb) : Colors.white54,
                    size: 22,
                  ),
                ),
                title: Text(folderName, style: TextStyle(color: Colors.white, fontSize: 15)),
                subtitle: Text("${savedFolders[folderName]!.length} slides",
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: isSaved ? Icon(Icons.check_circle, color: Color(0xFF2563eb), size: 20) : null,
              );
            }),
          ],
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
