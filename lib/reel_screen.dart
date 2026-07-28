import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'video_blob_stub.dart' if (dart.library.html) 'video_blob_web.dart';

class ReelScreen extends StatefulWidget {
  final VoidCallback onStateChanged;
  final bool isActive;
  const ReelScreen({
    required this.onStateChanged,
    required this.isActive,
    Key? key,
  }) : super(key: key);

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  List<dynamic> dbReels = [];
  bool isLoading = true;
  int currentPage = 0;
  final Set<String> manuallyPausedReels = {};
  final Set<String> expandedDescriptionReels = {};
  String? playbackFeedbackReelId;
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
    _reportCurrentReel('left the Reels screen');
    _playbackFeedbackTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive && !widget.isActive) {
      _reportCurrentReel('left the Reels tab');
    }
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
    return reel['id']?.toString() ?? reel['videoUrl']?.toString();
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
        Uri.parse(
          "https://lisa-unevocable-undiscordantly.ngrok-free.dev/api/reels",
        ),
        headers: {
          "ngrok-skip-browser-warning": "true",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          dbReels = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Server returned an error status: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error connecting to ngrok backend: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: Center(
          child: CircularProgressIndicator(color: context.appAccent),
        ),
      );
    }

    if (dbReels.isEmpty) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: Center(
          child: Text(
            "No videos found. Upload some shorts from the React web dashboard!",
            style: TextStyle(color: context.appText),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          physics: const PageScrollPhysics(),
          itemCount: dbReels.length,
          onPageChanged: (index) {
            _reportCurrentReel('swiped to another reel');
            setState(() => currentPage = index);
          },
          itemBuilder: (context, index) {
            final reelData = dbReels[index];
            final String videoUrl = reelData['videoUrl'];
            final String title = reelData['title'] ?? "Untitled Short";
            final String description =
                reelData['description']?.toString().trim() ?? '';
            final String reelId = reelData['id']?.toString() ?? videoUrl;
            final bool isDescriptionExpanded = expandedDescriptionReels
                .contains(reelId);
            final bool isCurrent = index == currentPage;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _togglePlayback(reelId),
              onDoubleTap: () {
                if (!likedReels.contains(reelId)) {
                  reelsById[reelId] = SavedReel(
                    id: reelId,
                    title: title,
                    videoUrl: videoUrl,
                  );
                  likedReels.add(reelId);
                  setState(() {});
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: VideoPlayerItem(
                      videoUrl: videoUrl,
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
                  Container(color: Colors.black.withOpacity(0.25)),
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
                              const Row(
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "For You",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "DATABASE SHORTS",
                                  style: TextStyle(
                                    color: Color(0xFF2563eb),
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
                    bottom: 100,
                    child: _ReelActions(
                      reelId: reelId,
                      title: title,
                      videoUrl: videoUrl,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReelActions extends StatelessWidget {
  const _ReelActions({
    required this.reelId,
    required this.title,
    required this.videoUrl,
    required this.onChanged,
  });

  final String reelId;
  final String title;
  final String videoUrl;
  final VoidCallback onChanged;

  Future<void> _shareVideo(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Preparing video to share...')),
    );

    try {
      final response = await http.get(
        Uri.parse(videoUrl),
        headers: const {
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'video/mp4',
        },
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
      backgroundColor: context.appSurface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      backgroundColor: dialogContext.appSurface,
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
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to $folder')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final liked = likedReels.contains(reelId);
    final saved = savedReelsByFolder.values.any((ids) => ids.contains(reelId));
    return Column(
      children: [
        _ActionButton(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          color: liked ? Colors.redAccent : Colors.white,
          label: 'Like',
          onTap: () {
            if (liked) {
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
          },
        ),
        const SizedBox(height: 18),
        _ActionButton(
          icon: saved ? Icons.bookmark : Icons.bookmark_border,
          color: saved ? const Color(0xFF2563eb) : Colors.white,
          label: 'Save',
          onTap: () => _chooseFolder(context),
        ),
        const SizedBox(height: 18),
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(28),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ── Isolated Video Player Component for Clean Memory Management ──
class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final bool shouldPlay;
  final void Function(bool isPlaying, Duration videoDuration) onPlaybackChanged;

  const VideoPlayerItem({
    required this.videoUrl,
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
      if (kIsWeb) {
        // THE FIX: download the video ourselves (with the header ngrok
        // needs to skip its warning page), then hand the player a local
        // blob URL instead of the raw ngrok link.
        final response = await http.get(
          Uri.parse(widget.videoUrl),
          headers: {
            "ngrok-skip-browser-warning": "true",
            "Accept": "video/mp4",
          },
        );

        if (response.statusCode != 200) {
          throw Exception("Server returned ${response.statusCode}");
        }

        final blobUrl = createBlobUrl(response.bodyBytes);
        _controller = VideoPlayerController.networkUrl(Uri.parse(blobUrl));
      } else {
        // Android/iOS/desktop can send headers directly, no workaround needed.
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          httpHeaders: {"ngrok-skip-browser-warning": "true"},
        );
      }

      await _controller!.initialize();
      if (!mounted) return;
      _controller!.addListener(_reportPlaybackState);
      setState(() {
        isInitialized = true;
        _controller!.setLooping(true);
        if (widget.shouldPlay) {
          _controller!.play();
        }
      });
      _reportPlaybackState();
    } catch (error) {
      print("Video loading error on: ${widget.videoUrl} -> Error: $error");
      if (mounted) {
        setState(() => hasError = true);
      }
    }
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isInitialized || hasError || _controller == null) return;

    if (widget.shouldPlay) {
      _controller!.play();
    } else {
      _controller!.pause();
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
