import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/quran.dart';
import 'arabic_normalize.dart';

class QuranRepository {
  QuranRepository._();
  static final QuranRepository instance = QuranRepository._();

  List<QuranSurah>? _surahs;
  List<QuranAyah>? _ayahs;
  Map<int, List<QuranAyah>>? _byPage;
  Map<int, List<QuranAyah>>? _bySurah;
  Map<int, List<MushafAyahGlyph>>? _mushafByPage;

  List<QuranSurah> get surahs => _surahs!;
  List<QuranAyah> get ayahs => _ayahs!;

  bool get isLoaded => _surahs != null;

  Future<void> load() async {
    if (_surahs != null) return;
    final surahRaw = await rootBundle.loadString('assets/data/quran/surahs.json');
    final ayahRaw = await rootBundle.loadString('assets/data/quran/ayahs.json');
    final mushafRaw = await rootBundle.loadString('assets/data/quran/mushaf_pages.json');

    final surahJson = jsonDecode(surahRaw) as List<dynamic>;
    final ayahJson = jsonDecode(ayahRaw) as List<dynamic>;
    final mushafJson = jsonDecode(mushafRaw) as Map<String, dynamic>;

    _surahs = surahJson.map((e) => QuranSurah.fromJson(e as Map<String, dynamic>)).toList();
    _ayahs = ayahJson.map((e) => QuranAyah.fromJson(e as Map<String, dynamic>)).toList();

    final byPage = <int, List<QuranAyah>>{};
    final bySurah = <int, List<QuranAyah>>{};
    for (final a in _ayahs!) {
      byPage.putIfAbsent(a.page, () => []).add(a);
      bySurah.putIfAbsent(a.surahNumber, () => []).add(a);
    }
    _byPage = byPage;
    _bySurah = bySurah;

    _mushafByPage = mushafJson.map(
      (pageStr, list) => MapEntry(
        int.parse(pageStr),
        (list as List<dynamic>)
            .map((e) => MushafAyahGlyph.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  List<QuranAyah> ayahsForPage(int page) => _byPage?[page] ?? const [];

  /// Authoritative Madinah-Mushaf page content: the exact glyph text of
  /// every ayah on [page], sourced directly from the KFGQPC Mushaf data —
  /// used instead of [ayahsForPage] for Mushaf Mode, since it occasionally
  /// disagrees by one ayah with Tanzil's own page metadata at a page-turn
  /// boundary (e.g. 83:35), and the real Mushaf font data wins that tie.
  List<MushafAyahGlyph> mushafPage(int page) => _mushafByPage?[page] ?? const [];

  List<QuranAyah> ayahsForSurah(int surahNumber) => _bySurah?[surahNumber] ?? const [];

  QuranSurah surahByNumber(int number) => _surahs!.firstWhere((s) => s.number == number);

  int firstPageOfJuz(int juz) {
    for (final a in _ayahs!) {
      if (a.juz == juz) return a.page;
    }
    return 1;
  }

  int juzForPage(int page) {
    final list = _byPage?[page];
    if (list == null || list.isEmpty) return 1;
    return list.first.juz;
  }

  /// (hizb, quarter) at the top of [page] — matches the margin marks printed
  /// in a standard Madani Mushaf.
  (int, int) hizbForPage(int page) {
    final list = _byPage?[page];
    if (list == null || list.isEmpty) return (1, 1);
    return (list.first.hizb, list.first.hizbQuarter);
  }

  int firstPageOfHizb(int hizb) {
    for (final a in _ayahs!) {
      if (a.hizb == hizb) return a.page;
    }
    return 1;
  }

  String surahNameForPage(int page) {
    final list = _byPage?[page];
    if (list == null || list.isEmpty) return '';
    return surahByNumber(list.first.surahNumber).name;
  }

  List<QuranAyah> search(String query) {
    final q = normalizeArabic(query.trim());
    if (q.isEmpty || q.length < 2) return const [];
    return _ayahs!.where((a) => normalizeArabic(a.text).contains(q)).toList();
  }
}
