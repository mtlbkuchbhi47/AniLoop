import 'package:get/get.dart';
import 'package:hive/hive.dart';

class AniLoopSettingsController extends GetxController {
  late Box box;
  final appLanguage = 'English'.obs;
  final preferredAudio = 'Auto'.obs;
  final preferredSubtitle = 'English'.obs;
  final autoplay = true.obs;
  final autoSkipIntro = false.obs;

  static const languages = ['English', 'हिन्दी', '日本語', 'Español', 'Français', 'Deutsch'];
  static const audioLanguages = ['Auto', 'Japanese', 'English', 'Hindi', 'Tamil', 'Telugu', 'Korean', 'Spanish'];
  static const subtitleLanguages = ['Off', 'English', 'Hindi', 'Tamil', 'Telugu', 'Spanish', 'French'];

  @override
  void onInit() {
    box = Hive.box('settings');
    appLanguage.value = box.get('appLanguage', defaultValue: 'English');
    preferredAudio.value = box.get('preferredAudio', defaultValue: 'Auto');
    preferredSubtitle.value = box.get('preferredSubtitle', defaultValue: 'English');
    autoplay.value = box.get('autoplay', defaultValue: true);
    autoSkipIntro.value = box.get('autoSkipIntro', defaultValue: false);
    super.onInit();
  }

  Future<void> setLanguage(String value) async { appLanguage.value = value; await box.put('appLanguage', value); update(); }
  Future<void> setAudio(String value) async { preferredAudio.value = value; await box.put('preferredAudio', value); update(); }
  Future<void> setSubtitle(String value) async { preferredSubtitle.value = value; await box.put('preferredSubtitle', value); update(); }
  Future<void> setAutoplay(bool value) async { autoplay.value = value; await box.put('autoplay', value); update(); }
  Future<void> setAutoSkipIntro(bool value) async { autoSkipIntro.value = value; await box.put('autoSkipIntro', value); update(); }
}
