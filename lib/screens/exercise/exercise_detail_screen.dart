import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String title;
  final String? description;
  final String? category;
  final String? videoUrl;
  final int? sets;
  final int? repetitions;
  final int? durationSeconds;
  final String? frequencyText;

  const ExerciseDetailScreen({
    super.key,
    required this.title,
    this.description,
    this.category,
    this.videoUrl,
    this.sets,
    this.repetitions,
    this.durationSeconds,
    this.frequencyText,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool _isInitialized = false;
  bool _isYoutube = false;
  bool _isDirectVideo = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final url = widget.videoUrl;
    if (url == null || url.isEmpty) {
      setState(() => _isInitialized = true);
      return;
    }

    final youtubeId = _extractYoutubeId(url);
    if (youtubeId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
      setState(() => _isInitialized = true);
    } else {
      _isDirectVideo = true;
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController!.initialize().then((_) {
        if (mounted) setState(() => _isInitialized = true);
      }).catchError((_) {
        if (mounted) setState(() { _videoError = true; _isInitialized = true; });
      });
    }
  }

  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host.replaceFirst('www.', '');
    if (host == 'youtube.com' || host == 'm.youtube.com') {
      if (uri.path == '/watch') {
        return uri.queryParameters['v'];
      }
      final path = uri.pathSegments;
      if (path.isNotEmpty && (path.first == 'embed' || path.first == 'shorts')) {
        return path.length > 1 ? path[1] : null;
      }
    }
    if (host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }

  void _openInBrowser() {
    final url = widget.videoUrl;
    if (url != null) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPlayer(),
            const SizedBox(height: 20),
            if (widget.category != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealDim,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  widget.category!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
            if (widget.description != null && widget.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(widget.description!, style: const TextStyle(fontSize: 14, color: AppColors.textDim, height: 1.5)),
            ],
            const SizedBox(height: 20),
            if (widget.sets != null ||
                widget.repetitions != null ||
                widget.durationSeconds != null ||
                (widget.frequencyText != null && widget.frequencyText!.isNotEmpty)) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prescrição', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 12),
                    if (widget.sets != null) _InfoRow(label: 'Séries', value: '${widget.sets}'),
                    if (widget.repetitions != null) _InfoRow(label: 'Repetições', value: '${widget.repetitions}'),
                    if (widget.durationSeconds != null) _InfoRow(label: 'Duração', value: _formatDuration(widget.durationSeconds!)),
                    if (widget.frequencyText != null && widget.frequencyText!.isNotEmpty)
                      _InfoRow(label: 'Frequência', value: widget.frequencyText!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final url = widget.videoUrl;

    if (url == null || url.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off, size: 40, color: AppColors.textMuted),
              SizedBox(height: 8),
              Text('Nenhum vídeo disponível', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_isYoutube && _youtubeController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(controller: _youtubeController!),
          builder: (context, player) => player,
        ),
      );
    }

    if (_isDirectVideo && _videoController != null && _videoController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_videoController!),
              _VideoControls(controller: _videoController!),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_outline, size: 48, color: AppColors.teal),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir vídeo no navegador'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds >= 60) {
      final min = seconds ~/ 60;
      final sec = seconds % 60;
      return sec > 0 ? '${min}min ${sec}s' : '${min}min';
    }
    return '${seconds}s';
  }
}

class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoControls({required this.controller});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              if (widget.controller.value.isPlaying) {
                widget.controller.pause();
              } else {
                widget.controller.play();
              }
              setState(() {});
            },
          ),
          Expanded(
            child: VideoProgressIndicator(
              widget.controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.teal,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
            ),
          ),
          Text(
            _formatDuration(widget.controller.value.duration),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
