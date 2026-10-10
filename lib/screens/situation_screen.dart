import 'package:flutter/material.dart';

import '../models/dhikr_item.dart';
import 'all_adhkar_screen.dart';
import 'reader_screen.dart';

class _Situation {
  const _Situation(this.label, this.icon, this.resolve);
  final String label;
  final IconData icon;
  final List<DhikrItem> Function(List<DhikrGroup> groups) resolve;
}

List<DhikrItem> _byTag(List<DhikrGroup> groups, String tag) {
  final items = <DhikrItem>[];
  for (final g in groups) {
    for (final it in g.allItems) {
      if (it.tags.contains(tag)) items.add(it);
    }
  }
  return items;
}

List<DhikrItem> _bySubcategory(List<DhikrGroup> groups, String groupId, String subId) {
  final group = groups.firstWhere((g) => g.id == groupId, orElse: () => const DhikrGroup(id: '', name: '', icon: '', subcategories: []));
  final sub = group.subcategories.firstWhere((s) => s.id == subId, orElse: () => const Subcategory(id: '', name: '', groupId: '', items: []));
  return sub.items;
}

List<DhikrItem> _byGroup(List<DhikrGroup> groups, String groupId) {
  final group = groups.firstWhere((g) => g.id == groupId, orElse: () => const DhikrGroup(id: '', name: '', icon: '', subcategories: []));
  return group.allItems;
}

final List<_Situation> _situations = [
  _Situation('أنا ذاهب للنوم', Icons.bedtime_rounded, (g) => _bySubcategory(g, 'sleep', 'before_sleep')),
  _Situation('أنا استيقظت', Icons.wb_twilight_rounded, (g) => _bySubcategory(g, 'sleep', 'waking_up')),
  _Situation('أنا ذاهب للصلاة', Icons.mosque_rounded, (g) => _bySubcategory(g, 'prayer_mosque', 'going_to_mosque')),
  _Situation('انتهيت من الصلاة', Icons.check_circle_rounded, (g) => _bySubcategory(g, 'daily', 'after_salah')),
  _Situation('أنا خارج من المنزل', Icons.logout_rounded, (g) => _byTag(g, 'الخروج من المنزل')),
  _Situation('أنا داخل المنزل', Icons.login_rounded, (g) => _byTag(g, 'دخول المنزل')),
  _Situation('أنا مسافر', Icons.flight_rounded, (g) => _bySubcategory(g, 'travel', 'setting_off')),
  _Situation('أنا أشعر بالضيق', Icons.self_improvement_rounded, (g) => _byGroup(g, 'distress')),
  _Situation('أريد أن أستغفر', Icons.volunteer_activism_rounded, (g) => _bySubcategory(g, 'daily', 'istighfar')),
  _Situation('أريد أن أسبح', Icons.circle_rounded, (g) => _bySubcategory(g, 'daily', 'tasbih_tahlil')),
  _Situation('أريد التحصين', Icons.shield_rounded, (g) => _byGroup(g, 'protection')),
  _Situation('أنا مريض', Icons.healing_rounded, (g) => _byGroup(g, 'health')),
];

class SituationScreen extends StatelessWidget {
  const SituationScreen({super.key, required this.groups});

  final List<DhikrGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ماذا تفعل الآن؟')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _situations.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == _situations.length) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: const Icon(Icons.search_rounded),
                title: const Text('أريد دعاءً عامًا — تصفّح كل الأذكار'),
                trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AllAdhkarScreen(groups: groups)),
                ),
              ),
            );
          }
          final s = _situations[i];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: ListTile(
              leading: Icon(s.icon),
              title: Text(s.label),
              trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
              onTap: () {
                final items = s.resolve(groups);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReaderScreen(title: s.label, items: items)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
