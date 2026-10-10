import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dhikr_item.dart';
import '../state/app_state.dart';
import '../widgets/dhikr_card.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.title, required this.items});

  final String title;
  final List<DhikrItem> items;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final PageController _controller = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppState>().markRecent(widget.items.first.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('لا توجد أذكار في هذا القسم حاليًا')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_index + 1) / items.length,
            minHeight: 6,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_index + 1} / ${items.length} أذكار',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: items.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                context.read<AppState>().markRecent(items[i].id);
              },
              itemBuilder: (context, i) => SingleChildScrollView(
                child: DhikrCard(item: items[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index > 0
                        ? () => _controller.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            )
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('السابق'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _index < items.length - 1
                        ? () => _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            )
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('التالي'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
