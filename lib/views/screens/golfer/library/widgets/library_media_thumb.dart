import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:golf_training_app/services/swing_media_cache.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Shared in-memory cache so grid scroll does not re-extract every frame.
final Map<String, Uint8List> _thumbCache = {};

/// Library / analysis still: prefer server image thumb, else extract a JPEG
/// frame from the video URL (or local file).
class LibraryMediaThumb extends StatelessWidget {
  const LibraryMediaThumb({
    super.key,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.isLocal = false,
  });

  final String thumbnailUrl;
  final String videoUrl;
  final bool isLocal;

  static bool isLikelyImageUrl(String url) {
    final clean = url.toLowerCase().split('?').first;
    if (clean.isEmpty) return false;
    if (clean.endsWith('.mp4') ||
        clean.endsWith('.mov') ||
        clean.endsWith('.m4v') ||
        clean.endsWith('.webm') ||
        clean.endsWith('.avi')) {
      return false;
    }
    if (clean.endsWith('.jpg') ||
        clean.endsWith('.jpeg') ||
        clean.endsWith('.png') ||
        clean.endsWith('.webp') ||
        clean.endsWith('.gif')) {
      return true;
    }
    // Signed CDN image URLs often omit an extension — try Image.network first.
    return clean.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final thumb = thumbnailUrl.trim();
    final video = videoUrl.trim();

    if (thumb.isNotEmpty && isLikelyImageUrl(thumb)) {
      if (thumb.startsWith('http')) {
        return Image.network(
          thumb,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _VideoStill(url: video, isLocal: isLocal),
        );
      }
      final file = File(thumb);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _VideoStill(url: video, isLocal: isLocal),
        );
      }
    }

    // Server sometimes stores the mp4 in thumbnailUrl — treat as video source.
    final frameSource = video.isNotEmpty
        ? video
        : (thumb.toLowerCase().contains('.mp4') ? thumb : '');
    if (frameSource.isEmpty) return const _ThumbPlaceholder();
    return _VideoStill(
      url: frameSource,
      isLocal: isLocal || !frameSource.startsWith('http'),
    );
  }
}

class _VideoStill extends StatefulWidget {
  const _VideoStill({required this.url, required this.isLocal});

  final String url;
  final bool isLocal;

  @override
  State<_VideoStill> createState() => _VideoStillState();
}

class _VideoStillState extends State<_VideoStill> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _VideoStill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytes = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    final key = widget.url;
    final cached = _thumbCache[key];
    if (cached != null) {
      if (mounted) setState(() => _bytes = cached);
      return;
    }
    try {
      var videoPath = widget.url;
      if (videoPath.startsWith('http')) {
        final local = await SwingMediaCache.resolveLocalPath(
          remoteUrl: videoPath,
        );
        if (local != null && local.isNotEmpty) {
          videoPath = local;
        }
      }
      final data = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 480,
        timeMs: 400,
        quality: 70,
      );
      if (data == null || data.isEmpty) {
        if (mounted) setState(() => _failed = true);
        return;
      }
      _thumbCache[key] = data;
      if (!mounted) return;
      setState(() => _bytes = data);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const _ThumbPlaceholder();
    final bytes = _bytes;
    if (bytes == null) {
      return Container(
        color: const Color(0xFF1E3A2B),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      );
    }
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7942), Color(0xFF1E3A2B)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.videocam_outlined, color: Colors.white38, size: 36),
      ),
    );
  }
}
