import 'package:flutter/material.dart';

import '../models/dhikr_item.dart';
import '../theme/icon_map.dart';
import 'all_adhkar_screen.dart';
import 'divine_names_screen.dart';
import 'group_screen.dart';
import 'quran_index_screen.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';
import 'situation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.groups, required this.futureGroups});

  final List<DhikrGroup> groups;
  final List<DhikrGroup> futureGroups;

  Subcategory? _sub(String groupId, String subId) {
    final g = groups.firstWhere((g) => g.id == groupId, orElse: () => const DhikrGroup(id: '', name: '', icon: '', subcategories: []));
    try {
      return g.subcategories.firstWhere((s) => s.id == subId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      (Icons.wb_sunny_rounded, 'أذكار الصباح', _sub('daily', 'morning')),
      (Icons.bedtime_rounded, 'أذكار المساء', _sub('daily', 'evening')),
      (Icons.nights_stay_rounded, 'أذكار النوم', _sub('sleep', 'before_sleep')),
      (Icons.mosque_rounded, 'بعد الصلاة', _sub('daily', 'after_salah')),
      (Icons.circle_rounded, 'التسبيح', _sub('daily', 'tasbih_tahlil')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/icon.png', width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('لهج'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(groups: groups)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('ماذا تريد أن تقرأ؟', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AllAdhkarScreen(groups: groups)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10),
                  Text('ابحث في كل الأذكار...', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: shortcuts.map((s) {
              final (icon, label, sub) = s;
              return _ShortcutCard(
                icon: icon,
                label: label,
                onTap: sub == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReaderScreen(title: label, items: sub.items)),
                        ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('القرآن الكريم'),
              subtitle: const Text('604 صفحة، مع البحث والفهرسة بالسور والأجزاء'),
              trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuranIndexScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: const Color(0xFF181B3A),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DivineNamesScreen()),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFFE8C27A)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('أسماء الله الحسنى', style: TextStyle(color: Color(0xFFE8C27A), fontWeight: FontWeight.bold)),
                          Text('٩٩ اسمًا، مع الشرح ومواضع ورودها في القرآن', style: TextStyle(color: Color(0xFFB9BBD8), fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFE8C27A)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: const Icon(Icons.explore_rounded),
              title: const Text('ماذا تفعل الآن؟'),
              subtitle: const Text('أخبرنا بموقفك، ونعرض لك الذكر المناسب فورًا'),
              trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SituationScreen(groups: groups)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('أذكار حسب الموقف', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...groups.map((g) => _GroupRow(group: g, onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupScreen(group: g)),
              ))),
          const SizedBox(height: 8),
          Text('قريبًا', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          ...futureGroups.map((g) => _GroupRow(group: g, disabled: true, onTap: null)),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllAdhkarScreen(groups: groups)),
              ),
              child: const Text('كل الأذكار'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(label, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group, this.onTap, this.disabled = false});
  final DhikrGroup group;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: ListTile(
          leading: Icon(iconForName(group.icon)),
          title: Text(group.name),
          subtitle: disabled ? const Text('قريبًا بإذن الله') : Text('${group.itemCount} ذكر'),
          trailing: disabled ? null : const Icon(Icons.arrow_back_ios_new, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
