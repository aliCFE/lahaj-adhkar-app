import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/quran_repository.dart';
import '../theme/arabic_digits.dart';
import 'quran_reader_screen.dart';

const _kMushafGold = Color(0xFFC9A96A);
const _kMushafDeepGold = Color(0xFFB08D57);
const _kMushafBg = Color(0xFFEDE6D6);
const _kMushafInk = Color(0xFF2B2117);

class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = QuranRepository.instance;
    final results = repo.search(_query);

    return Scaffold(
      backgroundColor: _kMushafBg,
      appBar: AppBar(
        backgroundColor: _kMushafInk,
        foregroundColor: _kMushafGold,
        title: const Text('البحث في القرآن الكريم'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              autofocus: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن آية أو كلمة...',
                prefixIcon: const Icon(Icons.search, color: _kMushafDeepGold),
                filled: true,
                fillColor: const Color(0xFFFBF6E9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kMushafGold),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _query.trim().length < 2
                ? const Center(child: Text('اكتب حرفين على الأقل للبحث'))
                : results.isEmpty
                    ? const Center(child: Text('لا توجد نتائج'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final a = results[i];
                          final surah = repo.surahByNumber(a.surahNumber);
                          return Card(
                            elevation: 0,
                            color: const Color(0xFFFBF6E9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: _kMushafGold),
                            ),
                            child: ListTile(
                              title: Text(
                                a.text,
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.amiriQuran(color: _kMushafInk, fontSize: 16),
                              ),
                              subtitle: Text(
                                '${surah.name} — آية ${toEasternDigits(a.ayahNumber)} — صفحة ${toEasternDigits(a.page)}',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: _kMushafDeepGold),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: a.page)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
