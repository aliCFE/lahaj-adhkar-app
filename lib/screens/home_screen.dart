import 'package:flutter/material.dart';

import '../data/lesson_sections.dart';
import '../models/dhikr_item.dart';
import '../theme/icon_map.dart';
import 'all_adhkar_screen.dart';
import 'divine_names_screen.dart';
import 'group_screen.dart';
import 'hajj_umrah_home_screen.dart';
import 'lesson_list_screen.dart';
import 'quran_index_screen.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';
import 'situation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.groups,
    required this.futureGroups,
  });

  final List<DhikrGroup> groups;
  final List<DhikrGroup> futureGroups;

  Subcategory? _sub(String groupId, String subId) {
    final g = groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () =>
          const DhikrGroup(id: '', name: '', icon: '', subcategories: []),
    );
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'ماذا تريد أن تقرأ؟',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllAdhkarScreen(groups: groups),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search),
                          const SizedBox(width: 10),
                          Text(
                            'ابحث في كل الأذكار...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
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
                                MaterialPageRoute(
                                  builder: (_) => ReaderScreen(
                                    title: label,
                                    items: sub.items,
                                  ),
                                ),
                              ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: [
                      _BigSectionCard(
                        icon: Icons.menu_book_rounded,
                        title: 'القرآن الكريم',
                        subtitle: '604 صفحة، مع البحث والفهرسة',
                        background: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        foreground: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuranIndexScreen(),
                          ),
                        ),
                      ),
                      _BigSectionCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'أسماء الله الحسنى',
                        subtitle: '٩٩ اسمًا، مع المعنى وأثره',
                        background: const Color(0xFF181B3A),
                        foreground: const Color(0xFFE8C27A),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DivineNamesScreen(),
                          ),
                        ),
                      ),
                      _BigSectionCard(
                        icon: Icons.explore_rounded,
                        title: 'ماذا تفعل الآن؟',
                        subtitle: 'نعرض لك الذكر المناسب لموقفك',
                        background: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        foreground: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SituationScreen(groups: groups),
                          ),
                        ),
                      ),
                      _BigSectionCard(
                        icon: Icons.mosque_rounded,
                        title: 'الحج والعمرة',
                        subtitle: '١٣ درسًا بالتسلسل، مع مكتبة الأدعية',
                        background: const Color(0xFF1B3324),
                        foreground: const Color(0xFFD9B266),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HajjUmrahHomeScreen(),
                          ),
                        ),
                      ),
                      _BigSectionCard(
                        icon: Icons.nightlight_round,
                        title: 'الصيام',
                        subtitle: 'أحكامه وأركانه وشروطه',
                        background: const Color(0xFF16213B),
                        foreground: const Color(0xFF9FB8D9),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LessonListScreen(section: fastingSection),
                          ),
                        ),
                      ),
                      _BigSectionCard(
                        icon: Icons.gavel_rounded,
                        title: 'الفقه الإسلامي',
                        subtitle: 'مدخل إلى الفقه ومذاهبه وأبوابه',
                        background: const Color(0xFF2B1F14),
                        foreground: const Color(0xFFD2A857),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LessonListScreen(section: fiqhSection),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'أذكار حسب الموقف',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ...groups.map(
                    (g) => _GroupRow(
                      group: g,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupScreen(group: g),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قريبًا',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ...futureGroups.map(
                    (g) => _GroupRow(group: g, disabled: true, onTap: null),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllAdhkarScreen(groups: groups),
                        ),
                      ),
                      child: const Text('كل الأذكار'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigSectionCard extends StatelessWidget {
  const _BigSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              left: -24,
              bottom: -24,
              child: Icon(
                icon,
                size: 130,
                color: foreground.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 22, color: foreground),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.78),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
          subtitle: disabled
              ? const Text('قريبًا بإذن الله')
              : Text('${group.itemCount} ذكر'),
          trailing: disabled
              ? null
              : const Icon(Icons.arrow_back_ios_new, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
