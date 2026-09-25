import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'auth_service.dart';
import 'api_service.dart';

class _ReelData {
  const _ReelData({
    required this.id,
    required this.title,
    required this.filename,
    required this.videoUrl,
  });

  final int id;
  final String title;
  final String filename;
  final String videoUrl;

  factory _ReelData.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final videoUrl = json['videoUrl']?.toString();
    if (id is! num || videoUrl == null || videoUrl.isEmpty) {
      throw const FormatException('A reel is missing required API fields.');
    }
    final filename = json['filename']?.toString() ?? '';
    return _ReelData(
      id: id.toInt(),
      title: json['title']?.toString() ?? filename,
      filename: filename,
      videoUrl: videoUrl,
    );
  }
}

class ReelScreen extends StatefulWidget {
  final String accessToken;
  final VoidCallback onStateChanged;
  final bool isActive;
  final String? reelToOpenId;
  final VoidCallback onReelOpened;
  const ReelScreen({
    required this.accessToken,
    required this.onStateChanged,
    required this.isActive,
    required this.reelToOpenId,
    required this.onReelOpened,
    Key? key,
  }) : super(key: key);

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  List<_ReelData> dbReels = [];
  final PageController _pageController = PageController();
  bool isLoading = true;
  int currentPage = 0;
  final Set<String> manuallyPausedReels = {};
  final Set<String> expandedDescriptionReels = {};
  String? playbackFeedbackReelId;
  bool isMuted = false;
  Timer? _playbackFeedbackTimer;
  final Map<String, _ReelWatchStats> _watchStats = {};
  String? _activeReelId;
  DateTime? _watchStartedAt;

