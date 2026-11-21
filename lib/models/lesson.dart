/// Content model for the deep educational sections (Hajj & Umrah, Fasting,
/// Fiqh): a [LessonSection] groups ordered [Lesson]s, and each lesson is a
/// sequence of typed [LessonBlock]s so the UI can render headings, rulings,
/// Quran/Sunnah quotes, warnings and du'a entries with distinct styling
/// instead of one long plain paragraph.
library;

sealed class LessonBlock {
  const LessonBlock();
}

/// A plain paragraph of body text.
class ParagraphBlock extends LessonBlock {
  final String text;
  /// Small-print citation shown under the paragraph (e.g. a Qur'an/hadith
  /// reference, a scholarly book, or "اجتهاد فقهي" for non-textual rulings).
  final String? source;
  const ParagraphBlock(this.text, {this.source});
}

/// A sub-heading inside a lesson's body.
class HeadingBlock extends LessonBlock {
  final String text;
  const HeadingBlock(this.text);
}

/// A bulleted or numbered list of short points.
class BulletsBlock extends LessonBlock {
  final List<String> items;
  final bool numbered;
  /// Small-print citation shown once under the whole list.
  final String? source;
  const BulletsBlock(this.items, {this.numbered = false, this.source});
}

/// A single Sharia ruling, optionally attributed to a specific school
/// (madhhab) — e.g. "عند الحنفية: ..." — left null for a point of agreement.
class RulingCard extends LessonBlock {
  final String? madhhab;
  final String text;
  /// Small-print citation shown under the ruling text.
  final String? source;
  const RulingCard(this.text, {this.madhhab, this.source});
}

/// A Qur'an verse or hadith quotation, with its source and, for hadith,
/// a grading note when one is well known (e.g. "متفق عليه").
class QuoteCard extends LessonBlock {
  final String text;
  final String source;
  final String? grade;
  const QuoteCard({required this.text, required this.source, this.grade});
}

/// A warning / common-mistake / important-notice callout.
class WarningCard extends LessonBlock {
  final String text;
  /// Small-print citation shown under the warning text.
  final String? source;
  const WarningCard(this.text, {this.source});
}

/// A supplication entry with its source and an optional note — rendered
/// with a copy button in the UI.
class DuaCard extends LessonBlock {
  final String text;
  final String source;
  final String? note;
  const DuaCard({required this.text, required this.source, this.note});
}

/// A small comparison table (e.g. the three types of Hajj across schools).
class ComparisonTable extends LessonBlock {
  final List<String> headers;
  final List<List<String>> rows;
  /// Small-print citation shown once under the whole table.
  final String? source;
  const ComparisonTable({required this.headers, required this.rows, this.source});
}

class Lesson {
  final String id;
  final String sectionId;
  final String title;
  final String summary;
  final int order;
  final List<LessonBlock> blocks;
  final List<String> references;
  final List<String> relatedLessonIds;

  const Lesson({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.summary,
    required this.order,
    required this.blocks,
    this.references = const [],
    this.relatedLessonIds = const [],
  });
}

class LessonSection {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final List<Lesson> lessons;

  const LessonSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lessons,
  });
}
