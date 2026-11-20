import 'package:flutter/material.dart';

import '../models/guide.dart';

/// Renders a single [GuideArticle] (e.g. Hajj, Fasting, a Fiqh topic) as a
/// simple readable document: intro, then each section as an expandable
/// block, ending with the trusted references it was drawn from.
class GuideArticleScreen extends StatelessWidget {
  const GuideArticleScreen({super.key, required this.article});

  final GuideArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (article.intro.isNotEmpty) ...[
            Text(
              article.intro,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(height: 1.8, fontSize: 15),
            ),
            const SizedBox(height: 20),
          ],
          for (final section in article.sections) _GuideSectionCard(section: section),
          if (article.references.isNotEmpty) ...[
            const Divider(height: 32),
            Text('المصادر', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final r in article.references)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $r', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ),
          ],
        ],
      ),
    );
  }
}

class _GuideSectionCard extends StatelessWidget {
  const _GuideSectionCard({required this.section});
  final GuideSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            section.heading,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section.body.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  section.body,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(height: 1.7),
                ),
              ),
            for (final step in section.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(Icons.circle, size: 7, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(height: 1.6),
                      ),
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
