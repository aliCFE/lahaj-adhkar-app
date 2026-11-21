import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/quran_repository.dart';
import '../models/quran.dart';
import '../state/app_state.dart';
import '../theme/arabic_digits.dart';
import '../widgets/dark_mode_toggle.dart';

/// Mushaf Mode renders each page with the official per-page KFGQPC/QCF
/// Mushaf font (family "QCF_P001".."QCF_P604", one word-accurate ligature
/// font per page, sourced from the King Fahd Complex Mushaf data). Unlike a
/// printed Mushaf's one fixed type size, the display size is fit per page
/// (see [_fitScaleFor]) so a sparse page (e.g. a surah's closing page) fills
/// the card instead of leaving blank space, and a dense page shrinks just
/// enough to avoid scrolling. Reading Mode (toggle in the app bar) is the
/// accessible alternative with the app-wide adjustable text size.
///
/// This base size/line-height pair is the reference the per-page fit scale
/// multiplies: at multiplier 1.0 on a normal 15-line page, normal text
/// wrapping at the page width this screen renders at reproduces the
/// Mushaf's own line layout, since the font's per-page glyph advance-widths
/// were custom-built by the Complex's typesetters for exactly this purpose.
const double _kGlyphFontSize = 19;
const double _kGlyphLineHeight = 2.15;
const double _kBasmalaFontSize = 20;

String _mushafFontFamily(int page) => 'QCF_P${page.toString().padLeft(3, '0')}';

/// Custom Mushaf fonts are bundled assets, but Flutter only parses one into
/// the text engine the first time it's actually needed — until then, any
/// measurement against it (see [_measureHeight]) silently falls back to a
/// different font's metrics, which would throw off [_fitScaleFor]. Loading
/// it explicitly first and awaiting completion guarantees the measurement
/// that follows uses the real glyph widths.
final Set<String> _loadedMushafFonts = {};

Future<void> _ensureMushafFontLoaded(String family) async {
  if (_loadedMushafFonts.contains(family)) return;
  await (FontLoader(family)..addFont(rootBundle.load('assets/fonts/mushaf/$family.TTF'))).load();
  _loadedMushafFonts.add(family);
}

/// Auto-fits a page's content to exactly fill the available height with no
/// leftover blank space and no scrolling: a page with few ayahs renders its
/// text larger, a page with many words renders it smaller — product
/// direction takes this over literally keeping the printed Mushaf's fixed
/// type size on every page. The glyph data itself (which words/ayahs fall
/// on which page, and their exact orthography) is untouched; only the
/// display size of that fixed content changes, via a page-specific
/// [_fitScaleFor] fit measured against the real widget tree's font sizes
/// and spacing so the fit is exact rather than guessed.
///
/// Fitting is two separate knobs, not one, because text only wraps in
/// whole-line steps: the largest font that still fits can legitimately
/// leave up to just-under-one-line of blank space, which font size alone
/// can never close (the next size up would overflow to an extra line).
/// [_PageFit.fontScale] is chosen first (sizes the glyphs, which also
/// decides word-to-line wrapping); [_PageFit.leadingBoost] is chosen
/// second, stretching line/paragraph spacing only — never the glyph size
/// — to consume whatever that discreteness leaves over, without touching
/// which words landed on which line.
class _PageFit {
  const _PageFit(this.fontScale, this.leadingBoost);
  final double fontScale;
  final double leadingBoost;
}

final Map<String, _PageFit> _fitCache = {};

double _measureHeight(String text, TextStyle style, double maxWidth) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.rtl,
  )..layout(maxWidth: maxWidth < 1 ? 1 : maxWidth);
  return painter.height;
}

