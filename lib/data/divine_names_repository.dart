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
    final namesJson = jsonDecode(namesRaw) as List<dynamic>;

    _names = namesJson.map((e) {
      final map = e as Map<String, dynamic>;
      return DivineName(
        number: map['n'] as int,
        name: map['name'] as String,
        translit: map['translit'] as String,
        meaning: map['meaning'] as String,
      );
    }).toList();
  }
}
