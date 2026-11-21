import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
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
    var selected = _page;
    final target = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الانتقال إلى صفحة'),
        content: SizedBox(
          height: 180,
          width: 140,
          child: CupertinoPicker.builder(
            scrollController: FixedExtentScrollController(initialItem: _page - 1),
            itemExtent: 38,
            onSelectedItemChanged: (i) => selected = i + 1,
            childCount: kQuranPageCount,
            itemBuilder: (context, i) => Center(
              child: Text(toEasternDigits(i + 1), style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(context, selected),
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
          // Mushaf Mode shows this on the page itself (see _MarginLabel) —
          // matching the real Mushaf's own corner markers instead of
          // duplicating the same info in the app's toolbar.
          if (_readingMode)
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
          // Taller than scrollPadBottom to reserve a clear header band for
          // the decorative Juz/Hizb corner labels (see _MarginLabel) above
          // the first line of text, so they never overlap it.
          const scrollPadTop = 34.0;
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

          final juz = QuranRepository.instance.juzForPage(page);
          final (hizb, _) = QuranRepository.instance.hizbForPage(page);

          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  foregroundPainter: _MushafFramePainter(scale: scale),
                  child: Container(
                    width: cardW,
                    height: cardH,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF6E9),
                      borderRadius: BorderRadius.circular(8 * scale),
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
                ),
                Positioned(
                  top: 9 * scale,
                  right: 14 * scale,
                  child: _MarginLabel(text: 'الجزء ${_arabicOrdinal(juz)}', scale: scale),
                ),
                Positioned(
                  top: 9 * scale,
                  left: 14 * scale,
                  child: _MarginLabel(text: 'الحزب ${_arabicOrdinal(hizb)}', scale: scale),
                ),
              ],
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

  static const _teal = Color(0xFF2F6F6B);
  static const _gold = Color(0xFFC9A96A);
  static const _cream = Color(0xFFFBF6E9);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 14 * scale),
      decoration: BoxDecoration(
        color: _teal,
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: _gold, width: 1 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              surah.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiriQuran(fontSize: 18 * scale, color: _cream, fontWeight: FontWeight.bold),
            ),
          ),
          Tooltip(
            message: surah.revelationLabel,
            child: Container(
              width: 18 * scale,
              height: 18 * scale,
              padding: EdgeInsets.all(3.5 * scale),
              decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
              child: CustomPaint(
                painter: surah.isMeccan ? const _KaabaPainter() : const _MedinaDomePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kaaba pictogram — the cube, the Kiswah's gold embroidered belt (Hizam),
/// the gold rain spout (Mizab al-Rahma) on the roofline, and the door (Bab
/// al-Kaaba) — for the revelation-place badge, standing in for "مكية".
class _KaabaPainter extends CustomPainter {
  const _KaabaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const black = Color(0xFF1C1C1C);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.12, w * 0.84, h * 0.84),
        Radius.circular(w * 0.06),
      ),
      Paint()..color = black,
    );

    // Gold rain spout (Mizab al-Rahma) emerging from the roofline.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.58, h * 0.02, w * 0.14, h * 0.15),
      Paint()..color = _SurahBanner._gold,
    );

    // Kiswah's embroidered gold belt (Hizam), roughly two-thirds up.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.08, h * 0.52, w * 0.84, h * 0.15),
      Paint()..color = _SurahBanner._gold,
    );

    // The door (Bab al-Kaaba), set into the lower face.
    final door = Rect.fromLTWH(w * 0.54, h * 0.72, w * 0.2, h * 0.24);
    canvas.drawRect(door, Paint()..color = _SurahBanner._gold);
    canvas.drawRect(
      door,
      Paint()
        ..color = black
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035,
    );
  }

  @override
  bool shouldRepaint(covariant _KaabaPainter oldDelegate) => false;
}

