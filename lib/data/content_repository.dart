import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/dhikr_item.dart';
import 'arabic_normalize.dart';

/// Group ids that ship with content in this release.
const List<String> kAvailableGroupFiles = [
  'daily',
  'sleep',
  'daily_life',
  'prayer_mosque',
  'travel',
  'protection',
  'distress',
  'gratitude',
  'health',
  'social',
  'life_events',
  'weather',
  'bereavement',
];

/// Groups whose data model exists but content is not yet populated.
/// Shown in the UI as "قريبًا" (coming soon) rather than hidden entirely,
/// so the taxonomy is visibly complete without ever faking content.
const List<DhikrGroup> kFutureGroups = [
  DhikrGroup(id: 'ramadan', name: 'رمضان والصيام', icon: 'nights_stay', subcategories: []),
  DhikrGroup(id: 'hajj', name: 'الحج والعمرة', icon: 'terrain', subcategories: []),
];

class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  List<DhikrGroup>? _groups;

  Future<List<DhikrGroup>> loadAll() async {
    if (_groups != null) return _groups!;
    final groups = <DhikrGroup>[];
    for (final fileId in kAvailableGroupFiles) {
      final raw = await rootBundle.loadString('assets/data/$fileId.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      groups.add(_parseGroup(json));
    }
    _groups = groups;
    return groups;
  }

  DhikrGroup _parseGroup(Map<String, dynamic> json) {
    final groupId = json['id'] as String;
    final subcats = (json['subcategories'] as List<dynamic>).map((sc) {
      final scMap = sc as Map<String, dynamic>;
      final subId = scMap['id'] as String;
      final items = (scMap['items'] as List<dynamic>)
          .map((it) => DhikrItem.fromJson(it as Map<String, dynamic>, subId))
          .toList();
      return Subcategory(
        id: subId,
        name: scMap['name'] as String,
        groupId: groupId,
        items: items,
      );
    }).toList();

    return DhikrGroup(
      id: groupId,
      name: json['name'] as String,
      icon: json['icon'] as String,
      subcategories: subcats,
    );
  }

  List<DhikrItem> search(List<DhikrGroup> groups, String query) {
    final q = normalizeArabic(query.trim());
    if (q.isEmpty) return [];
    final results = <DhikrItem>[];
    for (final group in groups) {
      for (final item in group.allItems) {
        final matchesText = normalizeArabic(item.arabicText).contains(q);
        final matchesOccasion = normalizeArabic(item.occasion).contains(q);
        final matchesTag = item.tags.any((t) => normalizeArabic(t).contains(q));
        if (matchesText || matchesOccasion || matchesTag) {
          results.add(item);
        }
      }
    }
    return results;
  }

  /// Items from other categories that share at least one tag with [item] —
  /// surfaced as "ذو صلة" instead of duplicating the same text into every
  /// category it could plausibly belong to.
  List<DhikrItem> relatedItems(List<DhikrGroup> groups, DhikrItem item) {
    final related = <DhikrItem>[];
    for (final group in groups) {
      for (final other in group.allItems) {
        if (other.id == item.id) continue;
        if (other.categoryId == item.categoryId) continue;
        if (other.tags.any((t) => item.tags.contains(t))) {
          related.add(other);
        }
      }
    }
    return related;
  }
}
