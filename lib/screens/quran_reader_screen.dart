import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/quran_repository.dart';
import '../models/quran.dart';
import '../state/app_state.dart';
import '../theme/arabic_digits.dart';

/// Mushaf Mode uses a fixed type size, independent of device size or the
/// app-wide text-size slider — matching how a printed Mushaf has one fixed
/// type size per edition. Reading Mode (toggle in the app bar) is the
/// accessible alternative with adjustable size, for users who need it.
const double _kMushafFontSize = 19;
const double _kMushafLineHeight = 2.3;
const double _kBasmalaFontSize = 20;

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key, required this.initialPage});

  final int initialPage;

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late final PageController _controller =
      PageController(initialPage: widget.initialPage - 1);
  late int _page = widget.initialPage;
  bool _readingMode = false;
  final _repo = QuranRepository.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().setQuranLastPage(_page);
    });
  }

  void _jumpToPage(int page) {
    final clamped = page.clamp(1, kQuranPageCount);
    _controller.jumpToPage(clamped - 1);
  }

  Future<void> _showPageJumpDialog() async {
    final controller = TextEditingController();
    final target = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الانتقال إلى صفحة'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: '1 - 604'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
    if (target != null) _jumpToPage(target);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final surahName = _repo.surahNameForPage(_page);
    final juz = _repo.juzForPage(_page);
    final (hizb, quarter) = _repo.hizbForPage(_page);

    return Scaffold(
      appBar: AppBar(
        title: Text(surahName),
        actions: [
          IconButton(
            tooltip: _readingMode ? 'وضع المصحف' : 'وضع القراءة',
            icon: Icon(_readingMode ? Icons.menu_book_rounded : Icons.text_fields_rounded),
            onPressed: () => setState(() => _readingMode = !_readingMode),
          ),
          IconButton(
            icon: Icon(
              appState.isQuranPageBookmarked(_page) ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () => appState.toggleQuranBookmark(_page),
          ),
        ],
      ),
      backgroundColor: _readingMode ? null : const Color(0xFFEDE6D6),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'الجزء ${toEasternDigits(juz)} · ${hizbQuarterLabel(quarter)} من الحزب ${toEasternDigits(hizb)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: kQuranPageCount,
                  onPageChanged: (i) {
                    final newPage = i + 1;
                    setState(() => _page = newPage);
                    context.read<AppState>().setQuranLastPage(newPage);
                  },
                  itemBuilder: (context, i) => _readingMode
                      ? _QuranReadingModePage(page: i + 1)
                      : _QuranPageView(page: i + 1),
                ),
                // Tap zones: right third = previous page, left third = next
                // page — matching RTL reading direction (forward progress
                // moves toward the left of the screen). Row reverses child
                // order under ambient RTL Directionality, so the "previous"
                // zone is listed first to land on the physical right (same
                // convention as the السابقة/التالية button row below).
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _page > 1 ? () => _jumpToPage(_page - 1) : null,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const Expanded(flex: 2, child: SizedBox.shrink()),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _page < kQuranPageCount ? () => _jumpToPage(_page + 1) : null,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _page > 1 ? () => _jumpToPage(_page - 1) : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('السابقة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _showPageJumpDialog,
                    child: Text('${toEasternDigits(_page)} / ${toEasternDigits(kQuranPageCount)}'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _page < kQuranPageCount ? () => _jumpToPage(_page + 1) : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('التالية'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mushaf Mode: fixed-size paged "open book" layout.
class _QuranPageView extends StatelessWidget {
  const _QuranPageView({required this.page});
  final int page;

  @override
  Widget build(BuildContext context) {
    final ayahs = QuranRepository.instance.ayahsForPage(page);
    final style = GoogleFonts.amiriQuran(
      fontSize: _kMushafFontSize,
      height: _kMushafLineHeight,
      color: const Color(0xFF2B2117),
    );
    final isNewSurah = ayahs.isNotEmpty && ayahs.first.ayahNumber == 1;
    final surah = isNewSurah ? QuranRepository.instance.surahByNumber(ayahs.first.surahNumber) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFBF6E9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFC9A96A), width: 1.4),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (surah != null) ...[
                        _SurahBanner(surah: surah),
                        const SizedBox(height: 10),
                        if (surah.number != 1 && surah.number != 9)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiriQuran(fontSize: _kBasmalaFontSize, color: const Color(0xFF2B2117)),
                            ),
                          ),
                      ],
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: style,
                          children: [
                            for (final a in ayahs) ...[
                              TextSpan(text: a.text),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFB08D57), width: 1.2),
                                      color: a.isSajda ? const Color(0x33B08D57) : null,
                                    ),
                                    child: Text(
                                      toEasternDigits(a.ayahNumber),
                                      style: const TextStyle(fontSize: 10.5, color: Color(0xFFB08D57)),
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' '),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                toEasternDigits(page),
                style: const TextStyle(color: Color(0xFFB08D57), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reading Mode: plain scrollable text with the app's adjustable text size,
/// for users who need larger text than the fixed Mushaf layout allows.
class _QuranReadingModePage extends StatelessWidget {
  const _QuranReadingModePage({required this.page});
  final int page;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final ayahs = QuranRepository.instance.ayahsForPage(page);
    final style = GoogleFonts.amiriQuran(
      fontSize: 22 * appState.textScale,
      height: 2.1,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: style,
            children: [
              for (final a in ayahs) ...[
                TextSpan(text: a.text),
                TextSpan(
                  text: ' ﴿${toEasternDigits(a.ayahNumber)}﴾ ',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16 * appState.textScale),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SurahBanner extends StatelessWidget {
  const _SurahBanner({required this.surah});
  final QuranSurah surah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E6C8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFC9A96A), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              surah.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiriQuran(fontSize: 18, color: const Color(0xFF6B4F1D), fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            surah.revelationLabel,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B4F1D)),
          ),
        ],
      ),
    );
  }
}
