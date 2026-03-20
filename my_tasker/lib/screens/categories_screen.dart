// lib/screens/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';
import '../widgets/widgets.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(catsProvider);
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.surface, elevation: 0,
        title: const Row(children: [
          AppLogo(size: 26), SizedBox(width: 8),
          Text('বিষয় ও ক্যাটাগরি', style: TextStyle(fontWeight: FontWeight.w700, color: C.text)),
        ]),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: C.border)),
      ),
      body: cats.isEmpty
          ? const EmptyView(message: 'কোনো ক্যাটাগরি নেই।\n+ বোতামে চাপুন।', icon: Icons.category_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: cats.length,
              itemBuilder: (_, i) => _CatCard(cat: cats[i], ref: ref)
                  .animate().fadeIn(delay: Duration(milliseconds: i * 60)),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: C.primary, foregroundColor: Colors.white,
        onPressed: () => _showAddCat(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCat(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddCatSheet(ref: ref),
    );
  }
}

class _CatCard extends StatelessWidget {
  final MainCategory cat; final WidgetRef ref;
  const _CatCard({required this.cat, required this.ref});

  @override
  Widget build(BuildContext context) {
    final col  = C.byIndex(cat.colorIndex);
    final subs = DB.getSubCats(cat.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), color: col, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat.name, style: const TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w700)),
              Text('${K.tobn(subs.length)} টি উপ-ক্যাটাগরি', style: const TextStyle(color: C.textSub, fontSize: 12)),
            ])),
            Press(
              onTap: () => _showAddSub(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add, color: col, size: 16),
                  const SizedBox(width: 2),
                  Text('উপ-বিষয়', style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: C.textHint, size: 20),
              onPressed: () async { await DB.deleteCat(cat.id); ref.read(catsProvider.notifier).refresh(); },
            ),
          ]),
        ),
        if (subs.isNotEmpty) ...[
          const Divider(height: 1, color: C.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('উপ-ক্যাটাগরি (দীর্ঘ-চাপে মুছুন)',
                  style: TextStyle(color: C.textHint, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                  children: subs.map((s) => _SubChip(sub: s, ref: ref)).toList()),
            ]),
          ),
        ],
      ]),
    );
  }

  void _showAddSub(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddSubSheet(parentCat: cat, ref: ref),
    );
  }
}

class _SubChip extends StatelessWidget {
  final SubCategory sub; final WidgetRef ref;
  const _SubChip({required this.sub, required this.ref});
  @override
  Widget build(BuildContext context) {
    final col = C.byIndex(sub.colorIndex);
    return GestureDetector(
      onLongPress: () async { await DB.deleteSubCat(sub.id); ref.read(catsProvider.notifier).refresh(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: col.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: col.withOpacity(0.35)),
        ),
        child: Text(sub.name, style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _AddCatSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddCatSheet({required this.ref});
  @override State<_AddCatSheet> createState() => _AddCatSheetState();
}
class _AddCatSheetState extends State<_AddCatSheet> {
  final _name = TextEditingController();
  int _color = 0, _icon = 0xe080;
  @override void dispose() { _name.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHandle(),
      const Text('নতুন ক্যাটাগরি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text)),
      const SizedBox(height: 4),
      const Text('যেমন: গণিত, পদার্থবিজ্ঞান, ইংরেজি', style: TextStyle(color: C.textSub, fontSize: 12)),
      const SizedBox(height: 16),
      TextField(controller: _name, autofocus: true,
          style: const TextStyle(color: C.text),
          decoration: const InputDecoration(hintText: 'ক্যাটাগরির নাম')),
      const SizedBox(height: 16),
      const Text('রঙ:', style: TextStyle(color: C.textSub, fontSize: 13)),
      const SizedBox(height: 8),
      ColorPicker(selected: _color, onSelect: (i) => setState(() => _color = i)),
      const SizedBox(height: 16),
      const Text('আইকন:', style: TextStyle(color: C.textSub, fontSize: 13)),
      const SizedBox(height: 8),
      IconPicker(selected: _icon, onSelect: (c) => setState(() => _icon = c)),
      const SizedBox(height: 20),
      PBtn(label: 'ক্যাটাগরি যোগ করুন', fullWidth: true,
        onTap: () async {
          if (_name.text.trim().isEmpty) return;
          await DB.addCategory(_name.text.trim(), _color, _icon);
          widget.ref.read(catsProvider.notifier).refresh();
          if (mounted) Navigator.pop(context);
        }),
    ]),
  );
}

class _AddSubSheet extends StatefulWidget {
  final MainCategory parentCat; final WidgetRef ref;
  const _AddSubSheet({required this.parentCat, required this.ref});
  @override State<_AddSubSheet> createState() => _AddSubSheetState();
}
class _AddSubSheetState extends State<_AddSubSheet> {
  final _name = TextEditingController();
  int _color = 0;
  @override void dispose() { _name.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHandle(),
      const Text('উপ-ক্যাটাগরি যোগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text)),
      const SizedBox(height: 4),
      Text('ক্যাটাগরি: ${widget.parentCat.name}', style: const TextStyle(color: C.textSub, fontSize: 12)),
      const SizedBox(height: 16),
      TextField(controller: _name, autofocus: true,
          style: const TextStyle(color: C.text),
          decoration: const InputDecoration(hintText: 'উপ-ক্যাটাগরির নাম')),
      const SizedBox(height: 16),
      const Text('রঙ:', style: TextStyle(color: C.textSub, fontSize: 13)),
      const SizedBox(height: 8),
      ColorPicker(selected: _color, onSelect: (i) => setState(() => _color = i)),
      const SizedBox(height: 20),
      PBtn(label: 'যোগ করুন', fullWidth: true,
        onTap: () async {
          if (_name.text.trim().isEmpty) return;
          await DB.addSubCat(widget.parentCat.id, _name.text.trim(), _color);
          widget.ref.read(catsProvider.notifier).refresh();
          if (mounted) Navigator.pop(context);
        }),
    ]),
  );
}
