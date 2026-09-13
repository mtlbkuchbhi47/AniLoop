import 'dart:convert';
import 'package:http/http.dart' as http;

class AniListMedia {
  final int id;
  final String title;
  final String? english;
  final String? native;
  final String? description;
  final String? cover;
  final String? banner;
  final String? format;
  final String? status;
  final int? episodes;
  final int? score;
  final List<String> genres;
  final String? studio;
  const AniListMedia({required this.id, required this.title, this.english, this.native, this.description, this.cover, this.banner, this.format, this.status, this.episodes, this.score, this.genres=const [], this.studio});
  factory AniListMedia.fromJson(Map<String,dynamic> j) {
    final t=(j['title'] ?? <String,dynamic>{}) as Map<String,dynamic>;
    final studios=((j['studios']?['nodes'] as List?) ?? const []).whereType<Map<String,dynamic>>().toList();
    return AniListMedia(
      id: (j['id'] as num?)?.toInt() ?? 0,
      title: (t['english'] ?? t['romaji'] ?? t['native'] ?? 'Unknown').toString(),
      english:t['english']?.toString(), native:t['native']?.toString(),
      description:j['description']?.toString().replaceAll(RegExp(r'<[^>]*>'),'').trim(),
      cover:j['coverImage']?['extraLarge']?.toString() ?? j['coverImage']?['large']?.toString() ?? j['coverImage']?['medium']?.toString(),
      banner:j['bannerImage']?.toString(), format:j['format']?.toString(), status:j['status']?.toString(),
      episodes:(j['episodes'] as num?)?.toInt(), score:(j['averageScore'] as num?)?.toInt(),
      genres:((j['genres'] as List?) ?? const []).map((e)=>e.toString()).toList(),
      studio:studios.isNotEmpty ? studios.first['name']?.toString() : null,
    );
  }
}

class AniListService {
  static const endpoint='https://graphql.anilist.co';
  static const browseQuery='''query (\$search:String, \$sort:[MediaSort], \$page:Int) { Page(page:\$page, perPage:20) { media(type:ANIME, search:\$search, sort:\$sort) { id title { romaji english native } description format status episodes averageScore genres studios(isMain:true) { nodes { name } } bannerImage coverImage { medium large extraLarge } } } }''';
  static const detailQuery='''query (\$search:String) { Media(type:ANIME, search:\$search) { id title { romaji english native } description format status episodes averageScore genres studios(isMain:true) { nodes { name } } bannerImage coverImage { medium large extraLarge } } }''';
  static Future<List<AniListMedia>> browse(String sort) async {
    final r=await http.post(Uri.parse(endpoint),headers:{'Content-Type':'application/json'},body:jsonEncode({'query':browseQuery,'variables':{'sort':sort,'page':1}}));
    if(r.statusCode!=200) throw Exception('AniList unavailable');
    final list=(jsonDecode(r.body)['data']?['Page']?['media'] as List?) ?? const [];
    return list.whereType<Map<String,dynamic>>().map(AniListMedia.fromJson).toList();
  }
  static Future<List<AniListMedia>> search(String value) async {
    final r=await http.post(Uri.parse(endpoint),headers:{'Content-Type':'application/json'},body:jsonEncode({'query':browseQuery,'variables':{'search':value,'sort':'SEARCH_MATCH','page':1}}));
    if(r.statusCode!=200) throw Exception('Search unavailable');
    final list=(jsonDecode(r.body)['data']?['Page']?['media'] as List?) ?? const [];
    return list.whereType<Map<String,dynamic>>().map(AniListMedia.fromJson).toList();
  }
  static Future<AniListMedia?> details(String value) async { try { final r=await http.post(Uri.parse(endpoint),headers:{'Content-Type':'application/json'},body:jsonEncode({'query':detailQuery,'variables':{'search':value}})); if(r.statusCode!=200)return null; final item=jsonDecode(r.body)['data']?['Media']; return item is Map<String,dynamic>?AniListMedia.fromJson(item):null; } catch(_){return null;} }
}