  @override
  void initState() {
    super.initState();
    fetchReelsFromDatabase();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reportCurrentReel('left the Reels screen');
    _playbackFeedbackTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (!widget.isActive) {
        _reportCurrentReel('left the Reels tab');
      }
      setState(() {});
    }
    if (oldWidget.reelToOpenId != widget.reelToOpenId &&
        widget.reelToOpenId != null) {
      _jumpToReel(widget.reelToOpenId!);
    }
  }

  void _jumpToReel(String reelId) {
    final index = dbReels.indexWhere((reel) => reel.id.toString() == reelId);
    if (index < 0) {
      if (!isLoading) widget.onReelOpened();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      currentPage = index;
      _pageController.jumpToPage(index);
      widget.onReelOpened();
    });
  }

  void _onPlaybackChanged({
    required String reelId,
    required String title,
    required Duration videoDuration,
    required bool isPlaying,
  }) {
    // Off-screen PageView items can initialize too; only the visible reel is tracked.
    if (reelId != _activeReelId && reelId != _currentReelId) return;

    final stats = _watchStats.putIfAbsent(
      reelId,
      () => _ReelWatchStats(
        id: reelId,
        title: title,
        videoDuration: videoDuration,
      ),
    )..videoDuration = videoDuration;

    if (isPlaying && reelId == _currentReelId && widget.isActive) {
      if (_activeReelId != reelId) {
        _stopWatch();
        _activeReelId = reelId;
        debugPrint('[Reel analytics] Started: "${stats.title}" (id: $reelId)');
      }
      _watchStartedAt ??= DateTime.now();
    } else if (reelId == _activeReelId) {
      _stopWatch();
    }
  }

  String? get _currentReelId {
    if (dbReels.isEmpty || currentPage >= dbReels.length) return null;
    final reel = dbReels[currentPage];
    return reel.id.toString();
  }

  void _stopWatch() {
    if (_activeReelId == null || _watchStartedAt == null) return;
    _watchStats[_activeReelId]!.watched += DateTime.now().difference(
      _watchStartedAt!,
    );
    _watchStartedAt = null;
  }

  void _reportCurrentReel(String reason) {
    _stopWatch();
    final reelId = _activeReelId;
    if (reelId == null) return;

    final stats = _watchStats[reelId]!;
    final skipped =
        stats.videoDuration > Duration.zero &&
        stats.watched < stats.videoDuration * 0.8;
    debugPrint(
      '[Reel analytics] ${skipped ? 'SKIPPED' : 'WATCHED'}: '
      '"${stats.title}" (id: $reelId) | watched: '
      '${_formatDuration(stats.watched)} / ${_formatDuration(stats.videoDuration)} '
      '| reason: $reason',
    );
    _activeReelId = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _togglePlayback(String reelId) {
    setState(() {
      if (manuallyPausedReels.contains(reelId)) {
        manuallyPausedReels.remove(reelId);
      } else {
        manuallyPausedReels.add(reelId);
      }
      playbackFeedbackReelId = reelId;
    });
    _playbackFeedbackTimer?.cancel();
    _playbackFeedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => playbackFeedbackReelId = null);
    });
  }

  Future<void> fetchReelsFromDatabase() async {
    try {
      final response = await http.get(
        Uri.parse('$backendBaseUrl/api/reels'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body);
      if (responseData is! List) {
        throw const FormatException('The reels API response must be a list.');
      }
      final reels = responseData
          .map((reel) => _ReelData.fromJson(Map<String, dynamic>.from(reel)))
          .toList();
      if (!mounted) return;
      setState(() {
        dbReels = reels;
        isLoading = false;
      });
      if (widget.reelToOpenId != null) {
        _jumpToReel(widget.reelToOpenId!);
      }
      await _loadUserReelPreferences();
    } catch (e) {
      debugPrint('Error connecting to EduReel backend: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserReelPreferences() async {
    try {
      final auth = GoogleAuthService();
      final results = await Future.wait([
        auth.fetchLikedReelIds(widget.accessToken),
        auth.fetchSavedReelIds(widget.accessToken),
      ]);
      if (!mounted) return;

      final likedIds = results[0];
      final savedIds = results[1];
      setState(() {
        likedReels
          ..clear()
          ..addAll(likedIds);
        savedReelsByFolder..clear();
        if (savedIds.isNotEmpty) {
          savedReelsByFolder['Saved Reels'] = savedIds;
        }
        for (final reel in dbReels) {
          final id = reel.id.toString();
          if (likedIds.contains(id) || savedIds.contains(id)) {
            reelsById[id] = SavedReel(
              id: id,
              title: reel.title,
              videoUrl: reel.videoUrl,
            );
          }
        }
      });
      widget.onStateChanged();
    } catch (error) {
      debugPrint('Error loading user reel preferences: $error');
    }
  }

  Future<void> _likeReel({
    required String reelId,
    required String title,
    required String videoUrl,
  }) async {
    if (likedReels.contains(reelId)) return;
    reelsById[reelId] = SavedReel(id: reelId, title: title, videoUrl: videoUrl);
    likedReels.add(reelId);
    setState(() {});
    widget.onStateChanged();

    try {
      await GoogleAuthService().setReelLiked(
        accessToken: widget.accessToken,
        reelId: reelId,
        liked: true,
      );
    } catch (error) {
      likedReels.remove(reelId);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not like reel: $error')));
      }
      widget.onStateChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppVisualBackground(
          child: Center(
            child: CircularProgressIndicator(color: context.appAccent),
          ),
        ),
      );
    }

    if (dbReels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppVisualBackground(
          child: Center(
            child: Text(
              "No videos found. Upload some shorts from the React web dashboard!",
              style: TextStyle(color: context.appText),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const PageScrollPhysics(),
          itemCount: dbReels.length,
          onPageChanged: (index) {
            _reportCurrentReel('swiped to another reel');
            setState(() => currentPage = index);
          },
          itemBuilder: (context, index) {
            final reelData = dbReels[index];
            final String videoUrl = reelData.videoUrl;
            final String title = reelData.title.isEmpty
                ? 'Untitled Short'
                : reelData.title;
            final String description = '';
            final String reelId = reelData.id.toString();
            final bool isDescriptionExpanded = expandedDescriptionReels
                .contains(reelId);
            final bool isCurrent = index == currentPage;

            return Stack(
              children: [
                Positioned.fill(
                  child: VideoPlayerItem(
                    videoUrl: videoUrl,
                    isMuted: isMuted,
                    shouldPlay:
                        isCurrent &&
                        widget.isActive &&
                        !manuallyPausedReels.contains(reelId),
                    onPlaybackChanged: (isPlaying, videoDuration) =>
                        _onPlaybackChanged(
                          reelId: reelId,
                          title: title,
                          videoDuration: videoDuration,
                          isPlaying: isPlaying,
                        ),
                  ),
                ),
                // This overlay sits above the platform video surface. On
                // Flutter Web, the <video> element can otherwise consume
                // the tap before the Reel widget receives it.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _togglePlayback(reelId),
                    onDoubleTap: () {
                      _likeReel(
                        reelId: reelId,
                        title: title,
                        videoUrl: videoUrl,
                      );
                    },
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xA4081318),
                        Color(0x180D1B20),
                        Color(0xE20A1216),
                      ],
                      stops: [0, 0.42, 1],
                    ),
                  ),
                ),
                if (playbackFeedbackReelId == reelId)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Color(0x99000000),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        manuallyPausedReels.contains(reelId)
                            ? Icons.play_arrow
                            : Icons.pause,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlassPanel(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              radius: 17,
                              gradient: const LinearGradient(
                                colors: [Color(0xA82B2B2B), Color(0xA3181818)],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "For You",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xB21B1B1B),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: const Color(0x45FFFFFF),
                                ),
                              ),
                              child: const Text(
                                "DATABASE SHORTS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.25,
                                ),
                                maxLines: isDescriptionExpanded ? null : 2,
                                overflow: isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (isDescriptionExpanded) {
                                      expandedDescriptionReels.remove(reelId);
                                    } else {
                                      expandedDescriptionReels.add(reelId);
                                    }
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  isDescriptionExpanded ? 'less' : 'more...',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _ReelActions(
                      accessToken: widget.accessToken,
                      reelId: reelId,
                      title: title,
                      videoUrl: videoUrl,
                      isMuted: isMuted,
                      onToggleMute: () => setState(() => isMuted = !isMuted),
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReelActions extends StatelessWidget {
  const _ReelActions({
    required this.accessToken,
    required this.reelId,
    required this.title,
    required this.videoUrl,
    required this.isMuted,
    required this.onToggleMute,
    required this.onChanged,
  });

  final String accessToken;
  final String reelId;
  final String title;
  final String videoUrl;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final VoidCallback onChanged;

  Future<void> _toggleLike(BuildContext context) async {
    final wasLiked = likedReels.contains(reelId);
    if (wasLiked) {
      likedReels.remove(reelId);
    } else {
      reelsById[reelId] = SavedReel(
        id: reelId,
        title: title,
        videoUrl: videoUrl,
      );
      likedReels.add(reelId);
    }
    onChanged();

    try {
      await GoogleAuthService().setReelLiked(
        accessToken: accessToken,
        reelId: reelId,
        liked: !wasLiked,
      );
    } catch (error) {
      if (wasLiked) {
        likedReels.add(reelId);
      } else {
        likedReels.remove(reelId);
      }
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update like: $error')),
        );
      }
    }
  }

  Future<void> _shareVideo(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Preparing video to share...')),
    );

    try {
      final response = await http.get(
        Uri.parse(videoUrl),
        headers: const {'Accept': 'video/mp4'},
      );
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('Video download failed (${response.statusCode})');
      }

      final safeName = title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final videoFile = XFile.fromData(
        response.bodyBytes,
        name: '${safeName.isEmpty ? 'reel' : safeName}.mp4',
        mimeType: 'video/mp4',
      );
      await Share.shareXFiles([videoFile], text: title, subject: title);
    } catch (error) {
      // A URL is still useful when the server prevents downloading the file.
      await Share.share('$title\n$videoUrl', subject: title);
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Could not download the video, so its link was shared.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _chooseFolder(BuildContext context) async {
    final controller = TextEditingController();
    final folders = <String>{
      ...savedFolders.keys,
      ...savedReelsByFolder.keys,
    }.toList()..sort();
    final folder = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: GlassPanel(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save reel to folder',
                style: TextStyle(
                  color: sheetContext.appText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...folders.map(
                (name) => ListTile(
                  leading: Icon(
                    Icons.folder_outlined,
                    color: sheetContext.appAccent,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(color: sheetContext.appText),
                  ),
                  onTap: () => Navigator.pop(sheetContext, name),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.create_new_folder_outlined,
                  color: sheetContext.appAccent,
                ),
                title: Text(
                  'Create new folder',
                  style: TextStyle(color: sheetContext.appText),
                ),
                onTap: () async {
                  final name = await showDialog<String>(
                    context: sheetContext,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: dialogContext.appCard,
                      title: Text(
                        'New folder',
                        style: TextStyle(color: dialogContext.appText),
                      ),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        style: TextStyle(color: dialogContext.appText),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(
                            dialogContext,
                            controller.text.trim(),
                          ),
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  );
                  if (name != null && name.isNotEmpty && sheetContext.mounted) {
                    Navigator.pop(sheetContext, name);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (folder == null || folder.isEmpty) return;

    reelsById[reelId] = SavedReel(id: reelId, title: title, videoUrl: videoUrl);
    savedFolders.putIfAbsent(folder, () => {});
    savedReelsByFolder.putIfAbsent(folder, () => {}).add(reelId);
    onChanged();
    try {
      await GoogleAuthService().setReelSaved(
        accessToken: accessToken,
        reelId: reelId,
        saved: true,
      );
    } catch (error) {
      savedReelsByFolder[folder]?.remove(reelId);
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save reel: $error')));
      }
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to $folder')));
    }
  }

  Future<void> _unsave(BuildContext context) async {
    final previousFolders = <String>{};
    for (final entry in savedReelsByFolder.entries) {
      if (entry.value.remove(reelId)) previousFolders.add(entry.key);
    }
    onChanged();

    try {
      await GoogleAuthService().setReelSaved(
        accessToken: accessToken,
        reelId: reelId,
        saved: false,
      );
    } catch (error) {
      for (final folder in previousFolders) {
        savedReelsByFolder.putIfAbsent(folder, () => {}).add(reelId);
      }
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove saved reel: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final liked = likedReels.contains(reelId);
    final saved = savedReelsByFolder.values.any((ids) => ids.contains(reelId));
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? Colors.redAccent : Colors.white,
            label: 'Like',
            onTap: () => _toggleLike(context),
          ),
          const SizedBox(height: 2),
          _ActionButton(
            icon: saved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            label: 'Save',
            onTap: () => saved ? _unsave(context) : _chooseFolder(context),
          ),
          const SizedBox(height: 2),
          _ActionButton(
            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: Colors.white,
            label: isMuted ? 'Unmute' : 'Mute',
            onTap: onToggleMute,
          ),
          const SizedBox(height: 2),
          _ActionButton(
            icon: Icons.share_outlined,
            color: Colors.white,
            label: 'Share',
            onTap: () => _shareVideo(context),
          ),
        ],
      );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 54,
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0x70203339),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x35FFFFFF)),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 12),
                ],
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Isolated Video Player Component for Clean Memory Management ──
class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final bool isMuted;
  final bool shouldPlay;
  final void Function(bool isPlaying, Duration videoDuration) onPlaybackChanged;

  const VideoPlayerItem({
    required this.videoUrl,
    required this.isMuted,
    required this.shouldPlay,
    required this.onPlaybackChanged,
    Key? key,
  }) : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _controller;
  bool isInitialized = false;
  bool hasError = false;
  bool? _lastReportedPlaying;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _controller = controller;
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.setVolume(widget.isMuted ? 0 : 1);
      controller.addListener(_reportPlaybackState);
      controller.setLooping(true);
      setState(() {
        isInitialized = true;
      });
      if (widget.shouldPlay) {
        await controller.play();
      }
      _reportPlaybackState();
    } catch (error) {
      debugPrint("Video loading error on: ${widget.videoUrl} -> Error: $error");
      if (mounted) {
        setState(() => hasError = true);
      }
    }
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.removeListener(_reportPlaybackState);
      _controller?.dispose();
      _controller = null;
      isInitialized = false;
      hasError = false;
      initializePlayer();
      return;
    }
    if (!isInitialized || hasError || _controller == null) return;
    if (oldWidget.isMuted != widget.isMuted) {
      _controller!.setVolume(widget.isMuted ? 0 : 1);
    }
    if (widget.shouldPlay) {
      if (!_controller!.value.isPlaying) {
        _controller!.play();
      }
    } else {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  void _reportPlaybackState() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final isPlaying = controller.value.isPlaying;
    if (_lastReportedPlaying == isPlaying) return;
    _lastReportedPlaying = isPlaying;
    widget.onPlaybackChanged(isPlaying, controller.value.duration);
  }

  @override
  void dispose() {
    _controller?.removeListener(_reportPlaybackState);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
            SizedBox(height: 8),
            Text(
              "Playback Error\nCheck format or network status.",
              style: TextStyle(color: const Color(0x40FFFFFF), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white24),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}

class _ReelWatchStats {
  _ReelWatchStats({
    required this.id,
    required this.title,
    required this.videoDuration,
  });

  final String id;
  final String title;
  Duration videoDuration;
  Duration watched = Duration.zero;
}
