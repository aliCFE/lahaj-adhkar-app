class VerseRef {
  final int surah;
  final int ayah;
  final int page;
  const VerseRef({required this.surah, required this.ayah, required this.page});

  factory VerseRef.fromJson(Map<String, dynamic> json) => VerseRef(
        surah: json['s'] as int,
        ayah: json['a'] as int,
        page: json['p'] as int,
      );
}

class DivineName {
  final int number;
  final String name;
  final String translit;
  final String meaning;
  final List<VerseRef> verses;

  const DivineName({
    required this.number,
    required this.name,
    required this.translit,
    required this.meaning,
    required this.verses,
  });
}
