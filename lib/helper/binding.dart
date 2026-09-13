import 'package:get/get.dart';
import 'package:aniloop/controllers/web_controller.dart';
import 'package:aniloop/controllers/theme_controller.dart';
import 'package:aniloop/controllers/aniloop_settings_controller.dart';
import 'package:aniloop/controllers/catalog_controller.dart';
import 'package:aniloop/controllers/runtime_data_controller.dart';

class Binding extends Bindings {
  @override
  void dependencies() {
    Get.put(CatalogController());
    Get.put(RuntimeController());
    Get.put(ThemeController());
    Get.put(AniLoopSettingsController());
    Get.put(WebController());
  }
}
