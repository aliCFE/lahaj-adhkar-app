import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dhikr_item.dart';
import '../state/app_state.dart';
import 'reader_screen.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key, required this.group});

  final DhikrGroup group;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: group.subcategories.isEmpty
          ? const Center(child: Text('المحتوى قيد الإعداد — قريبًا بإذن الله'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: group.subcategories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final sub = group.subcategories[i];
                final done = sub.items.where((it) => appState.progressFor(it.id) > 0).length;
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(sub.name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(done > 0 ? '$done / ${sub.items.length} أذكار' : '${sub.items.length} أذكار'),
                    trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen(title: sub.name, items: sub.items),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
