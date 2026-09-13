import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:aniloop/controllers/aniloop_settings_controller.dart';

class LandscapePlayer extends StatefulWidget {
  final String vidUrl;
  final Map<String, String> headers;
  final String title;
  final int epi;
  const LandscapePlayer({super.key, required this.vidUrl, required this.headers, required this.title, required this.epi});
  @override State<LandscapePlayer> createState() => LandscapePlayerState();
}

class LandscapePlayerState extends State<LandscapePlayer> {
  late final Player player;
  late final VideoController controller;
  late final AniLoopSettingsController settings;
  StreamSubscription<Tracks>? _tracksSub;
  Tracks tracks = const Tracks();
  bool ready = false;

  @override
  void initState() {
    super.initState();
    settings = Get.find<AniLoopSettingsController>();
    player = Player();
    controller = VideoController(player);
    tracks = player.state.tracks;
    _tracksSub = player.stream.tracks.listen((value) {
      if (mounted) setState(() => tracks = value);
      if (!ready) _applyPreferredTracks(value);
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    log('AniLoop player: ${widget.vidUrl}');
    _open();
  }

  Future<void> _open() async {
    try {
      await player.open(Media(widget.vidUrl, httpHeaders: widget.headers), play: true);
    } catch (e) {
      log('Player error: $e');
    }
  }

  Future<void> _applyPreferredTracks(Tracks value) async {
    if (value.audio.length > 2 || value.subtitle.length > 2) {
      ready = true;
      final preferredAudio = settings.preferredAudio.value;
      final preferredSubtitle = settings.preferredSubtitle.value;
      final audio = _findAudio(value.audio, preferredAudio);
      if (audio != null) await player.setAudioTrack(audio);
      final sub = _findSubtitle(value.subtitle, preferredSubtitle);
      if (preferredSubtitle == 'Off') {
        await player.setSubtitleTrack(SubtitleTrack.no());
      } else if (sub != null) {
        await player.setSubtitleTrack(sub);
      }
    }
  }

  AudioTrack? _findAudio(List<AudioTrack> list, String wanted) {
    if (wanted == 'Auto') return AudioTrack.auto();
    final w = wanted.toLowerCase();
    for (final t in list) {
      final text = '${t.title ?? ''} ${t.language ?? ''}'.toLowerCase();
      if (text.contains(w) || (w == 'japanese' && (text.contains('ja') || text.contains('jpn')))) return t;
    }
    return null;
  }

  SubtitleTrack? _findSubtitle(List<SubtitleTrack> list, String wanted) {
    if (wanted == 'Off') return SubtitleTrack.no();
    final w = wanted.toLowerCase();
    for (final t in list) {
      final text = '${t.title ?? ''} ${t.language ?? ''}'.toLowerCase();
      if (text.contains(w) || (w == 'japanese' && text.contains('ja'))) return t;
    }
    return null;
  }

  String _label(String? title, String? language, String fallback) {
    final a = (title ?? '').trim();
    final b = (language ?? '').trim();
    if (a.isNotEmpty && b.isNotEmpty && a.toLowerCase() != b.toLowerCase()) return '$a ($b)';
    if (a.isNotEmpty) return a;
    if (b.isNotEmpty) return b;
    return fallback;
  }

  Future<void> _tracksSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff17171b),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: StatefulBuilder(builder: (context, setSheet) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Audio & Subtitles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white70)),
                ]),
                const SizedBox(height: 14),
                const Text('AUDIO', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                if (tracks.audio.length <= 2)
                  const Text('इस stream में अलग audio tracks उपलब्ध नहीं हैं।', style: TextStyle(color: Colors.white60))
                else
                  Wrap(spacing: 8, runSpacing: 8, children: tracks.audio.where((x) => x.id != 'no').map((x) => ChoiceChip(
                    label: Text(_label(x.title, x.language, 'Audio')),
                    selected: player.state.track.audio.id == x.id,
                    onSelected: (_) async { await player.setAudioTrack(x); setSheet(() {}); },
                  )).toList()),
                const SizedBox(height: 20),
                const Text('SUBTITLES', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                if (tracks.subtitle.length <= 2)
                  const Text('इस stream में अलग subtitle tracks उपलब्ध नहीं हैं।', style: TextStyle(color: Colors.white60))
                else
                  Wrap(spacing: 8, runSpacing: 8, children: tracks.subtitle.where((x) => x.id != 'auto').map((x) => ChoiceChip(
                    label: Text(x.id == 'no' ? 'Off' : _label(x.title, x.language, 'Subtitle')),
                    selected: player.state.track.subtitle.id == x.id,
                    onSelected: (_) async { await player.setSubtitleTrack(x); setSheet(() {}); },
                  )).toList()),
                const SizedBox(height: 16),
                Text('Available tracks source/stream से आते हैं। अगर Hindi dub या Hindi subtitle source में नहीं है, तो AniLoop उसे create नहीं करेगा.', style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 12, height: 1.4)),
              ]),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _tracksSub?.cancel();
    player.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(child: Video(controller: controller, controls: AdaptiveVideoControls)),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _tracksSheet,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.subtitles_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text('Audio & CC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          )),
        ),
      ]),
    );
  }
}