double _measureContentHeight(
  List<List<MushafAyahGlyph>> segments,
  double width,
  double scale,
  double fontScale,
  double leadingBoost,
  String fontFamily,
) {
  double total = 0;
  for (var i = 0; i < segments.length; i++) {
    final segment = segments[i];
    if (segment.first.ayahNumber == 1) {
      if (i != 0) total += 14 * scale * fontScale * leadingBoost;
      total += _measureHeight(
            QuranRepository.instance.surahByNumber(segment.first.surahNumber).name,
            GoogleFonts.amiriQuran(fontSize: 18 * scale * fontScale, fontWeight: FontWeight.bold),
            width - 24 * scale * fontScale,
          ) +
          20 * scale * fontScale +
          2;
      total += 10 * scale * fontScale * leadingBoost;
      final surahNumber = segment.first.surahNumber;
      if (surahNumber != 1 && surahNumber != 9) {
        total += _measureHeight(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          GoogleFonts.amiriQuran(fontSize: _kBasmalaFontSize * scale * fontScale),
          width,
        );
        total += 10 * scale * fontScale * leadingBoost;
      }
    }
    total += _measureHeight(
      segment.map((a) => a.glyphText).join(' '),
      TextStyle(fontFamily: fontFamily, fontSize: _kGlyphFontSize * scale * fontScale, height: _kGlyphLineHeight * leadingBoost),
      width,
    );
  }
  return total;
}

