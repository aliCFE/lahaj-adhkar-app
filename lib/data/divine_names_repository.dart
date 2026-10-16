import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/divine_name.dart';

class DivineNamesRepository {
  DivineNamesRepository._();
  static final DivineNamesRepository instance = DivineNamesRepository._();

  List<DivineName>? _names;
  List<DivineName> get names => _names!;
  bool get isLoaded => _names != null;

  Future<void> load() async {
    if (_names != null) return;
    final namesRaw = await rootBundle.loadString('assets/data/names_of_allah.json');
    final versesRaw = await rootBundle.loadString('assets/data/names_of_allah_verses.json');

    final namesJson = jsonDecode(namesRaw) as List<dynamic>;
    final versesJson = jsonDecode(versesRaw) as Map<String, dynamic>;

    _names = namesJson.map((e) {
      final map = e as Map<String, dynamic>;
      final number = map['n'] as int;
      final verseList = (versesJson[number.toString()] as List<dynamic>? ?? [])
          .map((v) => VerseRef.fromJson(v as Map<String, dynamic>))
          .toList();
      return DivineName(
        number: number,
        name: map['name'] as String,
        translit: map['translit'] as String,
        meaning: map['meaning'] as String,
        verses: verseList,
      );
    }).toList();
  }
}
