import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/divine_names_repository.dart';
import '../models/divine_name.dart';
import '../theme/arabic_digits.dart';
import '../widgets/dark_mode_toggle.dart';

const _kBg = Color(0xFF0E1026);
const _kCard = Color(0xFF181B3A);
const _kAccent = Color(0xFF4CE0D2);
const _kGold = Color(0xFFE8C27A);
const _kTextDim = Color(0xFFB9BBD8);

final _kTashkeel = RegExp('[ً-ْٰـ]');

// Names are stored fully diacritized (e.g. "الرَّحْمَن"), but most people type
// search queries without tashkeel — strip it from both sides so "الرحمن"
// still matches.
String _stripTashkeel(String s) => s.replaceAll(_kTashkeel, '');

class DivineNamesScreen extends StatefulWidget {
  const DivineNamesScreen({super.key});

  @override
  State<DivineNamesScreen> createState() => _DivineNamesScreenState();
}

class _DivineNamesScreenState extends State<DivineNamesScreen> {
  late final Future<void> _loadFuture = DivineNamesRepository.instance.load();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('أسماء الله الحسنى'),
        actions: const [DarkModeToggle()],
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: _kAccent));
          }
          final all = DivineNamesRepository.instance.names;
          final q = _query.trim();
          final qNorm = _stripTashkeel(q);
          List<DivineName> filtered;
          if (qNorm.isEmpty) {
            filtered = all;
          } else {
            // Name/transliteration matches are what someone is almost always
            // looking for when they type a name — show only those when any
            // exist, instead of drowning them in unrelated entries whose
            // meaning/effect text happens to share a common descriptive word
            // (e.g. searching "الواسع" used to also surface "الرحمن" and
            // others, since "واسع" appears in their meaning text too).
            final nameMatches = all
                .where((n) => _stripTashkeel(n.name).contains(qNorm) || n.translit.toLowerCase().contains(q.toLowerCase()))
                .toList();
            filtered = nameMatches.isNotEmpty
                ? nameMatches
                : all.where((n) => n.meaning.contains(q) || n.effect.contains(q)).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم أو معنى...',
                    hintStyle: const TextStyle(color: _kTextDim),
                    prefixIcon: const Icon(Icons.search, color: _kAccent),
                    filled: true,
                    fillColor: _kCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    // Same breakpoints as the home screen's tile grid — fixes
                    // cards ballooning into huge, mostly-empty squares on
                    // tablet/desktop widths (a fixed 2-column count stretched
                    // each card to half the viewport).
                    final columns = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.05,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _NameCard(entry: filtered[i]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  const _NameCard({required this.entry});
  final DivineName entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _NameDetailSheet(entry: entry),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kCard, Color(0xFF212456)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kAccent.withValues(alpha: 0.6)),
                ),
                child: Text(toEasternDigits(entry.number), style: const TextStyle(color: _kAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text(
                entry.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiriQuran(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(entry.translit, style: const TextStyle(color: _kTextDim, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameDetailSheet extends StatelessWidget {
  const _NameDetailSheet({required this.entry});
  final DivineName entry;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [_kAccent.withValues(alpha: 0.25), Colors.transparent]),
                  border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Text(
                  entry.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiriQuran(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(child: Text(entry.translit, style: const TextStyle(color: _kAccent, fontSize: 14, letterSpacing: 1))),
            const SizedBox(height: 24),
            _DetailSection(
              icon: Icons.menu_book_rounded,
              iconColor: _kGold,
              title: 'المعنى',
              text: entry.meaning,
            ),
            const SizedBox(height: 16),
            _DetailSection(
              icon: Icons.favorite_rounded,
              iconColor: _kAccent,
              title: 'أثر الإيمان بهذا الاسم',
              text: entry.effect,
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
    this.highlight = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? iconColor.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.8),
          ),
        ],
      ),
    );
  }
}
