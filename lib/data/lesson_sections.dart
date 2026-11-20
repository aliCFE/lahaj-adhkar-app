import '../models/lesson.dart';
import 'hajj_umrah_lessons.dart';

List<Lesson> _forSection(String sectionId) {
  final list = hajjUmrahLessons.where((l) => l.sectionId == sectionId).toList();
  list.sort((a, b) => a.order.compareTo(b.order));
  return list;
}

final LessonSection hajjSection = LessonSection(
  id: 'hajj',
  title: 'الحج',
  subtitle: 'من التعريف بالحج إلى أداء مناسكه خطوة بخطوة',
  icon: 'kaaba',
  lessons: _forSection('hajj'),
);

final LessonSection umrahSection = LessonSection(
  id: 'umrah',
  title: 'العمرة',
  subtitle: 'كيفية أداء العمرة كاملة من الإحرام إلى التحلل',
  icon: 'umrah',
  lessons: _forSection('umrah'),
);

final List<LessonSection> hajjUmrahSections = [hajjSection, umrahSection];

Lesson? lessonById(String id) {
  for (final l in hajjUmrahLessons) {
    if (l.id == id) return l;
  }
  return null;
}
