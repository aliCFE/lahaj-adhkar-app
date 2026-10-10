import 'package:flutter/material.dart';

import '../models/dhikr_item.dart';
import '../models/source.dart';

/// Internal QA screen — not part of the normal user flow.
/// Lists every shipped item with its full source/authenticity metadata so
/// the content can be audited at a glance, including duplicate-text checks.
class ContentReviewScreen extends StatelessWidget {
  const ContentReviewScreen({super.key, required this.groups});

  final List<DhikrGroup> groups;

  @override
  Widget build(BuildContext context) {
    final allItems = groups.expand((g) => g.allItems.map((it) => (g, it))).toList();
    final textCounts = <String, int>{};
    for (final (_, it) in allItems) {
      textCounts[it.arabicText] = (textCounts[it.arabicText] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: Text('مراجعة المحتوى — ${allItems.length} ذكر')),
      body: ListView.builder(
        itemCount: allItems.length,
        itemBuilder: (context, i) {
          final (group, item) = allItems[i];
          final isDuplicateText = textCounts[item.arabicText]! > 1;
          return ExpansionTile(
            title: Text('${group.name} ▸ ${item.id}', style: const TextStyle(fontSize: 13)),
            subtitle: Text(
              item.occasion,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: isDuplicateText ? Colors.orange : null),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.arabicText, textDirection: TextDirection.rtl),
                    const SizedBox(height: 8),
                    Text('التكرار: ${item.repeatCount.label}'),
                    Text('الوسوم: ${item.tags.join('، ')}'),
                    if (isDuplicateText)
                      const Text('نص مكرر في أكثر من فئة', style: TextStyle(color: Colors.orange)),
                    const SizedBox(height: 8),
                    const Text('المصادر:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...item.sources.map((s) => _SourceLine(source: s)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source});
  final Source source;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '• ${source.sourceName}'
        '${source.hadithNumber != null ? ' (${source.hadithNumber})' : ''}'
        ' — ${authenticityLabel(source.authenticity)}'
        '${source.notes != null ? '\n  ${source.notes}' : ''}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
