import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/lesson_sections.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';
import 'hajj_umrah_duas_screen.dart';
import 'lesson_detail_screen.dart';
import 'lesson_list_screen.dart';

const _kBg = Color(0xFF122117);
const _kCard = Color(0xFF1B3324);
const _kGold = Color(0xFFD9B266);

/// Home page for the Hajj & Umrah educational section: a hero header,
/// a quick "what's the difference" card, the two section cards (each
/// showing lesson count and reading progress), a continue-last-lesson
/// banner when one exists, and a link to the du'a library.
class HajjUmrahHomeScreen extends StatelessWidget {
  const HajjUmrahHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lastLessonId = appState.recent.firstWhere(
      (id) => id.startsWith('lesson:') && lessonById(id.substring(7)) != null,
      orElse: () => '',
    );
    final lastLesson = lastLessonId.isEmpty ? null : lessonById(lastLessonId.substring(7));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('الحج والعمرة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B3324), Color(0xFF0E1A12)], begin: Alignment.topRight, end: Alignment.bottomLeft),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.mosque_rounded, size: 46, color: _kGold),
                const SizedBox(height: 12),
                const Text('رحلتك إلى بيت الله الحرام', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'دليل تعليمي شامل للحج والعمرة، من التعريف بالمناسك إلى أدائها خطوة بخطوة، '
                  'وفق منهج أهل السنة والجماعة.',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Color(0xFFCBD6CE), fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
          if (lastLesson != null) ...[
            const SizedBox(height: 16),
            Material(
              color: _kCard,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonDetailScreen(
                      lesson: lastLesson,
                      section: lastLesson.sectionId == hajjSection.id ? hajjSection : umrahSection,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: _kGold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('متابعة آخر درس', style: TextStyle(color: Color(0xFFCBD6CE), fontSize: 11)),
                            Text(lastLesson.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          for (final section in hajjUmrahSections) _SectionCard(section: section),
          const SizedBox(height: 8),
          const _DifferenceCard(),
          const SizedBox(height: 12),
          Material(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HajjUmrahDuasScreen())),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.favorite_rounded, color: _kGold),
                    SizedBox(width: 12),
                    Expanded(child: Text('أدعية الحج والعمرة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white54),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final LessonSection section;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final total = section.lessons.length;
    final readCount = section.lessons.where((l) => appState.recent.contains('lesson:${l.id}')).length;
    final progress = total == 0 ? 0.0 : readCount / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonListScreen(section: section))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_stories_rounded, color: _kGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(section.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          Text('$total دروس', style: const TextStyle(color: Color(0xFFCBD6CE), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white54),
                  ],
                ),
                const SizedBox(height: 10),
                Text(section.subtitle, textDirection: TextDirection.rtl, style: const TextStyle(color: Color(0xFFCBD6CE), fontSize: 12, height: 1.5)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.white12, color: _kGold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifferenceCard extends StatelessWidget {
  const _DifferenceCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('الحكم', 'الحج ركن من أركان الإسلام، فرض عين على المستطيع مرة في العمر.', 'واجبة عند الشافعية والحنابلة، وسنة مؤكدة عند الحنفية والمالكية.'),
      ('الزمن', 'له أشهر محددة فقط (شوال، ذو القعدة، عشر ذي الحجة الأولى).', 'تصح في أي وقت من العام.'),
      ('الأركان', 'يشمل الوقوف بعرفة والمبيت بمزدلفة ومنى ورمي الجمرات، إضافة إلى الطواف والسعي.', 'الإحرام والطواف والسعي والحلق أو التقصير فقط.'),
      ('المدة', 'عدة أيام متتالية.', 'يمكن أداؤها خلال ساعات.'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('الفرق بين الحج والعمرة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          for (final (label, hajj, umrah) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, textDirection: TextDirection.rtl, style: TextStyle(color: _kGold, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('الحج: $hajj', textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.5)),
                  Text('العمرة: $umrah', textDirection: TextDirection.rtl, style: const TextStyle(color: Color(0xFFCBD6CE), fontSize: 12.5, height: 1.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
