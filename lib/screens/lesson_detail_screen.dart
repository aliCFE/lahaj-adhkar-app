import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/lesson_sections.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';
import '../widgets/dark_mode_toggle.dart';

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
          const DarkModeToggle(),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: related, section: sectionFor(related))),
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
                    // Row reverses child order under ambient RTL Directionality, so
                    // "previous" is listed first to land on the physical right and
                    // "next" second to land on the physical left (same convention as
                    // the السابقة/التالية button rows in quran_reader_screen.dart and
                    // reader_screen.dart).
                    if (prev != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text('السابق: ${prev.title}', overflow: TextOverflow.ellipsis),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: prev, section: widget.section)),
                          ),
                        ),
                      ),
                    if (prev != null && next != null) const SizedBox(width: 8),
                    if (next != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: next, section: widget.section)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text('التالي: ${next.title}', overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
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
        ParagraphBlock() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                b.text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 15 * textScale, height: 1.8),
              ),
              if (b.source != null) _SourceCaption(source: b.source!, textScale: textScale),
            ],
          ),
        BulletsBlock() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < b.items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      b.numbered
                          ? Text('${i + 1}.', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 14 * textScale))
                          : Icon(Icons.circle, size: 6, color: Theme.of(context).colorScheme.primary),
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
              if (b.source != null) _SourceCaption(source: b.source!, textScale: textScale),
            ],
          ),
        RulingCard() => _Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            icon: Icons.gavel_rounded,
            label: b.madhhab != null ? 'حكم فقهي — ${b.madhhab}' : 'حكم فقهي',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(b.text, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 15 * textScale, height: 1.7)),
                if (b.source != null) _SourceCaption(source: b.source!, textScale: textScale),
              ],
            ),
          ),
        QuoteCard() => _Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            textColor: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.tertiaryContainer,
            textColor: Theme.of(context).colorScheme.onTertiaryContainer,
            icon: Icons.info_rounded,
            label: 'تنبيه',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(b.text, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 14 * textScale, height: 1.7)),
                if (b.source != null) _SourceCaption(source: b.source!, textScale: textScale, color: Theme.of(context).colorScheme.onTertiaryContainer),
              ],
            ),
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

/// Small-print citation line shown directly under a piece of content, e.g.
/// "المصدر: سورة البقرة، الآية 183" — distinct from the lesson-wide
/// "المصادر" list at the bottom, which cites the lesson's general reading.
class _SourceCaption extends StatelessWidget {
  const _SourceCaption({required this.source, required this.textScale, this.color});
  final String source;
  final double textScale;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'المصدر: $source',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 11 * textScale,
          height: 1.4,
          fontStyle: FontStyle.italic,
          color: color ?? Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.color, required this.icon, required this.label, required this.child, this.trailing, this.textColor});
  final Color color;
  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final labelColor = textColor ?? Colors.black54;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: labelColor),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: labelColor))),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          textColor != null ? DefaultTextStyle.merge(style: TextStyle(color: textColor), child: child) : child,
        ],
      ),
    );
  }
}

/// Renders each row as its own full-width card (label, then each other
/// column as a small heading + value) instead of a rigid [DataTable] grid,
/// since long Arabic sentences wrapped into narrow table cells become
/// cramped and hard to read.
class _ComparisonTableView extends StatelessWidget {
  const _ComparisonTableView({required this.table, required this.textScale});
  final ComparisonTable table;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in table.rows)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  row[0],
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 * textScale, color: Theme.of(context).colorScheme.primary),
                ),
                for (var i = 1; i < row.length; i++) ...[
                  const SizedBox(height: 10),
                  Text(
                    table.headers[i],
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11 * textScale, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.outline),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row[i],
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 14 * textScale, height: 1.6),
                  ),
                ],
              ],
            ),
          ),
        if (table.source != null) _SourceCaption(source: table.source!, textScale: textScale),
      ],
    );
  }
}
