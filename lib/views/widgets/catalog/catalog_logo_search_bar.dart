import 'package:aniloop/controllers/runtime_data_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:aniloop/themes/themes.dart';
import 'package:aniloop/views/widgets/search/search.dart';
import 'package:aniloop/controllers/theme_controller.dart';
import 'package:aniloop/controllers/catalog_controller.dart';
import 'package:aniloop/views/aniloop_settings_view.dart';

class LogoAndSearchBar extends StatefulWidget {
  const LogoAndSearchBar({super.key});

  @override
  State<LogoAndSearchBar> createState() => _LogoAndSearchBarState();
}

class _LogoAndSearchBarState extends State<LogoAndSearchBar> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CatalogController>(builder: (c) {
      return Container(
        color: RuntimeController.isDarkMode
            ? Themes.dark.scaffoldBackgroundColor
            : Themes.light.scaffoldBackgroundColor,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Image.asset(
                "assets/images/logo.png",
                width: 38,
                height: 38,
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 6), child: Text('AniLoop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width - 125,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Stack(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: RuntimeController.isDarkMode
                          ? Themes.dark.unselectedWidgetColor
                          : Themes.light.unselectedWidgetColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      controller: textEditingController,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.requestFocus();
                      },
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          c.getSerachItemResult(value);
                          FocusManager.instance.primaryFocus?.unfocus();
                          Get.to(
                              SearchView(
                                searchVAlue: value,
                                textEditingController: textEditingController,
                              ),
                              transition: Transition.downToUp);
                        }
                      },
                      style: TextStyle(
                          color: !RuntimeController.isDarkMode
                              ? Themes.dark.primaryColor
                              : Themes.light.primaryColor,
                          fontSize: 15,
                          letterSpacing: 1),
                      decoration: InputDecoration.collapsed(
                        hintText: "Search anything...",
                        hintStyle: TextStyle(
                          color: RuntimeController.isDarkMode
                              ? Themes.dark.hintColor
                              : Themes.light.hintColor,
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.search_rounded,
                        color: Color.fromARGB(255, 140, 140, 140),
                      ),
                    ),
                  )
                ],
              ),
            ),
            IconButton(
              tooltip: "Settings",
              onPressed: () => Get.to(() => AniLoopSettingsView(), transition: Transition.cupertino),
              icon: const Icon(Icons.tune_rounded),
            ),
            GestureDetector(
              onTapUp: (details) async {
                await Get.find<ThemeController>().changeTheme();
              },
              child: Icon(
                Icons.light_mode_rounded,
                color: RuntimeController.isDarkMode
                    ? Themes.dark.hintColor
                    : Themes.light.highlightColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}
