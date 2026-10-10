final RegExp _diacritics = RegExp(
  '[ؐ-ًؚ-ْٰۖ-ۭ]',
);
final RegExp _tatweel = RegExp('ـ');

/// Normalizes Arabic text for forgiving search matching:
/// - strips harakat/tanween/shadda/sukun and Quranic annotation marks
///   (content is fully diacritized, but a normal keyboard types plain text)
/// - strips tatweel (ـ)
/// - unifies alef/yaa variants so "اسلام"/"إسلام", "الله"/"آلله" etc. match
String normalizeArabic(String input) {
  var out = input.replaceAll(_diacritics, '').replaceAll(_tatweel, '');
  out = out
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ٱ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه');
  return out;
}
