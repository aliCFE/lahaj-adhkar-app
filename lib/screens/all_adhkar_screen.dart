import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/content_repository.dart';
import '../models/dhikr_item.dart';
import '../state/app_state.dart';
import 'reader_screen.dart';

enum _Filter { all, favorites, recent }

class AllAdhkarScreen extends StatefulWidget {
  const AllAdhkarScreen({super.key, required this.groups, this.initialQuery});

  final List<DhikrGroup> groups;
  final String? initialQuery;

  @override
  State<AllAdhkarScreen> createState() => _AllAdhkarScreenState();
}

class _AllAdhkarScreenState extends State<AllAdhkarScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery ?? '');
  String _query = '';
  String? _categoryFilter;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
  }

  List<DhikrItem> get _allItems => widget.groups.expand((g) => g.allItems).toList();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    List<DhikrItem> items;
    if (_query.trim().isNotEmpty) {
      items = ContentRepository.instance.search(widget.groups, _query.trim());
    } else {
      items = _allItems;
    }

    if (_filter == _Filter.favorites) {
      items = items.where((it) => appState.isFavorite(it.id)).toList();
    } else if (_filter == _Filter.recent) {
      final recentIds = appState.recent;
      items = [
        for (final id in recentIds)
          if (items.any((it) => it.id == id)) items.firstWhere((it) => it.id == id),
      ];
    }

    if (_categoryFilter != null) {
      items = items.where((it) => it.categoryId == _categoryFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('كل الأذكار')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن ذكر، مناسبة، أو كلمة مفتاحية...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('الكل', _filter == _Filter.all, () => setState(() => _filter = _Filter.all)),
                _chip('المفضلة', _filter == _Filter.favorites, () => setState(() => _filter = _Filter.favorites)),
                _chip('قُرئ مؤخرًا', _filter == _Filter.recent, () => setState(() => _filter = _Filter.recent)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('لا توجد نتائج'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          title: Text(
                            it.arabicText,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                          subtitle: Text(it.occasion, textDirection: TextDirection.rtl, textAlign: TextAlign.right),
                          trailing: Icon(
                            appState.isFavorite(it.id) ? Icons.favorite : Icons.favorite_border,
                            color: appState.isFavorite(it.id) ? Colors.redAccent : null,
                            size: 20,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReaderScreen(title: it.occasion, items: [it])),
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

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}
