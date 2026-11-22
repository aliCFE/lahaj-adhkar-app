import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/dhikr_item.dart';
import '../models/source.dart';
import '../services/error_report.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class DhikrCard extends StatelessWidget {
  const DhikrCard({super.key, required this.item, this.onCompleted});

  final DhikrItem item;

  /// Called right after a tap brings the counter to its target (e.g. "3/3"),
  /// so the reader screen can move on to the next dhikr automatically.
  /// Never called for open-ended (no fixed count) dhikr.
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final progress = appState.progressFor(item.id);
    final isFav = appState.isFavorite(item.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.occasion,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'الإبلاغ عن خطأ في هذا الذكر',
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () => reportContentError('${item.id} — ${item.occasion}'),
                ),
                IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                  onPressed: () => appState.toggleFavorite(item.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              item.arabicText,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicDhikrStyle(context, scale: appState.textScale),
            ),
            if (item.medicalDisclaimer) ...[
              const SizedBox(height: 10),
              Text(
                'تنبيه: هذا دعاء وذكر شرعي، وليس بديلًا عن العلاج الطبي.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            _RepeatCounter(item: item, progress: progress, onCompleted: onCompleted),
            const SizedBox(height: 12),
            _SourceFooter(sources: item.sources),
          ],
        ),
      ),
    );
  }
}

class _RepeatCounter extends StatelessWidget {
  const _RepeatCounter({required this.item, required this.progress, this.onCompleted});

  final DhikrItem item;
  final int progress;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final isOpen = item.repeatCount.isOpen;
    final total = isOpen ? null : item.repeatCount.n;
    final label = isOpen ? '$progress' : '$progress / $total';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (appState.haptics) HapticFeedback.lightImpact();
        final next = appState.advance(item);
        if (!isOpen && next == item.repeatCount.n) onCompleted?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isOpen ? 'اضغط للتسبيح (بلا عدد محدد)' : 'اضغط لإكمال الذكر',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  const _SourceFooter({required this.sources});

  final List<Source> sources;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: sources.map((s) {
        final text = s.hadithNumber != null ? '${s.sourceName} (${s.hadithNumber})' : s.sourceName;
        return Chip(
          label: Text(text, style: const TextStyle(fontSize: 11)),
          visualDensity: VisualDensity.compact,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          side: BorderSide.none,
        );
      }).toList(),
    );
  }
}
