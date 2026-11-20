import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../state/app_state.dart';
import 'lesson_detail_screen.dart';

/// Lists a [LessonSection]'s lessons in order, each with a read checkmark
/// (derived from the shared "recent" list — no separate progress store)
/// and an overall completion percentage at the top.
class LessonListScreen extends StatelessWidget {
  const LessonListScreen({super.key, required this.section});

  final LessonSection section;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final total = section.lessons.length;
    final readCount = section.lessons.where((l) => appState.recent.contains('lesson:${l.id}')).length;
    final progress = total == 0 ? 0.0 : readCount / total;

    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(section.subtitle, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(color: Colors.grey, height: 1.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: progress, minHeight: 8),
                ),
              ),
              const SizedBox(width: 10),
              Text('$readCount / $total'),
            ],
          ),
          const SizedBox(height: 16),
          for (final lesson in section.lessons) _LessonTile(lesson: lesson, section: section, isRead: appState.recent.contains('lesson:${lesson.id}')),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.section, required this.isRead});
  final Lesson lesson;
  final LessonSection section;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isRead ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isRead ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
          child: Text('${lesson.order}'),
        ),
        title: Text(lesson.title),
        subtitle: Text(lesson.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: isRead ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20) : const Icon(Icons.arrow_back_ios_new, size: 14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson, section: section)),
        ),
      ),
    );
  }
}
