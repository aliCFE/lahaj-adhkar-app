import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/hajj_umrah_lessons.dart';
import '../models/lesson.dart';

/// A standalone library of Hajj & Umrah du'as, outside the lesson flow,
/// each with a copy button and its source/occasion noted.
class HajjUmrahDuasScreen extends StatelessWidget {
  const HajjUmrahDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أدعية الحج والعمرة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [for (final dua in hajjUmrahDuas) _DuaTile(dua: dua)],
      ),
    );
  }
}

class _DuaTile extends StatelessWidget {
  const _DuaTile({required this.dua});
  final DuaCard dua;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dua.note ?? dua.source,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'نسخ الدعاء',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: dua.text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الدعاء')));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dua.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16, height: 1.9, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(dua.source, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 11, color: Colors.black45)),
        ],
      ),
    );
  }
}
