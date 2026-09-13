import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:aniloop/themes/themes.dart';
import 'package:aniloop/controllers/catalog_controller.dart';
import 'package:aniloop/controllers/runtime_data_controller.dart';
import 'package:aniloop/views/widgets/search/search_result_item.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CatalogController>(builder: (c) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: RuntimeController.isDarkMode
              ? Themes.dark.scaffoldBackgroundColor
              : Themes.light.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Obx(
              () => Center(
                child: Column(
                  children: [
                    const ResultContainer(),
                    if (RuntimeController.resultItemPerSource.length !=
                        c.sources.length)
                      Center(
                          child: CircularProgressIndicator(
                        color: RuntimeController.secondaryColor,
                      ))
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
