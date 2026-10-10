import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/quran_repository.dart';
import '../models/quran.dart';
import '../state/app_state.dart';
import '../theme/arabic_digits.dart';
import 'quran_reader_screen.dart';
import 'quran_search_screen.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

const _kMushafGold = Color(0xFFC9A96A);
const _kMushafDeepGold = Color(0xFFB08D57);
const _kMushafBg = Color(0xFFEDE6D6);
const _kMushafInk = Color(0xFF2B2117);

class _QuranIndexScreenState extends State<QuranIndexScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  late final Future<void> _loadFuture = QuranRepository.instance.load();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: _kMushafBg,
      appBar: AppBar(
        backgroundColor: _kMushafInk,
        foregroundColor: _kMushafGold,
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranSearchScreen())),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _kMushafGold,
          unselectedLabelColor: _kMushafGold.withValues(alpha: 0.55),
          indicatorColor: _kMushafGold,
          tabs: const [Tab(text: 'السور'), Tab(text: 'الأجزاء'), Tab(text: 'المحفوظات')],
        ),
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final repo = QuranRepository.instance;
          return Column(
            children: [
              if (appState.quranLastPage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Material(
                    color: _kMushafInk,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: appState.quranLastPage!)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_rounded, color: _kMushafGold),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('متابعة القراءة', style: TextStyle(color: _kMushafGold, fontWeight: FontWeight.bold)),
                                  Text(
                                    'الصفحة ${toEasternDigits(appState.quranLastPage!)} — ${repo.surahNameForPage(appState.quranLastPage!)}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_back_ios_new, size: 16, color: _kMushafGold),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SurahList(repo: repo),
                    _JuzList(repo: repo),
                    _BookmarksList(repo: repo, appState: appState),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList({required this.repo});
  final QuranRepository repo;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: repo.surahs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final s = repo.surahs[i];
        return Card(
          elevation: 0,
          color: const Color(0xFFFBF6E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _kMushafGold),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _kMushafGold.withValues(alpha: 0.25),
              child: Text(toEasternDigits(s.number), style: const TextStyle(fontSize: 13, color: _kMushafInk)),
            ),
            title: Text(s.name, style: const TextStyle(color: _kMushafInk)),
            subtitle: Text('${s.revelationLabel} · ${toEasternDigits(s.ayahCount)} آية', style: const TextStyle(color: _kMushafDeepGold)),
            trailing: Text('ص ${toEasternDigits(s.startPage)}', style: const TextStyle(color: _kMushafDeepGold)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: s.startPage)),
            ),
          ),
        );
      },
    );
  }
}

class _JuzList extends StatelessWidget {
  const _JuzList({required this.repo});
  final QuranRepository repo;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: kQuranJuzCount,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final juz = i + 1;
        final page = repo.firstPageOfJuz(juz);
        return Card(
          elevation: 0,
          color: const Color(0xFFFBF6E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _kMushafGold),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _kMushafGold.withValues(alpha: 0.25),
              child: Text(toEasternDigits(juz), style: const TextStyle(fontSize: 13, color: _kMushafInk)),
            ),
            title: Text('الجزء ${toEasternDigits(juz)}', style: const TextStyle(color: _kMushafInk)),
            subtitle: Text(repo.surahNameForPage(page), style: const TextStyle(color: _kMushafDeepGold)),
            trailing: Text('ص ${toEasternDigits(page)}', style: const TextStyle(color: _kMushafDeepGold)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: page)),
            ),
          ),
        );
      },
    );
  }
}

class _BookmarksList extends StatelessWidget {
  const _BookmarksList({required this.repo, required this.appState});
  final QuranRepository repo;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final pages = appState.quranBookmarks.toList()..sort();
    if (pages.isEmpty) {
      return const Center(child: Text('لا توجد صفحات محفوظة بعد'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final page = pages[i];
        return Card(
          elevation: 0,
          color: const Color(0xFFFBF6E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _kMushafGold),
          ),
          child: ListTile(
            leading: const Icon(Icons.bookmark_rounded, color: _kMushafDeepGold),
            title: Text('الصفحة ${toEasternDigits(page)}', style: const TextStyle(color: _kMushafInk)),
            subtitle: Text(repo.surahNameForPage(page), style: const TextStyle(color: _kMushafDeepGold)),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18, color: _kMushafDeepGold),
              onPressed: () => appState.toggleQuranBookmark(page),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: page)),
            ),
          ),
        );
      },
    );
  }
}