/// Prophet's Mosque pictogram — the Green Dome (Qubbat al-Khadra) in its
/// true onion/bulb silhouette, sitting on its drum, with a gold crescent
/// finial — for the revelation-place badge, standing in for "مدنية".
class _MedinaDomePainter extends CustomPainter {
  const _MedinaDomePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The mosque's base/drum beneath the dome.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.66, w * 0.56, h * 0.28),
        Radius.circular(w * 0.04),
      ),
      Paint()..color = _SurahBanner._cream,
    );

    // The green onion dome (Qubbat al-Khadra) — apex, bulge, then a neck
    // down to the drum, mirrored on both sides.
    final dome = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..cubicTo(w * 0.82, h * 0.10, w * 0.86, h * 0.40, w * 0.64, h * 0.54)
      ..lineTo(w * 0.64, h * 0.68)
      ..lineTo(w * 0.36, h * 0.68)
      ..lineTo(w * 0.36, h * 0.54)
      ..cubicTo(w * 0.14, h * 0.40, w * 0.18, h * 0.10, w * 0.5, h * 0.06)
      ..close();
    canvas.drawPath(dome, Paint()..color = _SurahBanner._teal);

    // Gold crescent finial on top.
    canvas.drawCircle(Offset(w * 0.5, h * 0.03), w * 0.07, Paint()..color = _SurahBanner._gold);
  }

  @override
  bool shouldRepaint(covariant _MedinaDomePainter oldDelegate) => false;
}

/// Small bordered marker reproducing a real Mushaf page's corner labels
/// (e.g. "الجزء الأول" / "الحزب الأول") — see [_arabicOrdinal].
class _MarginLabel extends StatelessWidget {
  const _MarginLabel({required this.text, required this.scale});
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: _SurahBanner._teal,
        borderRadius: BorderRadius.circular(4 * scale),
        border: Border.all(color: _SurahBanner._gold, width: 1 * scale),
      ),
      child: Text(
        text,
        style: GoogleFonts.amiriQuran(
          fontSize: 10.5 * scale,
          color: _SurahBanner._cream,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Converts 1-60 to an Arabic masculine ordinal ("الأول".."الستون") — enough
/// to cover every Juz (1-30) and Hizb (1-60) number on a real Mushaf page.
String _arabicOrdinal(int n) {
  const units = [
    '',
    'الأول',
    'الثاني',
    'الثالث',
    'الرابع',
    'الخامس',
    'السادس',
    'السابع',
    'الثامن',
    'التاسع',
  ];
  const unitsCompound = [
    '',
    'الحادي',
    'الثاني',
    'الثالث',
    'الرابع',
    'الخامس',
    'السادس',
    'السابع',
    'الثامن',
    'التاسع',
  ];
  const teens = [
    'العاشر',
    'الحادي عشر',
    'الثاني عشر',
    'الثالث عشر',
    'الرابع عشر',
    'الخامس عشر',
    'السادس عشر',
    'السابع عشر',
    'الثامن عشر',
    'التاسع عشر',
  ];
  const tens = ['', '', 'العشرون', 'الثلاثون', 'الأربعون', 'الخمسون', 'الستون'];

  if (n <= 9) return units[n];
  if (n <= 19) return teens[n - 10];
  if (n % 10 == 0) return tens[n ~/ 10];
  return '${unitsCompound[n % 10]} و${tens[n ~/ 10]}';
}

/// Decorative double-line frame + corner rosettes drawn just inside the
/// page card's edge, evoking the geometric border on a real printed
/// Mushaf page (an original design in the same visual language, not a
/// traced copy of any specific printed edition's artwork).
class _MushafFramePainter extends CustomPainter {
  const _MushafFramePainter({required this.scale});
  final double scale;

  static const _gold = Color(0xFFC9A96A);
  static const _teal = Color(0xFF2F6F6B);

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Offset.zero & size;

    final outerRRect = RRect.fromRectAndRadius(outer.deflate(4 * scale), Radius.circular(6 * scale));
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * scale,
    );

    final innerRRect = RRect.fromRectAndRadius(outer.deflate(8.5 * scale), Radius.circular(4 * scale));
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..color = _teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale,
    );

    final fill = Paint()..color = _gold;
    final dot = Paint()..color = _teal;
    for (final corner in [outer.topLeft, outer.topRight, outer.bottomLeft, outer.bottomRight]) {
      final dx = corner.dx < size.width / 2 ? 1.0 : -1.0;
      final dy = corner.dy < size.height / 2 ? 1.0 : -1.0;
      final center = corner + Offset(6.5 * dx * scale, 6.5 * dy * scale);
      _drawRosette(canvas, center, 6 * scale, fill, dot);
    }
  }

  void _drawRosette(Canvas canvas, Offset center, double r, Paint fill, Paint dot) {
    const points = 8;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * 0.42;
      final angle = (math.pi / points) * i;
      final p = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawCircle(center, r * 0.28, dot);
  }

  @override
  bool shouldRepaint(covariant _MushafFramePainter oldDelegate) => oldDelegate.scale != scale;
}
