class QuranSurah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final bool isMeccan;
  final int ayahCount;
  final int startPage;

  const QuranSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.isMeccan,
    required this.ayahCount,
    required this.startPage,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      isMeccan: json['revelationType'] == 'meccan',
      ayahCount: json['ayahCount'] as int,
      startPage: json['startPage'] as int,
    );
  }

  String get revelationLabel => isMeccan ? 'مكية' : 'مدنية';
}

class QuranAyah {
  final int globalNumber;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final int page;
  final int juz;
  final int hizb;
  final int hizbQuarter;
  final bool isSajda;

  const QuranAyah({
    required this.globalNumber,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.page,
    required this.juz,
    required this.hizb,
    required this.hizbQuarter,
    required this.isSajda,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      globalNumber: json['g'] as int,
      surahNumber: json['s'] as int,
      ayahNumber: json['a'] as int,
      text: json['t'] as String,
      page: json['p'] as int,
      juz: json['j'] as int,
      hizb: json['hz'] as int,
      hizbQuarter: json['hq'] as int,
      isSajda: json['sj'] as bool,
    );
  }
}

/// Arabic label for a quarter-hizb position, matching Mushaf margin marks:
/// quarter 1 = "ربع", 2 = "نصف", 3 = "ثلاثة أرباع", 4 = "حزب" (end of hizb).
String hizbQuarterLabel(int quarter) {
  switch (quarter) {
    case 1:
      return 'ربع الحزب';
    case 2:
      return 'نصف الحزب';
    case 3:
      return 'ثلاثة أرباع الحزب';
    default:
      return 'نهاية الحزب';
  }
}

const int kQuranPageCount = 604;
const int kQuranJuzCount = 30;
