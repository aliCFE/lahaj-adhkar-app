/// A single topic/heading block within a [GuideArticle], e.g. "أركان الحج"
/// or "مفطرات الصيام". [body] holds plain paragraphs (blank line = new
/// paragraph); [steps] optionally holds an ordered checklist/sequence.
class GuideSection {
  final String heading;
  final String body;
  final List<String> steps;

  const GuideSection({
    required this.heading,
    this.body = '',
    this.steps = const [],
  });
}

/// A full guide topic (e.g. "الحج" or "صلاة الاستخارة") made of ordered
/// sections, with the trusted references it was drawn from.
class GuideArticle {
  final String id;
  final String title;
  final String icon;
  final String intro;
  final List<GuideSection> sections;
  final List<String> references;

  const GuideArticle({
    required this.id,
    required this.title,
    required this.icon,
    required this.intro,
    required this.sections,
    this.references = const [],
  });
}
