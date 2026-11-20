import '../models/lesson.dart';
import 'fasting_lessons.dart';
import 'fiqh_lessons.dart';
import 'hajj_umrah_lessons.dart';

final List<Lesson> _allLessons = [...hajjUmrahLessons, ...fastingLessons, ...fiqhLessons];

List<Lesson> _forSection(String sectionId) {
  final list = _allLessons.where((l) => l.sectionId == sectionId).toList();
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

final LessonSection fastingSection = LessonSection(
  id: 'fasting',
  title: 'الصيام',
  subtitle: 'من أساسياته وكيفيته إلى أعذاره وأنواعه وزكاة الفطر',
  icon: 'moon',
  lessons: _forSection('fasting'),
);

final LessonSection fiqhSection = LessonSection(
  id: 'fiqh',
  title: 'الفقه الإسلامي',
  subtitle: 'مدخل إلى الفقه، أحكامه، مصادره، مذاهبه، وأبوابه',
  icon: 'gavel',
  lessons: _forSection('fiqh'),
);

LessonSection sectionFor(Lesson lesson) {
  switch (lesson.sectionId) {
    case 'hajj':
      return hajjSection;
    case 'umrah':
      return umrahSection;
    case 'fasting':
      return fastingSection;
    case 'fiqh':
      return fiqhSection;
    default:
      return hajjSection;
  }
}

Lesson? lessonById(String id) {
  for (final l in _allLessons) {
    if (l.id == id) return l;
  }
  return null;
}
