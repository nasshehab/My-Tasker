// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final grouped = <String, List<HistoryEntry>>{};
    for (final e in history) {
      grouped.putIfAbsent(K.dateKey(e.timestamp), () => []).add(e);
    }
    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.surface, elevation: 0,
        title: const Row(children: [
          AppLogo(size: 26), SizedBox(width: 8),
          Text('কার্যক্রমের ইতিহাস', style: TextStyle(fontWeight: FontWeight.w700, color: C.text)),
        ]),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: C.border)),
      ),
      body: history.isEmpty
          ? const EmptyView(
              message: 'এখনো কোনো কার্যক্রম নেই।\nকাজ সম্পন্ন করলে এখানে দেখা যাবে।',
              icon: Icons.history)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: keys.length,
              itemBuilder: (_, i) {
                final key     = keys[i];
                final entries = grouped[key]!;
                final date    = DateTime.parse(key);
                final isToday = key == K.dateKey(DateTime.now());
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isToday ? C.primaryDim : C.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isToday ? 'আজ' : K.fmtDate(date),
                        style: TextStyle(
                            color: isToday ? C.primary : C.textSub,
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  ...entries.map((e) => _HistoryTile(entry: e)),
                ]);
              },
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryTile({required this.entry});

  Color get _col {
    switch (entry.type) {
      case 'task':  return C.green;
      case 'study': return C.primary;
      case 'habit': return C.accent;
      default:      return C.textSub;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: C.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border)),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: _col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(IconData(entry.iconCode, fontFamily: 'MaterialIcons'), color: _col, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(entry.title, style: const TextStyle(color: C.text, fontSize: 13, fontWeight: FontWeight.w500)),
        if (entry.description.isNotEmpty)
          Text(entry.description, style: const TextStyle(color: C.textSub, fontSize: 11)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(K.fmtTime(entry.timestamp), style: const TextStyle(color: C.textHint, fontSize: 11)),
        if (entry.minutes != null)
          Text(K.fmtDuration(entry.minutes!),
              style: TextStyle(color: _col, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ]),
  );
}
