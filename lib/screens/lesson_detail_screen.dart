import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/lesson_sections.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';

/// Renders a single [Lesson]'s blocks with per-type styling (headings,
/// bullet lists, ruling/quote/warning/du'a cards, comparison tables),
/// a favorite toggle, the app's shared font-size control, and prev/next
/// navigation within the same [LessonSection].
class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key, required this.lesson, required this.section});

  final Lesson lesson;
  final LessonSection section;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().markRecent('lesson:${widget.lesson.id}');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lesson = widget.lesson;
    final favId = 'lesson:${lesson.id}';
    final ordered = widget.section.lessons;
    final index = ordered.indexWhere((l) => l.id == lesson.id);
    final prev = index > 0 ? ordered[index - 1] : null;
    final next = index >= 0 && index < ordered.length - 1 ? ordered[index + 1] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'تصغير الخط',
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: () => appState.setTextScale((appState.textScale - 0.1).clamp(0.8, 1.6)),
          ),
          IconButton(
            tooltip: 'تكبير الخط',
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: () => appState.setTextScale((appState.textScale + 0.1).clamp(0.8, 1.6)),
          ),
          IconButton(
            tooltip: 'إضافة إلى المفضلة',
            icon: Icon(appState.isFavorite(favId) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            onPressed: () => appState.toggleFavorite(favId),
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            lesson.summary,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13 * appState.textScale, height: 1.6),
          ),
          const SizedBox(height: 16),
          for (final block in lesson.blocks) _LessonBlockView(block: block, textScale: appState.textScale),
          if (lesson.references.isNotEmpty) ...[
            const Divider(height: 32),
            Text('المصادر', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final r in lesson.references)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $r', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ),
          ],
          if (lesson.relatedLessonIds.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('دروس ذات صلة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lesson.relatedLessonIds.map((id) {
                final related = lessonById(id);
                if (related == null) return const SizedBox.shrink();
                return ActionChip(
                  label: Text(related.title),
                  onPressed: () {
                    final relatedSection = related.sectionId == hajjSection.id ? hajjSection : umrahSection;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: related, section: relatedSection)),
                    );
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: (prev != null || next != null)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    if (next != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text('التالي: ${next.title}', overflow: TextOverflow.ellipsis),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: next, section: widget.section)),
                          ),
                        ),
                      ),
                    if (prev != null && next != null) const SizedBox(width: 8),
                    if (prev != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: Text('السابق: ${prev.title}', overflow: TextOverflow.ellipsis),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: prev, section: widget.section)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _LessonBlockView extends StatelessWidget {
  const _LessonBlockView({required this.block, required this.textScale});
  final LessonBlock block;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final b = block;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: switch (b) {
        HeadingBlock() => Text(
            b.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17 * textScale, color: Theme.of(context).colorScheme.primary),
          ),
        ParagraphBlock() => Text(
            b.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 15 * textScale, height: 1.8),
          ),
        BulletsBlock() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < b.items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: b.numbered
                            ? Text('${i + 1}.', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 14 * textScale))
                            : Icon(Icons.circle, size: 6, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b.items[i],
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 15 * textScale, height: 1.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        RulingCard() => _Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            icon: Icons.gavel_rounded,
            label: b.madhhab != null ? 'حكم فقهي — ${b.madhhab}' : 'حكم فقهي',
            child: Text(b.text, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 15 * textScale, height: 1.7)),
          ),
        QuoteCard() => _Card(
            color: const Color(0xFFF0E6D2),
            icon: Icons.menu_book_rounded,
            label: b.grade != null ? '${b.source} — ${b.grade}' : b.source,
            child: Text(
              b.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15 * textScale, height: 1.9, fontWeight: FontWeight.w600),
            ),
          ),
        WarningCard() => _Card(
            color: const Color(0xFFFBE3D0),
            icon: Icons.info_rounded,
            label: 'تنبيه',
            child: Text(b.text, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 14 * textScale, height: 1.7)),
          ),
        DuaCard() => _Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            icon: Icons.favorite_rounded,
            label: b.note ?? b.source,
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              tooltip: 'نسخ الدعاء',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: b.text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الدعاء')));
              },
            ),
            child: Text(
              b.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15 * textScale, height: 1.9, fontWeight: FontWeight.w600),
            ),
          ),
        ComparisonTable() => _ComparisonTableView(table: b, textScale: textScale),
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.color, required this.icon, required this.label, required this.child, this.trailing});
  final Color color;
  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54))),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ComparisonTableView extends StatelessWidget {
  const _ComparisonTableView({required this.table, required this.textScale});
  final ComparisonTable table;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primaryContainer),
        columns: [
          for (final h in table.headers)
            DataColumn(label: Text(h, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * textScale))),
        ],
        rows: [
          for (final row in table.rows)
            DataRow(cells: [
              for (final cell in row)
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(cell, textDirection: TextDirection.rtl, softWrap: true, style: TextStyle(fontSize: 13 * textScale, height: 1.5)),
                  ),
                ),
            ]),
        ],
      ),
    );
  }
}
