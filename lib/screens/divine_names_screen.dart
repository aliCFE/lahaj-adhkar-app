import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/divine_names_repository.dart';
import '../data/quran_repository.dart';
import '../models/divine_name.dart';
import '../theme/arabic_digits.dart';
import 'quran_reader_screen.dart';

const _kBg = Color(0xFF0E1026);
const _kCard = Color(0xFF181B3A);
const _kAccent = Color(0xFF4CE0D2);
const _kGold = Color(0xFFE8C27A);
const _kTextDim = Color(0xFFB9BBD8);

class DivineNamesScreen extends StatefulWidget {
  const DivineNamesScreen({super.key});

  @override
  State<DivineNamesScreen> createState() => _DivineNamesScreenState();
}

class _DivineNamesScreenState extends State<DivineNamesScreen> {
  late final Future<void> _loadFuture = Future.wait([
    DivineNamesRepository.instance.load(),
    QuranRepository.instance.load(),
  ]);
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
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: _kAccent));
          }
          final all = DivineNamesRepository.instance.names;
          final q = _query.trim();
          final filtered = q.isEmpty
              ? all
              : all.where((n) => n.name.contains(q) || n.meaning.contains(q) || n.translit.toLowerCase().contains(q.toLowerCase())).toList();

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
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _NameCard(entry: filtered[i]),
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
              if (entry.verses.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${toEasternDigits(entry.verses.length)} آية',
                    style: const TextStyle(color: _kGold, fontSize: 10),
                  ),
                ),
              ],
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
            const SizedBox(height: 18),
            Text('المعنى', style: TextStyle(color: _kGold, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              entry.meaning,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.7),
            ),
            const SizedBox(height: 24),
            Text(
              entry.verses.isEmpty ? 'الورود في القرآن' : 'ورد هذا الاسم في ${toEasternDigits(entry.verses.length)} آية',
              style: const TextStyle(color: _kGold, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              entry.verses.isEmpty
                  ? 'لم يرد هذا الاسم بهذه الصيغة نفسها في القرآن الكريم، وإنما ثبت من خلال السنة أو من معانٍ مشتقة من أفعال قرآنية بنفس الجذر.'
                  : 'القائمة تضم كل موضع ورد فيه لفظ الاسم آليًا من نص القرآن، وبعض الألفاظ العامة (كـ"الملك" أو "الحق") قد ترد أحيانًا بمعناها اللغوي العام لا بصيغة التسمية الصريحة لله تعالى.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(color: _kTextDim, fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 8),
            if (entry.verses.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.verses.map((v) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: v.page)));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        '${QuranRepository.instance.surahByNumber(v.surah).name} : ${toEasternDigits(v.ayah)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
