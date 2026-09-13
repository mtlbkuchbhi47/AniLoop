import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:aniloop/views/widgets/details/details.dart';
import 'package:aniloop/controllers/catalog_controller.dart';
import 'package:aniloop/controllers/runtime_data_controller.dart';

class GridCatalog extends StatelessWidget {
  const GridCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CatalogController>(builder: (c) {
      return LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200 ? 7 : width >= 900 ? 6 : width >= 650 ? 5 : width >= 480 ? 4 : 3;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(10, 112, 10, 24),
          itemCount: RuntimeController.posters.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 12, mainAxisSpacing: 14, childAspectRatio: .62, crossAxisCount: columns,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                c.getFilmDetails(RuntimeController.moreDetailsUrls[index], index);
                Get.to(() => FilmDetails(title: RuntimeController.titles[index]), transition: Transition.fade);
              },
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.network(RuntimeController.posters[index], fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xff202024), child: const Icon(Icons.broken_image_outlined))),
                    Positioned(top: 8, left: 8, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(.75), borderRadius: BorderRadius.circular(7)),
                      child: const Text('HD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    )),
                  ]),
                )),
                const SizedBox(height: 7),
                Text(RuntimeController.titles[index], style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            );
          },
        );
      });
    });
  }
}
