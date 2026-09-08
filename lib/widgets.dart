import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_theme.dart';

// ── Shared slide card used in liked/saved pages ───────────────────────────────
class SlideCard extends StatelessWidget {
  final int slideIndex;
  final Color accentColor;
  final IconData trailingIcon;

  const SlideCard({
    super.key,
    required this.slideIndex,
    required this.accentColor,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: 21,
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(
              accentColor.withValues(alpha: 0.20),
              context.appPanelTop,
            ),
            context.appPanelBottom,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.appAccent.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.appAccent.withValues(alpha: 0.36),
                    ),
                  ),
                  child: Text(
                    topics[slideIndex],
                    style: TextStyle(
                      color: context.appAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Spacer(),
                Icon(trailingIcon, color: accentColor, size: 18),
              ],
            ),
            SizedBox(height: 10),
            Text(
              headings[slideIndex],
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.bold,
                fontSize: 17,
                height: 1.2,
              ),
            ),
            SizedBox(height: 6),
            Text(
              descriptions[slideIndex],
              style: TextStyle(
                color: context.appMutedText,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            Container(
              width: 50,
              height: 3,
              decoration: BoxDecoration(
                color: context.appAccent,
                borderRadius: BorderRadius.circular(2),
              ),
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

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.appFaintText, size: 64),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: context.appMutedText, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            sub,
            style: TextStyle(color: context.appSubtleText, fontSize: 13),
          ),
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
      setState(() {
        savedFolders.putIfAbsent(name, () => {});
        savedFolders[name]!.add(widget.slideIndex);
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to "$name"'),
          backgroundColor: context.appAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.appPanelTop, context.appPanelBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: context.appCardBorder),
          left: BorderSide(color: context.appCardBorder),
          right: BorderSide(color: context.appCardBorder),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Save to Folder",
            style: TextStyle(
              color: context.appText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Choose an existing folder or create a new one.",
            style: TextStyle(color: context.appMutedText, fontSize: 13),
          ),
          SizedBox(height: 20),
          // Create new folder tile
          ListTile(
            onTap: _createFolder,
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.appAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.create_new_folder_outlined,
                color: context.appAccent,
                size: 22,
              ),
            ),
            title: Text(
              "Create New Folder",
              style: TextStyle(
                color: context.appAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (savedFolders.isNotEmpty) ...[
            Divider(color: context.appBorder),
            SizedBox(height: 4),
            ...savedFolders.keys.map((folderName) {
              final isSaved = savedFolders[folderName]!.contains(
                widget.slideIndex,
              );
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
                      content: Text(
                        isSaved
                            ? 'Removed from "$folderName"'
                            : 'Saved to "$folderName"',
                      ),
                      backgroundColor: context.appAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSaved
                        ? context.appAccent.withOpacity(0.2)
                        : context.appText.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSaved ? Icons.folder : Icons.folder_outlined,
                    color: isSaved ? context.appAccent : context.appMutedText,
                    size: 22,
                  ),
                ),
                title: Text(
                  folderName,
                  style: TextStyle(color: context.appText, fontSize: 15),
                ),
                subtitle: Text(
                  "${savedFolders[folderName]!.length} slides",
                  style: TextStyle(color: context.appSubtleText, fontSize: 12),
                ),
                trailing: isSaved
                    ? Icon(
                        Icons.check_circle,
                        color: context.appAccent,
                        size: 20,
                      )
                    : null,
              );
            }),
          ],
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
