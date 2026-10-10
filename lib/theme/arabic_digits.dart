const _easternDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Converts a non-negative integer to Eastern Arabic-Indic numerals,
/// used for ayah markers and page numbers in the Quran reader to match
/// the traditional Mushaf printing convention.
String toEasternDigits(int n) {
  return n.toString().split('').map((c) {
    final d = int.tryParse(c);
    return d == null ? c : _easternDigits[d];
  }).join();
}