/// Finds the page's [_PageFit] by binary search in two passes, since text
/// height isn't a closed-form function of either knob once line-wrapping
/// is involved. Pass 1 grows [_PageFit.fontScale] (clamped to [0.4, 3.0])
/// at the reference leading. Pass 2 then grows [_PageFit.leadingBoost]
/// (clamped to [1.0, 1.8]) with that font scale now fixed, to close
/// whatever fractional-line gap pass 1 had to leave. Cached per page/size
/// since the page content is static and this runs on every build while
/// swiping.
_PageFit _fitScaleFor(
  int page,
  List<List<MushafAyahGlyph>> segments,
  double width,
  double height,
  double scale,
  String fontFamily,
) {
  final key = '$page:${width.round()}x${height.round()}';
  final cached = _fitCache[key];
  if (cached != null) return cached;

  var lo = 0.4;
  var hi = 3.0;
  for (var i = 0; i < 10; i++) {
    final mid = (lo + hi) / 2;
    final h = _measureContentHeight(segments, width, scale, mid, 1.0, fontFamily);
    if (h <= height) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  final fontScale = lo;

  var leadLo = 1.0;
  var leadHi = 1.8;
  for (var i = 0; i < 10; i++) {
    final mid = (leadLo + leadHi) / 2;
    final h = _measureContentHeight(segments, width, scale, fontScale, mid, fontFamily);
    if (h <= height) {
      leadLo = mid;
    } else {
      leadHi = mid;
    }
  }

  return _fitCache[key] = _PageFit(fontScale, leadLo);
}

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
          const DarkModeToggle(),
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

/// Mushaf Mode: paged "open book" layout, scaled dynamically to fill the
/// available space (phone portrait/landscape, tablet any orientation)
/// while preserving the page's aspect ratio — so the page always renders
/// as large as the screen allows without distorting its proportions.
class _QuranPageView extends StatefulWidget {
  const _QuranPageView({required this.page});
  final int page;

  @override
  State<_QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<_QuranPageView> {
  // Reference card content size at the original design scale (the fixed
  // 14/10 outer padding below is excluded from it) — every size inside the
  // page (font, margins, banner) scales relative to this, so enlarging the
  // page changes its overall size only, never its internal proportions.
  static const double _refCardWidth = 480 - 28;
  static const double _refCardHeight = 760 - 20;
  static const double _refAspectRatio = _refCardWidth / _refCardHeight;

  late Future<void> _fontReady = _ensurePageFontsLoaded(widget.page);

  // Both the per-page QCF font and GoogleFonts' amiriQuran (banner + Basmala)
  // need to be fully loaded before measuring, or [_fitScaleFor] measures
  // against fallback-font metrics instead of the real glyph widths.
  static Future<void> _ensurePageFontsLoaded(int page) => Future.wait([
        _ensureMushafFontLoaded(_mushafFontFamily(page)),
        GoogleFonts.pendingFonts(),
      ]);

  @override
  void didUpdateWidget(covariant _QuranPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _fontReady = _ensurePageFontsLoaded(widget.page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fontReady,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildPage(context);
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    final page = widget.page;
    final glyphAyahs = QuranRepository.instance.mushafPage(page);
    final fontFamily = _mushafFontFamily(page);

    // A page can contain several short surahs back to back (common near
    // the end of the Mushaf), so the ayahs are split into per-surah runs —
    // each run gets its own banner + Basmala when it starts a surah,
    // instead of only the page's very first ayah.
    final segments = <List<MushafAyahGlyph>>[];
    for (final a in glyphAyahs) {
      if (segments.isEmpty || segments.last.first.surahNumber != a.surahNumber) {
        segments.add([a]);
      } else {
        segments.last.add(a);
      }
    }

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final budgetW = constraints.maxWidth - 28;
          final budgetH = constraints.maxHeight - 20;
          double cardW = budgetW;
          double cardH = cardW / _refAspectRatio;
          if (cardH > budgetH) {
            cardH = budgetH;
            cardW = cardH * _refAspectRatio;
          }
          // Mild safety clamp so an extreme desktop-sized window doesn't
          // blow the page up to a comically large font.
          final scale = (cardW / _refCardWidth).clamp(0.5, 2.0);

          // Solve for the content-fit multiplier that makes this page's own
          // ayahs exactly fill the card's content area — mirrors the padding
          // and footer sizing below so the measurement matches what's drawn.
          const scrollPadH = 18.0;
          const scrollPadTop = 18.0;
          const scrollPadBottom = 8.0;
          final contentWidth = cardW - 2 * scrollPadH * scale;
          final footerHeight = _measureHeight(
                toEasternDigits(page),
                TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * scale),
                cardW,
              ) +
              10 * scale;
          final contentHeight = cardH - (scrollPadTop + scrollPadBottom) * scale - footerHeight;
          final fit = _fitScaleFor(page, segments, contentWidth, contentHeight, scale, fontFamily);

          final style = TextStyle(
            fontFamily: fontFamily,
            fontSize: _kGlyphFontSize * scale * fit.fontScale,
            height: _kGlyphLineHeight * fit.leadingBoost,
            color: const Color(0xFF2B2117),
          );

          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Container(
              width: cardW,
              height: cardH,
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
                      padding: EdgeInsets.fromLTRB(
                        scrollPadH * scale,
                        scrollPadTop * scale,
                        scrollPadH * scale,
                        scrollPadBottom * scale,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Every segment but the first necessarily opens a
                            // surah at its ayah 1 — a page only continues an
                            // earlier surah at its very start.
                            for (final segment in segments) ...[
                              if (segment.first.ayahNumber == 1) ...[
                                if (segment != segments.first)
                                  SizedBox(height: 14 * scale * fit.fontScale * fit.leadingBoost),
                                _SurahBanner(
                                  surah: QuranRepository.instance.surahByNumber(segment.first.surahNumber),
                                  scale: scale * fit.fontScale,
                                ),
                                SizedBox(height: 10 * scale * fit.fontScale * fit.leadingBoost),
                                if (segment.first.surahNumber != 1 && segment.first.surahNumber != 9)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10 * scale * fit.fontScale * fit.leadingBoost),
                                    child: Text(
                                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.amiriQuran(fontSize: _kBasmalaFontSize * scale * fit.fontScale, color: const Color(0xFF2B2117)),
                                    ),
                                  ),
                              ],
                              // The ayah-end ornament (circle + number) is already
                              // baked into each ayah's glyph sequence by the official
                              // Mushaf font data — joining the segment's ayahs with a
                              // plain space reproduces the exact printed text, with no
                              // separately-styled marker needed (and no risk of the
                              // WidgetSpan RTL-justification bug the old marker-based
                              // approach had to work around).
                              Text(
                                segment.map((a) => a.glyphText).join(' '),
                                textAlign: TextAlign.right,
                                style: style,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10 * scale),
                    child: Text(
                      toEasternDigits(page),
                      style: TextStyle(color: const Color(0xFFB08D57), fontWeight: FontWeight.bold, fontSize: 14 * scale),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      child: Center(
        child: ConstrainedBox(
          // Caps the line length on tablets so justified Arabic text stays
          // comfortable to read instead of stretching edge to edge.
          constraints: const BoxConstraints(maxWidth: 640),
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
        ),
      ),
    );
  }
}

class _SurahBanner extends StatelessWidget {
  const _SurahBanner({required this.surah, required this.scale});
  final QuranSurah surah;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 12 * scale),
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
              style: GoogleFonts.amiriQuran(fontSize: 18 * scale, color: const Color(0xFF6B4F1D), fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            surah.revelationLabel,
            style: TextStyle(fontSize: 11 * scale, color: const Color(0xFF6B4F1D)),
          ),
        ],
      ),
    );
  }
}
