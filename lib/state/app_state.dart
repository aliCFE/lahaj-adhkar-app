import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dhikr_item.dart';

/// Holds favorites, per-item repetition progress, recently-read ids and
/// simple personalization settings. Everything is local to the device —
/// no account, no server, no tracking of religious usage.
class AppState extends ChangeNotifier {
  AppState(this._prefs);

  final SharedPreferences _prefs;

  static const _kFavorites = 'favorites';
  static const _kRecent = 'recent';
  static const _kTextScale = 'text_scale';
  static const _kHaptics = 'haptics';
  static const _kDarkMode = 'dark_mode';
  static const _kQuranLastPage = 'quran_last_page';
  static const _kQuranBookmarks = 'quran_bookmarks';

  Set<String> _favorites = {};
  List<String> _recent = [];
  final Map<String, int> _progress = {};
  double _textScale = 1.0;
  bool _haptics = true;
  bool _darkMode = false;
  int? _quranLastPage;
  Set<int> _quranBookmarks = {};

  Set<String> get favorites => _favorites;
  List<String> get recent => _recent;
  double get textScale => _textScale;
  bool get haptics => _haptics;
  bool get darkMode => _darkMode;
  int? get quranLastPage => _quranLastPage;
  Set<int> get quranBookmarks => _quranBookmarks;

  static Future<AppState> create() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    state._favorites = (prefs.getStringList(_kFavorites) ?? []).toSet();
    state._recent = prefs.getStringList(_kRecent) ?? [];
    state._textScale = prefs.getDouble(_kTextScale) ?? 1.0;
    state._haptics = prefs.getBool(_kHaptics) ?? true;
    state._darkMode = prefs.getBool(_kDarkMode) ?? false;
    state._quranLastPage = prefs.getInt(_kQuranLastPage);
    state._quranBookmarks =
        (prefs.getStringList(_kQuranBookmarks) ?? []).map(int.parse).toSet();
    return state;
  }

  bool isFavorite(String itemId) => _favorites.contains(itemId);

  void toggleFavorite(String itemId) {
    if (_favorites.contains(itemId)) {
      _favorites.remove(itemId);
    } else {
      _favorites.add(itemId);
    }
    _prefs.setStringList(_kFavorites, _favorites.toList());
    notifyListeners();
  }

  void markRecent(String itemId) {
    _recent.remove(itemId);
    _recent.insert(0, itemId);
    if (_recent.length > 50) _recent = _recent.sublist(0, 50);
    _prefs.setStringList(_kRecent, _recent);
    notifyListeners();
  }

  int progressFor(String itemId) => _progress[itemId] ?? 0;

  /// Advances the counter for [item] and returns the new count.
  /// Caps at the target repeat count so the completed state (e.g. "1/1")
  /// stays visible instead of silently snapping back to 0.
  int advance(DhikrItem item) {
    final current = _progress[item.id] ?? 0;
    if (!item.repeatCount.isOpen && current >= item.repeatCount.n) {
      return current;
    }
    final next = current + 1;
    _progress[item.id] = next;
    notifyListeners();
    return next;
  }

  void resetProgress(String itemId) {
    _progress[itemId] = 0;
    notifyListeners();
  }

  void setTextScale(double value) {
    _textScale = value;
    _prefs.setDouble(_kTextScale, value);
    notifyListeners();
  }

  void setHaptics(bool value) {
    _haptics = value;
    _prefs.setBool(_kHaptics, value);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    _prefs.setBool(_kDarkMode, value);
    notifyListeners();
  }

  void setQuranLastPage(int page) {
    _quranLastPage = page;
    _prefs.setInt(_kQuranLastPage, page);
    notifyListeners();
  }

  bool isQuranPageBookmarked(int page) => _quranBookmarks.contains(page);

  void toggleQuranBookmark(int page) {
    if (_quranBookmarks.contains(page)) {
      _quranBookmarks.remove(page);
    } else {
      _quranBookmarks.add(page);
    }
    _prefs.setStringList(_kQuranBookmarks, _quranBookmarks.map((e) => e.toString()).toList());
    notifyListeners();
  }
}
