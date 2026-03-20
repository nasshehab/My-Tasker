// lib/screens/habits_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../utils/db.dart';
import '../widgets/widgets.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  static DateTime get _weekStart {
    final now = DateTime.now();
    // week starts on Friday (weekday 5)
    final daysFromFri = (now.weekday + 2) % 7;
    final fri = now.subtract(Duration(days: daysFromFri));
    return DateTime(fri.year, fri.month, fri.day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.surface,
        title: const Row(children: [
          AppLogo(size: 26), SizedBox(width: 8),
          Text('অভ্যাস ট্র্যাকার', style: TextStyle(fontWeight: FontWeight.w700, color: C.text)),
        ]),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: C.border),
        ),
      ),
      body: habits.isEmpty
          ? const EmptyView(
              message: 'কোনো অভ্যাস যোগ করা হয়নি।\n+ বোতামে চাপ দিয়ে শুরু করুন।',
              icon: Icons.repeat_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: habits.length,
              itemBuilder: (_, i) => _HabitCard(
                  habit: habits[i], startOfWeek: _weekStart, ref: ref)
                  .animate().fadeIn(delay: Duration(milliseconds: i * 50)),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: C.primary, foregroundColor: Colors.white,
        onPressed: () => _showAdd(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAdd(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddHabitSheet(ref: ref),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime weekStart;
  final WidgetRef ref;
  const _HabitCard({required this.habit, required this.weekStart, required this.ref});

  @override
  Widget build(BuildContext context) {
    final col  = C.byIndex(habit.colorIndex);
    final total = habit.completionLog.length;
    final done  = habit.completionLog.values.where((v) => v).length;
    final pct   = total == 0 ? 0 : (done * 100 ~/ total);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(IconData(habit.iconCode, fontFamily: 'MaterialIcons'), color: col, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(habit.name, style: const TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  habit.currentStreak > 0 ? 'প্রতিদিন | ${K.tobn(habit.currentStreak)}P' : 'প্রতিদিন',
                  style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ])),
            // Toggle today
            GestureDetector(
              onTap: () async {
                await DB.toggleHabit(habit.id, DateTime.now());
                ref.read(habitsProvider.notifier).refresh();
              },
              child: () {
                final todayKey = K.dateKey(DateTime.now());
                final todayDone = habit.completionLog[todayKey] ?? false;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todayDone ? C.green : C.surface2,
                    border: Border.all(color: todayDone ? C.green : C.border, width: 2),
                  ),
                  child: todayDone ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                );
              }(),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: C.textHint, size: 20),
              onPressed: () async {
                await DB.deleteHabit(habit.id);
                ref.read(habitsProvider.notifier).refresh();
              },
            ),
          ]),
          const SizedBox(height: 14),
          WeekDots(log: habit.completionLog, startOfWeek: weekStart),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.local_fire_department_outlined, color: col, size: 16),
            const SizedBox(width: 4),
            Text('${K.tobn(habit.currentStreak)} দিন',
                style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            Icon(Icons.check_circle_outline, color: C.green, size: 16),
            const SizedBox(width: 4),
            Text('$pct% সম্পন্ন',
                style: const TextStyle(color: C.textSub, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddHabitSheet({required this.ref});
  @override State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _name = TextEditingController();
  int _color = 0, _icon = 0xe80c, _target = 30;

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHandle(),
      const Text('নতুন অভ্যাস', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text)),
      const SizedBox(height: 16),
      TextField(controller: _name, autofocus: true,
          style: const TextStyle(color: C.text),
          decoration: const InputDecoration(
              hintText: 'অভ্যাসের নাম (যেমন: ৩০ মিনিট পড়া)',
              prefixIcon: Icon(Icons.edit_outlined, color: C.textHint))),
      const SizedBox(height: 14),
      Row(children: [
        const Text('লক্ষ্যমাত্রা:', style: TextStyle(color: C.textSub, fontSize: 13)),
        const Spacer(),
        IconButton(onPressed: () => setState(() => _target = (_target - 5).clamp(5, 480)),
            icon: const Icon(Icons.remove_circle_outline, color: C.textSub)),
        Text('${K.tobn(_target)} মিনিট',
            style: const TextStyle(color: C.text, fontWeight: FontWeight.w700)),
        IconButton(onPressed: () => setState(() => _target = (_target + 5).clamp(5, 480)),
            icon: const Icon(Icons.add_circle_outline, color: C.primary)),
      ]),
      const SizedBox(height: 12),
      const Text('রঙ:', style: TextStyle(color: C.textSub, fontSize: 13)),
      const SizedBox(height: 8),
      ColorPicker(selected: _color, onSelect: (i) => setState(() => _color = i)),
      const SizedBox(height: 12),
      const Text('আইকন:', style: TextStyle(color: C.textSub, fontSize: 13)),
      const SizedBox(height: 8),
      IconPicker(selected: _icon, onSelect: (c) => setState(() => _icon = c)),
      const SizedBox(height: 20),
      PBtn(
        label: 'অভ্যাস যোগ করুন', fullWidth: true,
        onTap: () async {
          if (_name.text.trim().isEmpty) return;
          await DB.addHabit(name: _name.text.trim(), colorIndex: _color, targetMinutes: _target, iconCode: _icon);
          widget.ref.read(habitsProvider.notifier).refresh();
          if (mounted) Navigator.pop(context);
        },
      ),
    ]),
  );
}
