import 'package:flutter/material.dart';

import '../data/hajj_fasting_content.dart';
import '../models/guide.dart';
import 'guide_article_screen.dart';

/// Entry point for the Hajj & Fasting guide section: a short list of
/// topic cards, each opening its full [GuideArticleScreen].
class HajjFastingScreen extends StatelessWidget {
  const HajjFastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحج والصيام')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final article in hajjFastingArticles) _ArticleCard(article: article),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});
  final GuideArticle article;

  @override
  Widget build(BuildContext context) {
    final icon = article.icon == 'kaaba' ? Icons.mosque_rounded : Icons.nightlight_round;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(article.title),
        subtitle: Text('${article.sections.length} أقسام'),
        trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GuideArticleScreen(article: article)),
        ),
      ),
    );
  }
}
