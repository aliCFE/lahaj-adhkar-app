import 'repeat_count.dart';
import 'source.dart';

class DhikrItem {
  final String id;
  final String categoryId;
  final String arabicText;
  final String? translation;
  final RepeatCount repeatCount;
  final String occasion;
  final List<String> tags;
  final List<Source> sources;
  final bool isRuqyah;
  final bool medicalDisclaimer;

  const DhikrItem({
    required this.id,
    required this.categoryId,
    required this.arabicText,
    this.translation,
    required this.repeatCount,
    required this.occasion,
    required this.tags,
    required this.sources,
    this.isRuqyah = false,
    this.medicalDisclaimer = false,
  });

  factory DhikrItem.fromJson(Map<String, dynamic> json, String categoryId) {
    return DhikrItem(
      id: json['id'] as String,
      categoryId: categoryId,
      arabicText: json['arabicText'] as String,
      translation: json['translation'] as String?,
      repeatCount: RepeatCount.fromJson(json['repeatCount'] as Map<String, dynamic>),
      occasion: json['occasion'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      sources: (json['sources'] as List<dynamic>)
          .map((e) => Source.fromJson(e as Map<String, dynamic>))
          .toList(),
      isRuqyah: json['isRuqyah'] as bool? ?? false,
      medicalDisclaimer: json['medicalDisclaimer'] as bool? ?? false,
    );
  }
}

class Subcategory {
  final String id;
  final String name;
  final String groupId;
  final List<DhikrItem> items;

  const Subcategory({
    required this.id,
    required this.name,
    required this.groupId,
    required this.items,
  });
}

class DhikrGroup {
  final String id;
  final String name;
  final String icon;
  final List<Subcategory> subcategories;

  const DhikrGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });

  List<DhikrItem> get allItems =>
      subcategories.expand((s) => s.items).toList(growable: false);

  int get itemCount => allItems.length;
}
