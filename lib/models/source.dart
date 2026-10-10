enum Authenticity {
  quran,
  sahih,
  hasan,
  scholarlyDisagreement,
}

Authenticity authenticityFromString(String value) {
  switch (value) {
    case 'quran':
      return Authenticity.quran;
    case 'sahih':
      return Authenticity.sahih;
    case 'hasan':
      return Authenticity.hasan;
    case 'scholarly_disagreement':
      return Authenticity.scholarlyDisagreement;
    default:
      throw ArgumentError('Unknown authenticity value: $value');
  }
}

String authenticityLabel(Authenticity a) {
  switch (a) {
    case Authenticity.quran:
      return 'نص قرآني';
    case Authenticity.sahih:
      return 'صحيح';
    case Authenticity.hasan:
      return 'حسن';
    case Authenticity.scholarlyDisagreement:
      return 'ثابت مع خلاف في بعض ألفاظه';
  }
}

class Source {
  final String sourceName;
  final String? collection;
  final String? hadithNumber;
  final String? narrator;
  final Authenticity authenticity;
  final String? notes;

  const Source({
    required this.sourceName,
    this.collection,
    this.hadithNumber,
    this.narrator,
    required this.authenticity,
    this.notes,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      sourceName: json['sourceName'] as String,
      collection: json['collection'] as String?,
      hadithNumber: json['hadithNumber'] as String?,
      narrator: json['narrator'] as String?,
      authenticity: authenticityFromString(json['authenticity'] as String),
      notes: json['notes'] as String?,
    );
  }
}
