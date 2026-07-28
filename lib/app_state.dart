import 'package:flutter/material.dart';

// Global app state shared across all screens
final PageController globalPageController = PageController();

void jumpToSlide(int index) {
  if (globalPageController.hasClients) {
    globalPageController.jumpToPage(index);
  }
}

final Set<int> likedSlides = {};
// folder name → set of slide indices
final Map<String, Set<int>> savedFolders = {};
String userName = '';
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.dark);

/// Reels are stored separately from lesson slides because their identifiers are
/// URLs rather than slide indexes.
class SavedReel {
  const SavedReel({
    required this.id,
    required this.title,
    required this.videoUrl,
  });

  final String id;
  final String title;
  final String videoUrl;
}

final Map<String, SavedReel> reelsById = {};
final Set<String> likedReels = {};
// Folder name → reel IDs. Folder names are shared with the existing Saved page.
final Map<String, Set<String>> savedReelsByFolder = {};

final List<String> topics = [
  "TOPIC 1: ALGORITHMS",
  "TOPIC 2: DATA STRUCTURES",
  "TOPIC 3: DATABASES",
  "TOPIC 4: OPERATING SYSTEMS",
  "TOPIC 5: NETWORKING",
];

final List<String> headings = [
  "Mastering Sorting & Searching",
  "Stacks, Queues, and Trees",
  "Relational & NoSQL Databases",
  "Processes and Memory Management",
  "TCP/IP and Computer Networks",
];

final List<String> descriptions = [
  "Learn how efficient algorithms power modern computing, from searching Google to sorting your files.",
  "Understand how data structures organize and optimize information for fast access and updates.",
  "Explore how databases store, retrieve, and manage vast amounts of data reliably.",
  "Dive into how operating systems manage hardware, processes, and resources.",
  "Discover the protocols and architectures that connect computers worldwide.",
];
