import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aniloop/controllers/aniloop_settings_controller.dart';
import 'package:aniloop/themes/themes.dart';

class AniLoopSettingsView extends StatelessWidget {
  const AniLoopSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Get.find<AniLoopSettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          _section('App', [
            Obx(() => _choiceTile('App language', s.appLanguage.value, AniLoopSettingsController.languages, s.setLanguage, Icons.translate_rounded)),
            Obx(() => SwitchListTile.adaptive(title: const Text('Autoplay next episode'), value: s.autoplay.value, onChanged: s.setAutoplay, contentPadding: EdgeInsets.zero)),
            Obx(() => SwitchListTile.adaptive(title: const Text('Auto-skip intro'), subtitle: const Text('Works when intro markers are available'), value: s.autoSkipIntro.value, onChanged: s.setAutoSkipIntro, contentPadding: EdgeInsets.zero)),
          ]),
          _section('Playback', [
            Obx(() => _choiceTile('Preferred audio', s.preferredAudio.value, AniLoopSettingsController.audioLanguages, s.setAudio, Icons.record_voice_over_rounded)),
            Obx(() => _choiceTile('Preferred subtitles', s.preferredSubtitle.value, AniLoopSettingsController.subtitleLanguages, s.setSubtitle, Icons.subtitles_rounded)),
          ]),
          const SizedBox(height: 20),
          const Text('AniLoop uses the tracks exposed by the selected streaming source. Audio/subtitle switching is enabled when the source/player provides those tracks.', style: TextStyle(color: Colors.grey, height: 1.45)),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title.toUpperCase(), style: TextStyle(color: Themes.dark.secondaryHeaderColor, fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 12))),
      Container(decoration: BoxDecoration(color: Theme.of(Get.context!).cardColor, borderRadius: BorderRadius.circular(18)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), child: Column(children: children)),
    ]),
  );

  Widget _choiceTile(String title, String current, List<String> choices, Future<void> Function(String) onSelected, IconData icon) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(current),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () async {
      final value = await Get.dialog<String>(AlertDialog(title: Text(title), content: Column(mainAxisSize: MainAxisSize.min, children: choices.map((x) => RadioListTile<String>(value: x, groupValue: current, title: Text(x), onChanged: (v) => Get.back(result: v))).toList())));
      if (value != null) await onSelected(value);
    },
  );
}
